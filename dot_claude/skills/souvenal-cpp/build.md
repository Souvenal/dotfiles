# C++ Build Preferences

Two distinct scenarios with different toolchains.

## Scenes

| Scenario | Tool | File |
|---|---|---|
| New project (prototype or production) | xmake | [build/xmake.md](build/xmake.md) |
| Existing codebase | CMake | [build/cmake.md](build/cmake.md) |

## Decision Flow

```
Does CMakeLists.txt already exist?
├── Yes  -> Use CMake, see [build/cmake.md](build/cmake.md)
└── No   -> Use xmake, see [build/xmake.md](build/xmake.md)
```
