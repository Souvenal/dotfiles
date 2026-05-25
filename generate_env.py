#!/usr/bin/env python3
import json
import argparse
import re
from pathlib import Path
from dataclasses import dataclass
from typing import Callable


@dataclass
class ShellBackend:
    name: str
    indent: str
    export_line: Callable
    local_line: Callable
    alias_line: Callable
    eval_line: Callable
    source_line: Callable
    mkdir_line: Callable
    translate_condition: Callable
    render_condition: Callable
    close_block: str
    close_template: str


def translate_bash_condition(cond: str) -> tuple:
    return f"if {cond}; then", "fi"


def translate_fish_condition(cond: str) -> tuple:
    return f"if {cond}", "end"


def translate_ps1_condition(cond: str) -> tuple:
    return f"if ({cond}) {{", "}"


def render_bash_condition(cond_type: str, cond_value: str) -> str:
    condition_map = {
        "executable": f'command -v "{cond_value}" > /dev/null',
        "not_empty": f'[ -n "{cond_value}" ]',
        "dir_exists": f'[ -d "{cond_value}" ]',
        "file_exists": f'[ -f "{cond_value}" ]',
        "empty": f'[ -z "{cond_value}" ]',
        "path_exists": f'[ -e "{cond_value}" ]',
    }
    return condition_map.get(cond_type, "")


def render_fish_condition(cond_type: str, cond_value: str) -> str:
    condition_map = {
        "executable": f'command -v "{cond_value}" > /dev/null',
        "not_empty": f'test -n "{cond_value}"',
        "dir_exists": f'test -d "{cond_value}"',
        "file_exists": f'test -f "{cond_value}"',
        "empty": f'test -z "{cond_value}"',
        "path_exists": f'test -e "{cond_value}"',
    }
    return condition_map.get(cond_type, "")


def render_ps1_condition(cond_type: str, cond_value: str) -> str:
    def to_env_var(v: str) -> str:
        if v.startswith("$env:"):
            return v
        elif v.startswith("$"):
            return f"$env:{v[1:]}"
        else:
            return f"$env:{v}"

    env_var = to_env_var(cond_value)
    condition_map = {
        "executable": f"(Get-Command {cond_value}).Source | Test-Path -PathType Leaf -ErrorAction SilentlyContinue",
        "not_empty": f"[string]::IsNullOrEmpty({env_var}) -eq $false",
        "dir_exists": f"Test-Path {env_var} -PathType Container",
        "file_exists": f'Test-Path "{env_var}" -PathType Leaf',
        "empty": f"[string]::IsNullOrEmpty({env_var})",
        "path_exists": f"Test-Path {env_var}",
    }
    return condition_map.get(cond_type, "")


def make_export_line(indent_fn: Callable, quote_fn: Callable):
    def f(key: str, value: str, depth: int, quote: str = '"') -> str:
        if quote == '"' and '"' in value:
            value = value.replace("\\", "\\\\").replace('"', '\\"')
            return f'{indent_fn(depth)}export {key}="{value}"'
        elif quote == "'" and "'" in value:
            value = value.replace("'", "'\\''")
            return f"{indent_fn(depth)}export {key}='{value}'"
        return (
            f"{indent_fn(depth)}export {key}={quote_fn(quote)}{value}{quote_fn(quote)}"
        )

    return f


def escape_value(value: str, quote: str) -> str:
    if quote == '"' and '"' in value:
        return value.replace("\\", "\\\\").replace('"', '\\"')
    elif quote == "'" and "'" in value:
        return value.replace("'", "'\\''")
    return value


def convert_path_separator(value: str, target_shell: str) -> str:
    if target_shell != "ps1":
        return value

    path_keys = [
        "PATH",
        "PKG_CONFIG_PATH",
        "LD_LIBRARY_PATH",
        "PYTHONPATH",
        "CLASSPATH",
        "GOPATH",
    ]

    if not any(k in value for k in path_keys):
        return value

    if "${" in value:
        return value

    protected = []
    placeholder = "___PROT_{}___"

    def protect(match):
        protected.append(match.group(0))
        return placeholder.format(len(protected) - 1)

    protected_value = re.sub(r"\$env:[A-Za-z_][A-Za-z0-9_]*", protect, value)
    protected_value = protected_value.replace(":", ";")
    for i, p in enumerate(protected):
        protected_value = protected_value.replace(placeholder.format(i), p)

    return protected_value


def postprocess_ps1(content: str) -> str:
    """
    Post-process PowerShell content to convert environment variable references
    from shell-style ($VAR or ${VAR}) to PowerShell-style ($env:VAR).
    """
    lines = content.split("\n")
    processed_lines = []

    for line in lines:
        # Skip lines that are comments
        if line.strip().startswith("#"):
            processed_lines.append(line)
            continue

        # Handle lines with chezmoi templates by temporarily replacing them

        # Find and protect chezmoi templates
        template_parts = []
        template_placeholder = "___TEMPLATE_{}___"
        template_count = 0

        def protect_template(match):
            nonlocal template_count
            placeholder = template_placeholder.format(template_count)
            template_count += 1
            template_parts.append(match.group(0))
            return placeholder

        line_with_templates = re.sub(r"{{.*?}}", protect_template, line)

        # Replace environment variable references
        # Skip $HOME and other built-in variables
        # Skip $env: variables (already correct)
        # Convert $VAR or ${VAR} to $env:VAR

        # First pass: mark $env:VAR as already correct by adding a temporary marker
        # This prevents them from being re-matched
        temp_marker = "___ENV___"
        line_with_templates = re.sub(
            r"\$env:([A-Za-z_][A-Za-z0-9_]*)", temp_marker + r"\1", line_with_templates
        )

        # Second pass: convert $VAR or ${VAR} to $env:VAR
        # Pattern to match $VAR or ${VAR} but not $HOME
        pattern = r"\$(?:([A-Za-z_][A-Za-z0-9_]*)|\{([A-Za-z_][A-Za-z0-9_]*)\})"

        def replace_var(match):
            var_name = match.group(1) or match.group(2)
            # Skip PowerShell built-in variables
            built_in_vars = [
                "HOME",
                "PWD",
                "USERPROFILE",
                "HOSTNAME",
                "NULL",
                "TRUE",
                "FALSE",
                "NULL",
            ]
            if var_name in built_in_vars:
                return match.group(0)
            return f"$env:{var_name}"

        processed_line = re.sub(pattern, replace_var, line_with_templates)

        # Third pass: restore the temporary markers back to $env:VAR
        processed_line = re.sub(
            temp_marker + r"([A-Za-z_][A-Za-z0-9_]*)", r"$env:\1", processed_line
        )

        # Restore chezmoi templates
        for i, template in enumerate(template_parts):
            processed_line = processed_line.replace(
                template_placeholder.format(i), template
            )

        processed_lines.append(processed_line)

    return "\n".join(processed_lines)


BACKENDS = {
    "bash": ShellBackend(
        name="bash",
        indent="    ",
        export_line=lambda k, v, d, q='"': (
            f'{"    " * d}export {k}="{escape_value(v, q)}"'
        ),
        local_line=lambda k, v, d: f"{'    ' * d}{k}={v}",
        alias_line=lambda k, v, d: f"{'    ' * d}alias {k}='{v}'",
        eval_line=lambda v, d: f'{"    " * d}eval "{v}"',
        source_line=lambda v, d: f"{'    ' * d}{v}",
        translate_condition=translate_bash_condition,
        render_condition=render_bash_condition,
        close_block="fi",
        close_template="{{- end -}}",
        mkdir_line=lambda v, d: (
            f'{"    " * d}if [ ! -d "{v}" ]; then mkdir -p "{v}"; fi'
        ),
    ),
    "zsh": ShellBackend(
        name="zsh",
        indent="    ",
        export_line=lambda k, v, d, q='"': (
            f'{"    " * d}export {k}="{escape_value(v, q)}"'
        ),
        local_line=lambda k, v, d: f"{'    ' * d}{k}={v}",
        alias_line=lambda k, v, d: f"{'    ' * d}alias {k}='{v}'",
        eval_line=lambda v, d: f'{"    " * d}eval "{v}"',
        source_line=lambda v, d: f"{'    ' * d}{v}",
        translate_condition=translate_bash_condition,
        render_condition=render_bash_condition,
        close_block="fi",
        close_template="{{- end -}}",
        mkdir_line=lambda v, d: (
            f'{"    " * d}if [ ! -d "{v}" ]; then mkdir -p "{v}"; fi'
        ),
    ),
    "fish": ShellBackend(
        name="fish",
        indent="    ",
        export_line=lambda k, v, d, q='"': (
            f'{"    " * d}set -gx {k} "{escape_value(v, q)}"'
        ),
        local_line=lambda k, v, d: f"{'    ' * d}set {k} {v}",
        alias_line=lambda k, v, d: f"{'    ' * d}alias {k} '{v}'",
        eval_line=lambda v, d: f'{"    " * d}eval "{v}"',
        source_line=lambda v, d: f"{'    ' * d}{v}",
        translate_condition=translate_fish_condition,
        render_condition=render_fish_condition,
        close_block="end",
        close_template="{{- end -}}",
        mkdir_line=lambda v, d: (
            f'{"    " * d}if not test -d "{v}"; mkdir -p "{v}"; end'
        ),
    ),
    "ps1": ShellBackend(
        name="ps1",
        indent="    ",
        export_line=lambda k, v, d, q='"': (
            f'{"    " * d}$env:{k} = "{escape_value(v, q)}"'
        ),
        local_line=lambda k, v, d: f'{"    " * d}${k} = "{v}"',
        alias_line=lambda k, v, d: f"{'    ' * d}Set-Alias {k} '{v}'",
        eval_line=lambda v, d: f'{"    " * d}Invoke-Expression "{v}"',
        source_line=lambda v, d: f"{'    ' * d}. {v}",
        translate_condition=translate_ps1_condition,
        render_condition=render_ps1_condition,
        close_block="}",
        close_template="{{- end -}}",
        mkdir_line=lambda v, d: (
            f'{"    " * d}if (-not (Test-Path "{v}")) {{ New-Item -ItemType Directory -Path "{v}" -Force }}'
        ),
    ),
}


def render(env_data: dict, backend: ShellBackend, target_shell: str = "all") -> str:
    lines = []

    for block in env_data.get("blocks", []):
        block_shells = block.get("shell", "all")
        if block_shells != "all" and target_shell not in block_shells:
            continue

        comments = block.get("comment", [])
        env_vars = block.get("env", [])
        condition = block.get("condition")
        dirs = block.get("dir", [])

        for c in comments:
            lines.append(f"# {c}")

        block_depth = 0
        block_close = None

        for d in dirs:
            lines.append(backend.mkdir_line(d, block_depth))

        if condition:
            if isinstance(condition, dict):
                cond_type = condition.get("type")
                cond_value = condition.get("value")
                cond_str = backend.render_condition(cond_type, cond_value)
                cond_line, block_close = backend.translate_condition(cond_str)
                lines.append(cond_line)
                block_depth = 1
            else:
                cond_line, block_close = backend.translate_condition(condition)
                lines.append(cond_line)
                block_depth = 1

        for env in env_vars:
            key = env.get("key", "")
            value = env.get("value", "").replace("\\n", "\n")
            value = convert_path_separator(value, target_shell)
            env_condition = env.get("condition")
            env_type = env.get("type", "export")
            quote = env.get("quote", '"')

            env_depth = block_depth
            env_close = None

            if env_condition:
                if isinstance(env_condition, dict):
                    cond_type = env_condition.get("type")
                    cond_value = env_condition.get("value")
                    cond_str = backend.render_condition(cond_type, cond_value)
                    cond_line, env_close = backend.translate_condition(cond_str)
                    lines.append(f"{backend.indent * env_depth}{cond_line}")
                    env_depth += 1
                else:
                    cond_line, env_close = backend.translate_condition(env_condition)
                    lines.append(f"{backend.indent * env_depth}{cond_line}")
                    env_depth += 1

            if env_type == "alias":
                lines.append(backend.alias_line(key, value, env_depth))
            elif env_type == "eval":
                lines.append(backend.eval_line(value, env_depth))
            elif env_type == "source":
                lines.append(backend.source_line(value, env_depth))
            elif env_type == "local":
                lines.append(backend.local_line(key, value, env_depth))
            elif "\n" in value or "{{" in value:
                parts = value.split("\n")
                lines.append(backend.export_line(key, parts[0], env_depth, quote))
                for part in parts[1:]:
                    lines.append(part)
            else:
                lines.append(backend.export_line(key, value, env_depth, quote))

            if env_close:
                lines.append(f"{backend.indent * (env_depth - 1)}{env_close}")

        if block_close:
            lines.append(block_close)

        lines.append("")

    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--shell", choices=["bash", "zsh", "fish", "ps1", "all"], default="bash"
    )
    parser.add_argument("--output", type=Path)
    parser.add_argument("--input", type=Path, default=Path("env.json"))
    args = parser.parse_args()

    with open(args.input) as f:
        env_data = json.load(f)

    if args.shell == "all":
        for shell in ["bash", "zsh", "fish", "ps1"]:
            output_path = args.output or Path(f".chezmoitemplates/env.{shell}")
            content = render(env_data, BACKENDS[shell], shell)
            # Post-process for PowerShell to convert env var references
            if shell == "ps1":
                content = postprocess_ps1(content)
            with open(output_path, "w") as f:
                f.write(content)
            print(f"Written: {output_path}")
    else:
        content = render(env_data, BACKENDS[args.shell], args.shell)
        # Post-process for PowerShell to convert env var references
        if args.shell == "ps1":
            content = postprocess_ps1(content)
        if args.output:
            with open(args.output, "w") as f:
                f.write(content)
            print(f"Written: {args.output}")
        else:
            print(content)


if __name__ == "__main__":
    main()
