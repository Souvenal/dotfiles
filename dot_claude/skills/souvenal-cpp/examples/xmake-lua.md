# xmake.lua Examples

## Minimal Executable

```lua
set_project("myapp")
set_version("0.1.0")
set_languages("c++20")

add_rules("mode.debug", "mode.release")

target("myapp")
    set_kind("binary")
    add_files("src/*.cpp")
    add_includedirs("include")
```

## With External Dependencies

```lua
set_project("mylib")
set_version("1.0.0")
set_languages("c++20")

add_rules("mode.debug", "mode.release")

add_requires("spdlog >=1.12", "fmt >=10.0")

target("mylib")
    set_kind("static")
    add_files("src/*.cpp")
    add_packages("spdlog", "fmt")
    add_includedirs("include", {public = true})

target("mylib_tests")
    set_kind("binary")
    add_files("tests/*.cpp")
    add_deps("mylib")
    add_packages("spdlog", "fmt")
```

## Multi-Directory Project

```lua
-- xmake.lua (root)
set_project("bigproject")
set_version("2.0.0")
set_languages("c++23")

add_rules("mode.debug", "mode.release")

includes("engine")
includes("app")
includes("tests")
```

```lua
-- engine/xmake.lua
target("engine")
    set_kind("static")
    add_files("src/*.cpp")
    add_includedirs("include", {public = true})
```

```lua
-- app/xmake.lua
target("app")
    set_kind("binary")
    add_files("src/*.cpp")
    add_deps("engine")
```
