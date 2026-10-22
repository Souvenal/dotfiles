#!/usr/bin/env bash
set -euo pipefail

echo "HINT: Must turn off all running dsh processes !!!"
npm i -g "@deepseek-ai/dsh@next"
dsh plugin --profile web update --latest

# dsh may preserve an imported settings file during a migration instead of
# leaving ~/.dsh/settings.yaml in place. Restore the expected path before
# syncing it to chezmoi.
if [[ ! -e "$HOME/.dsh/settings.yaml" && -e "$HOME/.dsh/settings.yaml.imported" ]]; then
  cp "$HOME/.dsh/settings.yaml.imported" "$HOME/.dsh/settings.yaml"
  chmod 600 "$HOME/.dsh/settings.yaml"
fi

chezmoi add ~/.dsh/settings.yaml
chezmoi add ~/.dsh/.agent-presets
chezmoi add ~/.dsh/profiles/web/cordis.patch.yml
chezmoi add ~/.dsh/profiles/web/package.json
chezmoi add ~/.dsh/profiles/web/pnpm-lock.yaml
chezmoi add ~/.dsh/profiles/web/pnpm-workspace.yaml

# api keys
chezmoi add --encrypt ~/.dsh/.credentials.yaml

echo "Syncing dsh settings and profiles to chezmoi [COMPLETED]"
