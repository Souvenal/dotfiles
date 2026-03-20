# My solution for dotfiles management

## Dependency

- chezmoi: a cross-platform tool for managing dotfiles and personal configuration
- jq: command-line tool for processing JSON data

1. Install chezmoi according to [chezmoi page](https://www.chezmoi.io/install/).
2. Install jq via package manager.

## Usage

1. Init the chezmoi system.

    ```shell
    chezmoi init https://github.com/Souvenal/dotfiles.git
    ```
2. Copy the default config file to the config directory.

    ```shell
    cp ~/.local/share/chezmoi/chezmoi.template.toml ~/.config/chezmoi/chezmoi.toml
    ```
3. Manually specify some blank values or change some default values
4. Apply the chezmoi configuration.

    ```shell
    chezmoi apply
    ```

## Issues

- Windows pwsh is not yet supported.
- Fish support is incomplete.
- A meta build system for injecting environment variables into different shell profiles (bash, zsh, fish, etc.) is yet missing.