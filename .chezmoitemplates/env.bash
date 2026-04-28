# check https://wiki.archlinux.org.cn/title/XDG_Base_Directory for all software support
# XDG Base Directory
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# Network proxy config
# Use both upper and lower cases for compatibility
export http_proxy="{{ .network.http_proxy }}"
export HTTP_PROXY="$http_proxy"
export https_proxy="{{ .network.https_proxy }}"
export HTTPS_PROXY="$https_proxy"
export no_proxy="{{ .network.no_proxy }}"
export NO_PROXY="$no_proxy"

# wget
export WGETRC="$XDG_CONFIG_HOME/wgetrc"
alias wget='wget --hsts-file="$XDG_STATE_HOME/wget-hsts"'

# bash
export HISTFILE="$XDG_STATE_HOME/bash/history"

# npm
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export PATH="$XDG_DATA_HOME/npm:$PATH"

# bun
export BUN_INSTALL="$XDG_DATA_HOME/bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Homebrew settings
if [ -x "$(which brew)" ]; then
    BREW=$(which brew 2>/dev/null)
    export HOMEBREW_API_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles/api"
    export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.ustc.edu.cn/brew.git"
    export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.ustc.edu.cn/homebrew-core.git"
    export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles"
    export HOMEBREW_PIP_INDEX_URL="https://mirrors.ustc.edu.cn/pypi/simple/"
    eval "$($BREW shellenv)"
fi

# Docker
export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"
export MACHINE_STORAGE_PATH="$XDG_DATA_HOME/docker-machine"

# dotnet
export DOTNET_CLI_HOME="$XDG_DATA_HOME/dotnet"

# go
export GOPATH="$XDG_DATA_HOME/go"

# GPG
export GNUPGHOME="$XDG_DATA_HOME/gnupg"
export GPG_TTY="$(tty)"
export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"

# Gradle
export GRADLE_USER_HOME="$XDG_DATA_HOME/gradle"

# Node.js
export NODE_REPL_HISTORY="$XDG_DATA_HOME/node_repl_history"

# Nuget (partial)
export NUGET_PACKAGES="$XDG_DATA_HOME/nuget/packages"

# Python
export PYTHON_HISTORY="$XDG_STATE_HOME/python_history"
export PYTHONPYCACHEPREFIX="$XDG_CACHE_HOME/python"
export PYTHONUSERBASE="$XDG_DATA_HOME/python"

# vim with XDG config
export VIMDOTDIR="$XDG_CONFIG_HOME/vim"
alias vim='vim -u $VIMDOTDIR/vimrc'

# C/C++ settings
export CC="{{ .language.cpp.cc }}"
export CXX="{{ .language.cpp.cxx }}"
export CMAKE_GENERATOR="{{ .language.cpp.cmake_generator }}"
export CMAKE_BUILD_PARALLEL_LEVEL="8"

# xmake with XDG config
export XMAKE_PKG_CACHEDIR="$XDG_CACHE_HOME/xmake/cache"

# Dev config
export SDK_ROOT="{{ .sdk.sdk_path }}"
export PKG_CONFIG_PATH="{{ .sdk.pkg_config_path }}:$PKG_CONFIG_PATH"

# LLVM
export PATH="{{ .sdk.llvm_path }}/bin:$PATH"

# vcpkg and Vulkan SDK
if [ -d "${DEV_SDK_ROOT}" ]; then
    export VCPKG_ROOT="$SDK_ROOT/vcpkg"
    export VULKAN_SDK_VERSION="{{ .sdk.vulkan_sdk_version }}"
    export VULKAN_SDK_PATH="$DEV_SDK_PATH/VulkanSDK/$VULKAN_SDK_VERSION"
    if [ -f "${VULKAN_SDK_PATH/setup-env.sh}" ]; then
        source "$VULKAN_SDK_PATH/setup-env.sh"
    fi
fi
