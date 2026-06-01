# Python Toolchain: `uv` Only — No `pip`/`pip3`

Use `uv` as the **sole** Python package manager. `pip` and `pip3` commands are **forbidden** — never use them, even as fallback.

## Rule: uv Only

- **Never** run `pip install`, `pip3 install`, `pip list`, `pip freeze`, `pip uninstall`, or any other `pip`/`pip3` subcommand.
- **Never** run `python -m venv`, `source .venv/bin/activate`, `virtualenv`.
- For everything related to package/dependency management, use `uv` exclusively.

If `uv` not found, ask user to install via their package manager (`brew install uv`, `curl -LsSf https://astral.sh/uv/install.sh`) and stop — do not fall back to `pip`.

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