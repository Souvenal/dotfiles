# My solution for dotfiles management

## Design Philosophy

**Multi-machine migration with per-OS toolchains.**

Same config key (e.g., C++ compiler) may need different values on different OSes. Each OS gets its own list of valid options; the cached `chezmoi.toml` stores per-machine selections so prompts only ask when there are real choices.

## Dependency

- bitwarden-cli: access bitwarden password manager
- chezmoi: a cross-platform tool for managing dotfiles and personal configuration
- gpg: register gpg private keys
- jq: command-line tool for processing JSON data

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

## Issues

- Windows pwsh is not yet supported.
- Fish support is incomplete.
- A meta build system for injecting environment variables into different shell profiles (bash, zsh, fish, etc.) is yet missing.