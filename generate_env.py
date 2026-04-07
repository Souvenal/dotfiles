#!/usr/bin/env python3
import json
import argparse
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
    close_block: str
    close_template: str


def translate_bash_condition(cond: str, is_chezmoi: bool) -> tuple:
    if is_chezmoi:
        return cond, "{{- end -}}"
    return f"if {cond}; then", "fi"


def translate_fish_condition(cond: str, is_chezmoi: bool) -> tuple:
    if is_chezmoi:
        c = (cond
            .replace("{{- if eq .chezmoi.os \"darwin\" -}}", "if test (uname) = Darwin")
            .replace("{{- else if eq .chezmoi.os \"linux\" -}}", "else if test (uname) = Linux")
            .replace("{{- else -}}", "else")
            .replace("{{- end -}}", "end"))
        return c, "end"
    c = (cond
        .replace("[ -x", "test -x")
        .replace("]", "")
        .replace("[ -n", "test -n")
        .replace("[ -d", "test -d")
        .replace("[ -f", "test -f"))
    return f"if {c}", "end"


def translate_ps1_condition(cond: str, is_chezmoi: bool) -> tuple:
    if is_chezmoi:
        c = (cond
            .replace("{{- if eq .chezmoi.os \"darwin\" -}}", "if ($IsMacOS) {")
            .replace("{{- else if eq .chezmoi.os \"linux\" -}}", "} elseif ($IsLinux) {")
            .replace("{{- else -}}", "} else {")
            .replace("{{- end -}}", "}"))
        return c, "}"
    c = cond.replace("[ -x", "Test-Path").replace("]", "")
    return f"if {c} {{", "}"


def make_export_line(indent_fn: Callable, quote_fn: Callable):
    def f(key: str, value: str, depth: int, quote: str = '"') -> str:
        if quote == '"' and '"' in value:
            value = value.replace('\\', '\\\\').replace('"', '\\"')
            return f"{indent_fn(depth)}export {key}=\"{value}\""
        elif quote == "'" and "'" in value:
            value = value.replace("'", "'\\''")
            return f"{indent_fn(depth)}export {key}='{value}'"
        return f"{indent_fn(depth)}export {key}={quote_fn(quote)}{value}{quote_fn(quote)}"
    return f


def escape_value(value: str, quote: str) -> str:
    if quote == '"' and '"' in value:
        return value.replace('\\', '\\\\').replace('"', '\\"')
    elif quote == "'" and "'" in value:
        return value.replace("'", "'\\''")
    return value


BACKENDS = {
    "bash": ShellBackend(
        name="bash",
        indent="    ",
        export_line=lambda k, v, d, q='"': f"{'    ' * d}export {k}=\"{escape_value(v, q)}\"",
        local_line=lambda k, v, d: f"{'    ' * d}{k}={v}",
        alias_line=lambda k, v, d: f"{'    ' * d}alias {k}='{v}'",
        eval_line=lambda v, d: f"{'    ' * d}eval \"{v}\"",
        source_line=lambda v, d: f"{'    ' * d}{v}",
        translate_condition=translate_bash_condition,
        close_block="fi",
        close_template="{{- end -}}",
        mkdir_line=lambda v, d: f"{'    ' * d}if [ ! -d \"{v}\" ]; then mkdir -p \"{v}\"; fi",
    ),
    "zsh": ShellBackend(
        name="zsh",
        indent="    ",
        export_line=lambda k, v, d, q='"': f"{'    ' * d}export {k}=\"{escape_value(v, q)}\"",
        local_line=lambda k, v, d: f"{'    ' * d}{k}={v}",
        alias_line=lambda k, v, d: f"{'    ' * d}alias {k}='{v}'",
        eval_line=lambda v, d: f"{'    ' * d}eval \"{v}\"",
        source_line=lambda v, d: f"{'    ' * d}{v}",
        translate_condition=translate_bash_condition,
        close_block="fi",
        close_template="{{- end -}}",
        mkdir_line=lambda v, d: f"{'    ' * d}if [ ! -d \"{v}\" ]; then mkdir -p \"{v}\"; fi",
    ),
    "fish": ShellBackend(
        name="fish",
        indent="    ",
        export_line=lambda k, v, d, q='"': f"{'    ' * d}set -gx {k} \"{escape_value(v, q)}\"",
        local_line=lambda k, v, d: f"{'    ' * d}set {k} {v}",
        alias_line=lambda k, v, d: f"{'    ' * d}alias {k} '{v}'",
        eval_line=lambda v, d: f"{'    ' * d}eval \"{v}\"",
        source_line=lambda v, d: f"{'    ' * d}{v}",
        translate_condition=translate_fish_condition,
        close_block="end",
        close_template="{{- end -}}",
        mkdir_line=lambda v, d: f"{'    ' * d}if not test -d \"{v}\"; mkdir -p \"{v}\"; end",
    ),
    "ps1": ShellBackend(
        name="ps1",
        indent="    ",
        export_line=lambda k, v, d, q='"': f"{'    ' * d}$env:{k} = \"{escape_value(v, q)}\"",
        local_line=lambda k, v, d: f"{'    ' * d}${k} = \"{v}\"",
        alias_line=lambda k, v, d: f"{'    ' * d}Set-Alias {k} '{v}'",
        eval_line=lambda v, d: f"{'    ' * d}Invoke-Expression \"{v}\"",
        source_line=lambda v, d: f"{'    ' * d}. {v}",
        translate_condition=translate_ps1_condition,
        close_block="}",
        close_template="{{- end -}}",
        mkdir_line=lambda v, d: f"{'    ' * d}if (-not (Test-Path \"{v}\")) {{ New-Item -ItemType Directory -Path \"{v}\" -Force }}",
    ),
}


def is_chezmoi_template(condition: str) -> bool:
    return condition.strip().startswith("{{")


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
            is_tpl = is_chezmoi_template(condition)
            cond_line, block_close = backend.translate_condition(condition, is_tpl)
            lines.append(cond_line)
            if not is_tpl:
                block_depth = 1

        for env in env_vars:
            key = env.get("key", "")
            value = env.get("value", "").replace("\\n", "\n")
            env_condition = env.get("condition")
            env_type = env.get("type", "export")
            quote = env.get("quote", '"')

            env_depth = block_depth
            env_close = None

            if env_condition:
                is_tpl = is_chezmoi_template(env_condition)
                cond_line, env_close = backend.translate_condition(env_condition, is_tpl)
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
                lines.append(f"{backend.indent * env_depth}export {key}={parts[0]}")
                for part in parts[1:]:
                    lines.append(part)
            else:
                lines.append(backend.export_line(key, value, env_depth, quote))

            if env_close:
                lines.append(f"{backend.indent * (env_depth - 1)}{env_close}")

        if block_close:
            lines.append(block_close)

        if condition and is_chezmoi_template(condition):
            lines.append(backend.close_template)

        lines.append("")

    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--shell", choices=["bash", "zsh", "fish", "ps1", "all"], default="bash")
    parser.add_argument("--output", type=Path)
    parser.add_argument("--input", type=Path, default=Path("env.json"))
    args = parser.parse_args()

    with open(args.input) as f:
        env_data = json.load(f)

    if args.shell == "all":
        for shell in ["bash", "zsh", "fish", "ps1"]:
            output_path = args.output or Path(f".chezmoitemplates/env.{shell}")
            content = render(env_data, BACKENDS[shell], shell)
            with open(output_path, "w") as f:
                f.write(content)
            print(f"Written: {output_path}")
    else:
        content = render(env_data, BACKENDS[args.shell], args.shell)
        if args.output:
            with open(args.output, "w") as f:
                f.write(content)
            print(f"Written: {args.output}")
        else:
            print(content)


if __name__ == "__main__":
    main()
