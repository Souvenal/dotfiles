# Existing Project: CMake (Brownfield)

Enter existing C++ codebase, build system **typically CMake**. Work within existing CMake setup, follow conventions below.

## CMake Conventions

### Modern vs Legacy Style

- **Existing targets**: keep current style (legacy or modern).
- **New or modified targets**: use modern target-based:
  - `target_compile_features()` / `target_compile_options()`
  - `target_include_directories()`
  - `target_link_libraries()` with `PRIVATE` / `PUBLIC` / `INTERFACE`
  - `add_library()` / `add_executable()` with explicit source lists
- **If user asks to modernize**: full refactor to target-based.

### Generator Preference

| Platform | Generator |
|---|---|
| Windows | `Visual Studio 18 2026` |
| Non-Windows | `Ninja Multi-Config` |

Build with explicit config:
```
cmake --build build --config Release
```

Respect project's existing generator (e.g., `CMakePresets.json`). Only override when user asks or no generator specified.

### Preset Policy

- Don't create `CMakePresets.json` or `CMakeUserPresets.json` for existing projects.
- If project has presets, review them. Use if fit task without conflict.
- Don't commit new presets.

### Build Directory

- Use single `build/` for out-of-source builds.
- Respect project's existing dir naming if different.

### Dependency Management

CMake only for existing projects. Adding new deps is rare.
- If new dep must add: follow project's existing mechanism (`find_package`, `FetchContent`, or `CPM`).
- Don't introduce new dep management style to existing project.

### Compiler Warnings

- Don't add/modify warning flags in existing CMake projects.
- Use project's existing warning config as-is.

## Command Reference

| Task | Command |
|---|---|
| Configure | `cmake -B build -S . -DCMAKE_POLICY_VERSION_MINIMUM=3.12` |
| Configure with preset | `cmake --preset <name>` |
| Build | `cmake --build build` |
| Build specific target | `cmake --build build --target <target>` |
| Build parallel | `cmake --build build -j$(nproc)` |
| Run tests | `ctest --test-dir build` |
| Install | `cmake --install build --prefix <prefix>` |
| Clean | `cmake --build build --target clean` |
| Reconfigure | `cmake -B build -S . --fresh` |