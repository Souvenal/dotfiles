#!/usr/bin/env bash
set -euo pipefail

echo "HINT: Must turn off all running dsh processes !!!"
npm i -g "@deepseek-ai/dsh@next"
dsh plugin --profile web update --latest

# Use re-add instead of add: it syncs contents of already-managed files while
# preserving source attributes. `chezmoi add` re-derives attributes from the
# file, which on Windows (no POSIX modes) drops the private attribute of
# entries like private_dot_dsh/private_settings.yaml and blocks on an
# interactive "would remove private attribute" prompt.
# Note: re-add silently ignores not-yet-managed targets — for a brand-new
# file, run `chezmoi add <file>` once (and `chezmoi chattr +private` on it
# afterwards if it should stay private on Windows).
chezmoi re-add \
  ~/.dsh/.agent-presets \
  ~/.dsh/profiles/web/cordis.patch.yml \
  ~/.dsh/profiles/web/package.json \
  ~/.dsh/profiles/web/pnpm-lock.yaml \
  ~/.dsh/profiles/web/pnpm-workspace.yaml

# api keys: re-add preserves the existing encrypted_ and private_ attributes.
chezmoi re-add ~/.dsh/.credentials.yaml

echo "Syncing dsh settings and profiles to chezmoi [COMPLETED]"
