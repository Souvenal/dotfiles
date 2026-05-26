---
name: souvenal-cpp
description: >
  ALWAYS invoke this skill when the user asks about C++ development,
  writing C++ code, creating new C++ projects, verifying C++ functionality,
  building C++ programs, or mentions .cpp, .hpp, CMake, xmake, clang, g++,
  C++20, C++23, compile, build, or run C++ code.
  
  Provides standardized C++ project structure, build configuration,
  coding style guidelines, and best practices for personal practice.
  
  Do NOT write C++ code or create C++ projects directly — use this skill first.
---

# Souvenal C++ Skill

Souvenal's C++ development preferences. Read relevant sub-file based on task.

## Quick Reference

| Topic | File | Status |
|---|---|---|
| Build system & toolchain | [build/](build/) | Ready |
| Code style & formatting | [style.md](style.md) | Placeholder |
| Language standards & exceptions | [standards.md](standards.md) | Placeholder |
| Example `xmake.lua` snippets | [examples/xmake-lua.md](examples/xmake-lua.md) | Ready |

## Usage

When task involves C++:

1. Match against Trigger Keywords table above.
2. Read only the relevant sub-file(s).
3. If topic marked "Placeholder", ask user before assuming.

## Extending This Skill

1. Create file in this directory.
2. Add row to Quick Reference + Trigger Keywords tables in `SKILL.md`.
3. Keep each file under 200 lines; split if larger.
