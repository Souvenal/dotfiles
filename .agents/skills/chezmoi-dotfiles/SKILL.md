---
name: chezmoi-dotfiles
description: Use when managing dotfiles with chezmoi, adding interactive prompts with promptStringOnce/promptChoiceOnce/promptBoolOnce, extending data templates, or improving shell configuration templates.
---

# Chezmoi Dotfiles — Writing Guide

**Project architecture**: See `AGENTS.md` for this repo's data structure and conventions. This skill focuses on patterns and techniques.

**Template syntax**: Go `text/template` + sprig functions. Complete function list: https://www.chezmoi.io/reference/templates/init-functions/. **When unsure, use `use context7`.**

## Prompt Functions

All prompts follow the pattern: `promptXXXOnce . "data.path" "message" [default]`

| Function | Signature | Use When |
|----------|-----------|----------|
| `promptStringOnce` | `. "path" "msg" [default]` | Free-form text |
| `promptChoiceOnce` | `. "path" "msg" (list "a" "b") [default]` | Single choice |
| `promptMultichoiceOnce` | `. "path" "msg" (list "a" "b") (list "a")` | Multiple choices |
| `promptBoolOnce` | `. "path" "msg"` | Yes/no |
| `promptIntOnce` | `. "path" "msg"` | Integer |

**Example — string with default:**
```go
{{- $email := promptStringOnce . "personal.email" "Email address" "me@example.com" -}}
```

**Example — choice from list:**
```go
{{- $loc := promptChoiceOnce . "personal.location" "Location" (list "nju" "home" "unity-cn") "home" -}}
```

**Example — multi-select with defaults:**
```go
{{- $plugins := promptMultichoiceOnce . "zsh.plugins" "Select plugins" (list "git" "docker" "python") (list "git") -}}
```

**Example — optional config (leave empty to skip):**
```go
{{- $vulkan := promptStringOnce . "lib.vulkan_sdk_version" "Vulkan SDK version (leave empty to skip)" "" -}}
{{- if $vulkan }}
[data.lib]
    vulkan_sdk_version = {{ $vulkan | quote }}
{{- end }}
```

## Template Patterns

### Conditional based on OS / hostname / arch

```go
{{- if eq .chezmoi.os "darwin" }}
    # macOS-specific
{{- else if eq .chezmoi.os "linux" }}
    # Linux-specific
{{- end }}

{{- if eq .chezmoi.hostname "server-01" }}
    # host-specific
{{- end }}
```

### OS-Specific Config with Per-OS Choices

When a config key needs different options per OS, use the `*_choices` + `*_default` + `promptChoiceOnce` pattern. This allows flexible per-OS toolchains across machines.

**Canonical pattern (C/C++ compiler selection):**
```go
[data.language.cpp]
{{- $cc_choices := list "" }}
{{- $cc_default := "" }}
{{- $cxx_choices := list "" }}
{{- $cxx_default := "" }}
{{- if eq .chezmoi.os "linux" }}
    {{- $cc_choices = list "/usr/bin/gcc" }}
    {{- $cc_default = "/usr/bin/gcc" }}
    {{- $cxx_choices = list "/usr/bin/g++" }}
    {{- $cxx_default = "/usr/bin/g++" }}
{{- else if eq .chezmoi.os "darwin" }}
    {{- $cc_choices = list "/usr/bin/clang" "/usr/local/bin/clang" }}
    {{- $cc_default = "/usr/local/bin/clang" }}
    {{- $cxx_choices = list "/usr/bin/clang++" "/usr/local/bin/clang++" }}
    {{- $cxx_default = "/usr/local/bin/clang++" }}
{{- else if eq .chezmoi.os "windows" }}
    {{- $cc_choices = list "" }}
    {{- $cc_default = "" }}
    {{- $cxx_choices = list "" }}
    {{- $cxx_default = "" }}
{{- end }}
{{- $cc := promptChoiceOnce . "language.cpp.cc" "C compiler" $cc_choices $cc_default }}
{{- $cxx := promptChoiceOnce . "language.cpp.cxx" "C++ compiler" $cxx_choices $cxx_default }}
    cc = {{ $cc | quote }}
    cxx = {{ $cxx | quote }}
```

**Pattern rules:**
1. Initialize all `*_choices` and `*_default` to `list ""` / `""` (empty-safe defaults)
2. Each OS branch overrides only its own choices/defaults
3. Use `promptChoiceOnce` once per key, passing OS-specific choices/defaults
4. If an OS has only one option, use `list "only-option"` — empty string `list ""` works but forces an empty default

**When to use this pattern:**
- Config values differ per OS (compilers, SDKs, tools)
- Each OS has a fixed set of valid options
- Machine may migrate between OSes; chezmoi data persists per machine

### Multi-shell env template

`.chezmoitemplates/env.bash`:
```bash
export EDITOR="{{ .app.editor }}"
```

Source in shell rc:
```bash
source $(chezmoi source-path)/.chezmoitemplates/env.bash
```

## Adding a New Config Section

**Step 1** — Add prompt(s) to `.chezmoi.toml.tmpl`:
```go
{{- $enabled := promptBoolOnce . "features.tmux" "Enable tmux?" -}}
```

**Step 2** — Create the template file, e.g. `dot_tmux.conf.tmpl`:
```tmux
{{- if .features.tmux }}
set -g prefix C-a
{{- end }}
```

**Step 3** — Test without applying:
```bash
chezmoi execute-template --init < ~/.local/share/chezmoi/.chezmoi.toml.tmpl
chezmoi execute-template --init --promptString personal.email=me@host.org < ~/.local/share/chezmoi/.chezmoi.toml.tmpl
```

## Common Mistakes

1. **Missing leading `.`**: `promptStringOnce . "path" "msg"` — the dot is the data context
2. **Using `=` instead of `==`**: template comparison is `eq`, not `==`
3. **Forgetting `-` in directives**: `{{- ` trims preceding whitespace; ` -}}` trims trailing

## Data Access

```go
{{ .chezmoi.os }}           # darwin / linux / windows
{{ .chezmoi.hostname }}     # machine hostname
{{ .chezmoi.username }}     # current user
{{ .chezmoi.arch }}         # amd64 / arm64
{{ .data.category.key }}    # any [data.xxx] value
```
