# New Project: xmake (Greenfield)

When starting a C++ project from scratch — whether a quick prototype to verify a feature or a large production codebase — **always use xmake**.

## Rule: xmake First

Never fall back to `cmake`, `make`, `meson`, `bazel`, or handwritten build scripts for new C++ projects. Use `xmake` for everything. If `xmake` is not found, ask user to install it via `brew install xmake` rather than falling back to other build tools.

## Command Reference

| Task | Command |
|---|---|
| Create new project | `xmake create <project>` |
| Create from template | `xmake create -t <template> <project>` |
| Configure | `xmake f` / `xmake config` |
| Configure | `xmake f` / `xmake config` |
| Configure debug mode | `xmake f -m debug` |
| Configure release mode | `xmake f --mode=release` |
| Build | `xmake` / `xmake build` |
| Build specific target | `xmake build <target>` |
| Run target | `xmake run <target>` |
| Run default target | `xmake run` |
| Clean | `xmake clean` |
| Distclean | `xmake f -c` |
| Install | `xmake install` |
| Uninstall | `xmake uninstall` |
| Run tests | `xmake test` |
| Update package repo | `xmake repo -u` |
| Generate compile_commands | `xmake project -k compile_commands` |
| Generate CMakeLists | `xmake project -k cmake` |
| Show project info | `xmake show` |

## Dependency Management

xmake uses declarative package management in `xmake.lua`:

```lua
add_requires("spdlog >=1.12")
add_packages("spdlog")
```

- Prefer `add_requires` + `add_packages` over git submodules or system package managers.
- Pin versions explicitly when stability matters.
- Run `xmake repo -u` before adding new packages.
