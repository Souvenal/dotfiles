# My solution for dotfiles management

## Design Philosophy

**Multi-machine migration with per-OS toolchains.**

Same config key (e.g., C++ compiler) may need different values on different OSes. Each OS gets its own list of valid options; the cached `chezmoi.toml` stores per-machine selections so prompts only ask when there are real choices.

## Dependency

- bitwarden-cli: access bitwarden password manager
- chezmoi: a cross-platform tool for managing dotfiles and personal configuration
- gpg: register gpg private keys (gpg is packed with git on Windows, /path/to/Git/usr/bin should be added to PATH)
- jq: command-line tool for processing JSON data
- python3: for running generate_env.py

Install chezmoi according to [chezmoi page](https://www.chezmoi.io/install/).

## Usage

1. Init the chezmoi system.

    ```shell
    chezmoi init https://github.com/Souvenal/dotfiles.git
    ```

2. Apply the chezmoi configuration.

    ```shell
    chezmoi apply
    ```

3. Edit environment variables.

    Environment variables are centralized in `env.json`. After editing:

    ```shell
    python generate_env.py --shell all  # regenerate all shell templates
    ```

## Environment Variables

The `env.json` file contains all environment variable configuration. It is rendered by `generate_env.py` into shell-specific templates in `.chezmoitemplates/`.

```shell
# Render specific shell
python generate_env.py --shell bash

# Render all shells
python generate_env.py --shell all

# Render to custom output
python generate_env.py --shell fish --output .chezmoitemplates/env.fish
```

Each block in `env.json` can have:
- `comment`: array of comment lines
- `condition`: shell if-condition (e.g., `[ -x "$(which brew)" ]`) or chezmoi template
- `shell`: list of target shells (e.g., `["bash"]`, `["zsh"]`), or `"all"` (default). The block is only rendered for matching shells.
- `env`: array of environment variables, each with `key`, `value`, optional `type` (export/alias/eval/source/local), and optional `condition`

## Zsh Setup

If using zsh, add to `/etc/zshenv` (or the equivalent for your system):

```shell
export ZDOTDIR="$HOME"/.config/zsh
```

This ensures zsh reads configs from `$XDG_CONFIG_HOME/zsh` instead of `$HOME`.

## Issues

- Bitwarden is not supported yet on Windows.
- Compound conditions (e.g., `&&`, `||`, `!`) in `env.json` are not supported yet.
- Skills management is not supported yet.