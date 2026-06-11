# check https://wiki.archlinux.org.cn/title/XDG_Base_Directory for all software support
# XDG Base Directory
$env:XDG_CACHE_HOME = "$HOME/.cache"
$env:XDG_CONFIG_HOME = "$HOME/.config"
$env:XDG_DATA_HOME = "$HOME/.local/share"
$env:XDG_STATE_HOME = "$HOME/.local/state"

# local bin PATH
$env:PATH = "~/.local/bin;$env:PATH"

# npm
$env:NPM_CONFIG_USERCONFIG = "$env:XDG_CONFIG_HOME/npm/npmrc"
$env:PATH = "$env:XDG_DATA_HOME/npm/bin;$env:PATH"

# bun
$env:BUN_INSTALL = "$env:XDG_DATA_HOME/bun"
$env:PATH = "$env:BUN_INSTALL/bin;$env:PATH"

# pip
$env:PIP_CACHE_DIR = "$env:XDG_CACHE_HOME/pip"

# uv
$env:UV_CACHE_DIR = "$env:XDG_CACHE_HOME/uv"

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

# ipython
$env:IPYTHONDIR = "$env:XDG_CONFIG_HOME/ipython"

# matplotlib
$env:MPLCONFIGDIR = "$env:XDG_CONFIG_HOME/matplotlib"

# vim with XDG config
$env:VIMDOTDIR = "$env:XDG_CONFIG_HOME/vim"
Set-Alias vim 'vim -u $env:VIMDOTDIR/vimrc'

# C/C++ settings
$env:CC = "{{ .language.cpp.cc }}"
$env:CXX = "{{ .language.cpp.cxx }}"
$env:CMAKE_GENERATOR = "{{ .language.cpp.cmake_generator }}"
$env:CMAKE_BUILD_PARALLEL_LEVEL = "8"

# xmake with XDG config
$env:XMAKE_PKG_INSTALLDIR = "$env:XDG_DATA_HOME/xmake/packages"
$env:XMAKE_PKG_CACHEDIR = "$env:XDG_CACHE_HOME/xmake/cache"

# Dev config
$env:SDK_ROOT = "{{ .sdk.sdk_path }}"
$env:PKG_CONFIG_PATH = "{{ .sdk.pkg_config_path }};$env:PKG_CONFIG_PATH"

# LLVM
$env:LLVM_PATH = "{{ .sdk.llvm_path }}"
if (Test-Path $env:LLVM_PATH -PathType Container) {
    $env:PATH = "$env:LLVM_PATH/bin;$env:PATH"
}

# Vulkan SDK
$env:VULKAN_SDK_VERSION = "{{ .sdk.vulkan_sdk_version }}"
if (Test-Path "$env:SDK_ROOT/VulkanSDK/$env:VULKAN_SDK_VERSION/setup-env.sh" -PathType Leaf) {
    . source "$env:SDK_ROOT/VulkanSDK/$env:VULKAN_SDK_VERSION/setup-env.sh"
}
