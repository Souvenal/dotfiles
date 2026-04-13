# check https://wiki.archlinux.org.cn/title/XDG_Base_Directory for all software support
# XDG Base Directory
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# zsh
if [ ! -d "$XDG_STATE_HOME/zsh" ]; then mkdir -p "$XDG_STATE_HOME/zsh"; fi
if [ ! -d "$XDG_CACHE_HOME/zsh" ]; then mkdir -p "$XDG_CACHE_HOME/zsh"; fi
export ZSH="$XDG_DATA_HOME/oh-my-zsh"
export HISTFILE="$XDG_STATE_HOME/zsh/history"

# wget
export WGETRC="$XDG_CONFIG_HOME/wgetrc"
alias wget='wget --hsts-file="$XDG_STATE_HOME/wget-hsts"'

# bun
export PATH="{{ .chezmoi.homeDir }}/.cache/.bun/bin:$PATH"

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

# npm
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"

# Nuget (partial)
export NUGET_PACKAGES="$XDG_DATA_HOME/nuget/packages"

# Python
export PYTHON_HISTORY="$XDG_STATE_HOME/python_history"
export PYTHONPYCACHEPREFIX="$XDG_CACHE_HOME/python"
export PYTHONUSERBASE="$XDG_DATA_HOME/python"

# vim with XDG config
export VIMINIT="source $XDG_CONFIG_HOME/vim/vimrc"
export VIMDOTDIR="$XDG_CONFIG_HOME/vim"

# C/C++ settings
export CC="{{ .language.cpp.cc }}"
export CXX="{{ .language.cpp.cxx }}"
export CMAKE_GENERATOR="{{ .language.cpp.cmake_generator }}"
export CMAKE_BUILD_PARALLEL_LEVEL="8"

# xmake with XDG config
export XMAKE_PKG_CACHEDIR="$XDG_CACHE_HOME/xmake/cache"

# Dev config
export DEV_SDK_ROOT="{{ .lib.dev_sdk_root }}"
export PKG_CONFIG_PATH="{{ .lib.pkg_config_path }}:$PKG_CONFIG_PATH"
export LLVM_ROOT="{{ .lib.llvm_root }}"

# LLVM cmake prefix path
if [ -n "${LLVM_ROOT}" ]; then
    export CMAKE_PREFIX_PATH="$LLVM_ROOT${CMAKE_PREFIX_PATH:+:$CMAKE_PREFIX_PATH}"
fi

# vcpkg and Vulkan SDK
if [ -d "${DEV_SDK_ROOT}" ]; then
    export VCPKG_ROOT="$DEV_SDK_ROOT/vcpkg"
    export VULKAN_SDK_VERSION="{{ .lib.vulkan_sdk_version }}"
    export VULKAN_SDK_ROOT="$DEV_SDK_ROOT/VulkanSDK/$VULKAN_SDK_VERSION"
    if [ -f "${VULKAN_SDK_ROOT/setup-env.sh}" ]; then
        source "$VULKAN_SDK_ROOT/setup-env.sh"
    fi
fi
