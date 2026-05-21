---
description: use uv instead of pip/venv for all Python workflows
---

# Use `uv` as the Default Python Toolchain

---

Never fall back to `pip install`, `source .venv/bin/activate`, `python -m venv`. Use `uv` for everything. If `uv` is not found, ask user to install it via their package manager rather than falling back to pip.

## Commands

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
