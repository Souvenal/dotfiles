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
# Render specific shell for specific OS
python generate_env.py --shell bash --os linux

# Render all shells for all OSes (Cartesian product)
python generate_env.py --shell all

# Render to custom output
python generate_env.py --shell fish --os darwin --output .chezmoitemplates/env.fish-darwin.tmpl
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
- Lacks a way to symlink a entire directory (due to chezmoi pitfalls).
- **Starship `git_status` disabled on Windows.** In repos with Git LFS, Starship's `git_status` module spawns `git status` on every prompt render, which repeatedly launches `git-lfs filter-process`. On Windows, ConPTY/anonymous pipe handle inheritance during the pkt-line handshake causes `write /dev/stdout: The pipe is being closed.` (ERROR_NO_DATA). This is a Windows pipe compatibility issue between Git LFS and non-TTY subprocesses, not a Starship bug. Workaround: `git_status` is disabled on Windows; `git_branch` remains functional. See [git-lfs/git-lfs#4247](https://github.com/git-lfs/git-lfs/issues/4247).