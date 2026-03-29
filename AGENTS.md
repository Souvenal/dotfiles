# Dotfiles — Project Architecture

## Overview

This repo is managed by [chezmoi](https://www.chezmoi.io/) to maintain dotfiles and personal configuration across machines. The chezmoi source is at `~/.local/share/chezmoi/`.

## Design Philosophy

**Multi-machine migration with per-OS toolchains.**

Work happens across multiple devices — a lab Linux machine, a macOS work machine, a Windows VM, a home desktop. Each OS has its own ecosystem of compilers, SDKs, and tools. The same config key (e.g., `cc`) may need different values on different OSes.

The guiding principle: **OS-specific defaults, machine-specific choices.**

- Each OS gets its own list of valid options and a sensible default
- On init/migration, `promptChoiceOnce` asks only when there are real choices (not for single-option OSes)
- The cached `chezmoi.toml` stores per-machine selections — no need to re-answer on every apply
- Extending support for a new OS means adding one `if eq .chezmoi.os "..."` branch, nothing else

**Canonical example:** `[data.language.cpp]` — Linux uses gcc, macOS offers /usr/bin/clang vs /usr/local/bin/clang (brew LLVM), Windows leaves empty. Each compiler choice is independent (cc and cxx have separate choices).

## Data Structure

`.chezmoi.toml.tmpl` organizes all configuration under `[data.<category>]`:

| Category | Contents | Examples |
|----------|----------|----------|
| `data.app` | Application settings | homebrew mirrors, conda mirrors, editor |
| `data.language` | Language toolchains | C++ compiler paths, CMake generator |
| `data.lib` | SDK / library paths | Vulkan SDK, LLVM, dev SDK root |
| `data.personal` | User identity | name, email, location |
| `data.proxy` | Network proxy | http/https proxy URLs |
| `data.public_keys` | SSH/GPG keys | GPG key ID |
| `data.system` | OS-level paths | XDG base directories |
| `data.features` | Feature flags | tmux, GPG agent, etc. |
| `data.validation` | Validation settings | warn on empty prompts |

## Key Files

| File | Purpose |
|------|---------|
| `.chezmoi.toml.tmpl` | Main config with all `[data]` sections + prompts |
| `.chezmoitemplates/` | Reusable shell env templates (env.bash, env.fish) |
| `dot_bashrc.tmpl` | bashrc managed by chezmoi |
| `dot_zshrc.tmpl` | zshrc managed by chezmoi |
| `dot_bash_profile.tmpl` | bash profile |
| `dot_zprofile.tmpl` | zsh profile |
| `external/` | External repos as git subtrees |
| `private_*` | Private configs (file permissions set to 0o600/0o700, but still version controlled) |
| `run_after_apply.ps1.tmpl` | PowerShell post-apply script |
| `run_before_validate.sh.tmpl` | Pre-validation shell script |
| `run_once_install-gpg-key.sh.tmpl` | One-time GPG key import |

## Host Types

`personal.location` determines the machine context:

| Value | Meaning |
|-------|---------|
| `nju` | NJU lab machine |
| `unity-cn` | Unity China work machine |
| `home` | Personal/home machine |

## Conventions

- **Prompts**: Use `promptXXXOnce` variants only (no base `promptString`/`promptBool`). The "Once" variants persist values across runs.
- **System detection**: Use `.chezmoi.os` (darwin/linux/windows) and `.chezmoi.hostname` for conditionals.
- **Optional features**: Check for empty string `if $value` before writing optional `[data]` blocks.
- **Shell templates**: Multi-shell support via `.chezmoitemplates/` sourced in shell rc files.
- **Secret handling**: GPG keys and passwords are NOT stored in chezmoi — they reference `bitwarden-cli` or require manual import.
- **Private configs**: `private_` prefix removes all group/world permissions (0o600 for files, 0o700 for dirs) when applied — files are still version controlled.

## Dependency

- chezmoi
- bitwarden-cli (for password manager integration)
- gpg (for GPG key management)
- jq (for JSON processing)

## Init / Apply

```shell
# First time
chezmoi init https://github.com/Souvenal/dotfiles.git

# Apply changes
chezmoi apply

# Edit config
chezmoi cd  # drops you in ~/.local/share/chezmoi

# Test templates without applying
chezmoi execute-template --init < .chezmoi.toml.tmpl
```
