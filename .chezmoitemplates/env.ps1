# check https://wiki.archlinux.org.cn/title/XDG_Base_Directory for all software support
# XDG Base Directory
$env:XDG_CACHE_HOME = "$HOME/.cache"
$env:XDG_CONFIG_HOME = "$HOME/.config"
$env:XDG_DATA_HOME = "$HOME/.local/share"
$env:XDG_STATE_HOME = "$HOME/.local/state"

# Network proxy config
# Use both upper and lower cases for compatibility
$env:http_proxy = "{{ .network.http_proxy }}"
$env:HTTP_PROXY = "$env:http_proxy"
$env:https_proxy = "{{ .network.https_proxy }}"
$env:HTTPS_PROXY = "$env:https_proxy"
$env:no_proxy = "{{ .network.no_proxy }}"
$env:NO_PROXY = "$env:no_proxy"

# npm
$env:NPM_CONFIG_USERCONFIG = "$env:XDG_CONFIG_HOME/npm/npmrc"
$env:PATH = "$env:XDG_DATA_HOME/npm;$env:PATH"

# bun
$env:BUN_INSTALL = "$env:XDG_DATA_HOME/bun"
$env:PATH = "$env:BUN_INSTALL/bin;$env:PATH"

# Docker
$env:DOCKER_CONFIG = "$env:XDG_CONFIG_HOME/docker"
$env:MACHINE_STORAGE_PATH = "$env:XDG_DATA_HOME/docker-machine"

# dotnet
$env:DOTNET_CLI_HOME = "$env:XDG_DATA_HOME/dotnet"

# go
$env:GOPATH = "$env:XDG_DATA_HOME/go"

# Gradle
$env:GRADLE_USER_HOME = "$env:XDG_DATA_HOME/gradle"

# Node.js
$env:NODE_REPL_HISTORY = "$env:XDG_DATA_HOME/node_repl_history"

# Nuget (partial)
$env:NUGET_PACKAGES = "$env:XDG_DATA_HOME/nuget/packages"

# Python
$env:PYTHON_HISTORY = "$env:XDG_STATE_HOME/python_history"
$env:PYTHONPYCACHEPREFIX = "$env:XDG_CACHE_HOME/python"
$env:PYTHONUSERBASE = "$env:XDG_DATA_HOME/python"

# vim with XDG config
$env:VIMINIT = "source $env:XDG_CONFIG_HOME/vim/vimrc"
$env:VIMDOTDIR = "$env:XDG_CONFIG_HOME/vim"

# C/C++ settings
$env:CC = "{{ .language.cpp.cc }}"
$env:CXX = "{{ .language.cpp.cxx }}"
$env:CMAKE_GENERATOR = "{{ .language.cpp.cmake_generator }}"
$env:CMAKE_BUILD_PARALLEL_LEVEL = "8"

# xmake with XDG config
$env:XMAKE_PKG_CACHEDIR = "$env:XDG_CACHE_HOME/xmake/cache"

# Dev config
$env:DEV_SDK_ROOT = "{{ .lib.dev_sdk_root }}"
$env:PKG_CONFIG_PATH = "{{ .lib.pkg_config_path }};$env:PKG_CONFIG_PATH"
$env:LLVM_ROOT = "{{ .lib.llvm_root }}"

# LLVM cmake prefix path
if ([string]::IsNullOrEmpty($env:LLVM_ROOT) -eq $env:false) {
    $env:CMAKE_PREFIX_PATH = "$env:LLVM_ROOT${CMAKE_PREFIX_PATH:+:$env:CMAKE_PREFIX_PATH}"
}

# vcpkg and Vulkan SDK
if (Test-Path $env:DEV_SDK_ROOT -PathType Container) {
    $env:VCPKG_ROOT = "$env:DEV_SDK_ROOT/vcpkg"
    $env:VULKAN_SDK_VERSION = "{{ .lib.vulkan_sdk_version }}"
    $env:VULKAN_SDK_ROOT = "$env:DEV_SDK_ROOT/VulkanSDK/$env:VULKAN_SDK_VERSION"
    if (Test-Path "$env:VULKAN_SDK_ROOT/setup-env.sh" -PathType Leaf) {
        . source "$env:VULKAN_SDK_ROOT/setup-env.sh"
    }
}
