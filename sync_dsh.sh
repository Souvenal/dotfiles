# update
npx -y @deepseek-ai/dsh plugin --profile web update

chezmoi add ~/.dsh/settings.yaml
chezmoi add ~/.dsh/.agent-presets
chezmoi add ~/.dsh/profiles/web/cordis.patch.yml
chezmoi add ~/.dsh/profiles/web/package.json
chezmoi add ~/.dsh/profiles/web/pnpm-lock.yaml
chezmoi add ~/.dsh/profiles/web/pnpm-workspace.yaml

# api keys
chezmoi add --encrypt ~/.dsh/.credentials.yaml

echo "Syncing dsh settings and profiles to chezmoi [COMPLETED]"