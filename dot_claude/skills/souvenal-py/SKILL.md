---
name: souvenal-py
description: >
  ALWAYS invoke this skill when the user asks about Python development,
  writing Python code, creating new Python projects, verifying Python functionality,
  running Python programs, or mentions .py, pyproject.toml, uv, pip, ruff,
  pytest, venv, virtualenv, Python 3.10, Python 3.11, Python 3.12, Python 3.13,
  install, requirements, or test Python code.

  Provides standardized Python project structure, build configuration,
  coding style guidelines, and best practices for personal practice.

  Do NOT write Python code or create Python projects directly — use this skill first.
---

# Souvenal Python Skill

Souvenal's Python development preferences. Read relevant sub-file based on task.

## Quick Reference

| Topic | File | Status |
|---|---|---|
| Toolchain & build system | [toolchain.md](toolchain.md) | Ready |
| Code style & formatting | [style.md](style.md) | Placeholder |
| Language version & standards | [standards.md](standards.md) | Placeholder |

## Usage

When task involves Python:

1. Match against Trigger Keywords table above.
2. Read only the relevant sub-file(s).
3. If topic marked "Placeholder", ask user before assuming.

## Extending This Skill

1. Create file in this dir.
2. Add row to Quick Reference + Trigger Keywords tables in `SKILL.md`.
3. Keep each file under 200 lines; split if larger.