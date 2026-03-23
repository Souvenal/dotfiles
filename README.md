# My solution for dotfiles management

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