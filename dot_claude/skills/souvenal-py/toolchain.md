# Python Toolchain: `uv` First

Use `uv` as default Python toolchain — never fall back to `pip`, `venv`, `pipenv`, `poetry`, or `conda` for package/dependency management.

## Rule: uv First

Never fall back to `pip install`, `source .venv/bin/activate`, `python -m venv`. Use `uv` for everything.

If `uv` not found, ask user install via pkg mgr (`brew install uv`, `curl -LsSf https://astral.sh/uv/install.sh`) rather than falling back to pip.

## Command Reference

| Task | Command |
|---|---|
| Add dependency | `uv add <package>` |
| Add dev dependency | `uv add --dev <package>` |
| Remove dependency | `uv remove <package>` |
| Sync project | `uv sync` |
| Update lockfile | `uv lock` |
| Run script/command | `uv run <script-or-cmd>` |
| Run tool once | `uvx <tool>` |
| Install tool globally | `uv tool install <tool>` |
| Install Python version | `uv python install <version>` |
| Pin Python version | `uv python pin <version>` |

## Dependency Management

- Declare deps in `pyproject.toml` — `uv` reads/updates natively.
- Pin versions explicitly for prod deps; loose ranges for dev-only.
- Run `uv lock` after add/remove to keep `uv.lock` in sync.
- `uv sync` installs from existing `uv.lock` (faster + deterministic than `pip install -r requirements.txt`).

## Project Initialization

| Task | Command |
|---|---|
| New project | `uv init <project>` |
| New app package | `uv init --app <project>` |
| New library package | `uv init --lib <project>` |
| Create virtualenv only | `uv venv` |