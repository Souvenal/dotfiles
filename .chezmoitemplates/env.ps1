# check https://wiki.archlinux.org.cn/title/XDG_Base_Directory for all software support
# XDG Base Directory
$env:XDG_CACHE_HOME = "$HOME/.cache"
$env:XDG_CONFIG_HOME = "$HOME/.config"
$env:XDG_DATA_HOME = "$HOME/.local/share"
$env:XDG_STATE_HOME = "$HOME/.local/state"

# Docker
$env:DOCKER_CONFIG = "$XDG_CONFIG_HOME/docker"
$env:MACHINE_STORAGE_PATH = "$XDG_DATA_HOME/docker-machine"

# dotnet
$env:DOTNET_CLI_HOME = "$XDG_DATA_HOME/dotnet"

# go
$env:GOPATH = "$XDG_DATA_HOME/go"

# GPG
$env:GNUPGHOME = "$XDG_DATA_HOME/gnupg"
$env:GPG_TTY = "$(tty)"
$env:SSH_AUTH_SOCK = "$(gpgconf --list-dirs agent-ssh-socket)"

# Gradle
$env:GRADLE_USER_HOME = "$XDG_DATA_HOME/gradle"

# Node.js
$env:NODE_REPL_HISTORY = "$XDG_DATA_HOME/node_repl_history"

# npm
$env:NPM_CONFIG_USERCONFIG = "$XDG_CONFIG_HOME/npm/npmrc"

# Nuget (partial)
$env:NUGET_PACKAGES = "$XDG_DATA_HOME/nuget/packages"

# Python
$env:PYTHON_HISTORY = "$XDG_STATE_HOME/python_history"
$env:PYTHONPYCACHEPREFIX = "$XDG_CACHE_HOME/python"
$env:PYTHONUSERBASE = "$XDG_DATA_HOME/python"

# vim with XDG config
$env:VIMINIT = "let $MYVIMRC=\"$XDG_CONFIG_HOME/vim/vimrc\" | source $MYVIMRC"
$env:VIMDOTDIR = "$XDG_CONFIG_HOME/vim"

# wget
$env:WGETRC = "$XDG_CONFIG_HOME/wgetrc"
Set-Alias wget 'wget --hsts-file="$XDG_STATE_HOME/wget-hsts"'

# Homebrew settings
if Test-Path "$(which brew)"  {
    $BREW = "$(which brew 2>/dev/null)"
    $env:HOMEBREW_API_DOMAIN = "https://mirrors.ustc.edu.cn/homebrew-bottles/api"
    $env:HOMEBREW_BREW_GIT_REMOTE = "https://mirrors.ustc.edu.cn/brew.git"
    $env:HOMEBREW_CORE_GIT_REMOTE = "https://mirrors.ustc.edu.cn/homebrew-core.git"
    $env:HOMEBREW_BOTTLE_DOMAIN = "https://mirrors.ustc.edu.cn/homebrew-bottles"
    $env:HOMEBREW_PIP_INDEX_URL = "https://mirrors.ustc.edu.cn/pypi/simple/"
    Invoke-Expression "$($BREW shellenv)"
}

# C/C++ settings
export CC={{ .language.cpp.cc | quote }}
export CXX={{ .language.cpp.cxx | quote }}
export CMAKE_GENERATOR={{ .language.cpp.cmake_generator | quote }}
export CMAKE_BUILD_PARALLEL_LEVEL=
{{- if eq .chezmoi.os "darwin" -}}
$(sysctl -n hw.ncpu)
{{- else if eq .chezmoi.os "linux" -}}
$(nproc)
{{- else -}}
8
{{- end }}

# xmake with XDG config
$env:XMAKE_PKG_CACHEDIR = "$XDG_CACHE_HOME/xmake/cache"

# Dev config
export DEV_SDK_ROOT={{ .lib.dev_sdk_root | quote }}
export PKG_CONFIG_PATH={{ .lib.pkg_config_path | quote }}:$PKG_CONFIG_PATH
export LLVM_ROOT={{ .lib.llvm_root | quote }}

# LLVM cmake prefix path
if [ -n "$LLVM_ROOT"  {
    $env:CMAKE_PREFIX_PATH = "$LLVM_ROOT${CMAKE_PREFIX_PATH:+:$CMAKE_PREFIX_PATH}"
}

# vcpkg and Vulkan SDK
if [ -d "$DEV_SDK_ROOT"  {
    $env:VCPKG_ROOT = "$DEV_SDK_ROOT/vcpkg"
    export VULKAN_SDK_VERSION={{ .lib.vulkan_sdk_version }}
    $env:VULKAN_SDK_ROOT = "$DEV_SDK_ROOT/VulkanSDK/$VULKAN_SDK_VERSION"
    if [ -f "$VULKAN_SDK_ROOT/setup-env.sh"  {
        . source "$VULKAN_SDK_ROOT/setup-env.sh"
    }
}
