# check https://wiki.archlinux.org.cn/title/XDG_Base_Directory for all software support
# XDG Base Directory
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# local bin PATH
export PATH="~/.local/bin:$PATH"

# wget
export WGETRC="$XDG_CONFIG_HOME/wget/wgetrc"
alias wget='wget --hsts-file="$XDG_STATE_HOME/wget-hsts"'

# zsh
if [ ! -d "$XDG_STATE_HOME/zsh" ]; then mkdir -p "$XDG_STATE_HOME/zsh"; fi
if [ ! -d "$XDG_CACHE_HOME/zsh" ]; then mkdir -p "$XDG_CACHE_HOME/zsh"; fi
export ZSH="$XDG_DATA_HOME/oh-my-zsh"
export HISTFILE="$XDG_STATE_HOME/zsh/history"

# npm
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export PATH="$XDG_DATA_HOME/npm/bin:$PATH"

# bun
export BUN_INSTALL="$XDG_DATA_HOME/bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Homebrew settings
if command -v "brew" > /dev/null; then
    export HOMEBREW_API_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles/api"
    export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.ustc.edu.cn/brew.git"
    export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.ustc.edu.cn/homebrew-core.git"
    export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles"
    export HOMEBREW_PIP_INDEX_URL="https://mirrors.ustc.edu.cn/pypi/simple/"
    export HOMEBREW_NO_AUTO_UPDATE="1"
    eval "$(brew shellenv)"
fi

# pip
export PIP_CACHE_DIR="$XDG_CACHE_HOME/pip"

# uv
export UV_CACHE_DIR="$XDG_CACHE_HOME/uv"

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

# ipython
export IPYTHONDIR="$XDG_CONFIG_HOME/ipython"

# matplotlib
export MPLCONFIGDIR="$XDG_CONFIG_HOME/matplotlib"

# vim with XDG config
export VIMDOTDIR="$XDG_CONFIG_HOME/vim"
alias vim='vim -u $VIMDOTDIR/vimrc'

# C/C++ settings
export CC="{{ .language.cpp.cc }}"
export CXX="{{ .language.cpp.cxx }}"
export CMAKE_GENERATOR="{{ .language.cpp.cmake_generator }}"
export CMAKE_BUILD_PARALLEL_LEVEL="8"

# xmake with XDG config
export XMAKE_PKG_INSTALLDIR="$XDG_DATA_HOME/xmake/packages"
export XMAKE_PKG_CACHEDIR="$XDG_CACHE_HOME/xmake/cache"

# Dev config
export SDK_ROOT="{{ .sdk.sdk_path }}"
export PKG_CONFIG_PATH="{{ .sdk.pkg_config_path }}:$PKG_CONFIG_PATH"

# LLVM
export LLVM_PATH="{{ .sdk.llvm_path }}"
if [ -d "$LLVM_PATH" ]; then
    export PATH="$LLVM_PATH/bin:$PATH"
fi

# Vulkan SDK
export VULKAN_SDK_VERSION="{{ .sdk.vulkan_sdk_version }}"
if [ -f "$SDK_ROOT/VulkanSDK/$VULKAN_SDK_VERSION/setup-env.sh" ]; then
    source "$SDK_ROOT/VulkanSDK/$VULKAN_SDK_VERSION/setup-env.sh"
fi
