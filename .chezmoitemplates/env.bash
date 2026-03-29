# check https://wiki.archlinux.org.cn/title/XDG_Base_Directory for all software support
# XDG Base Directory
export XDG_CACHE_HOME={{ .system.xdg.cache_home | quote }}
export XDG_CONFIG_HOME={{ .system.xdg.config_home | quote }}
export XDG_DATA_HOME={{ .system.xdg.data_home | quote }}
export XDG_STATE_HOME={{ .system.xdg.state_home | quote }}

# Docker
export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"
export MACHINE_STORAGE_PATH="$XDG_DATA_HOME/docker-machine"

# GPG
export GNUPGHOME="$XDG_DATA_HOME/gnupg"
export GPG_TTY=$(tty)
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)

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
export VIMINIT='let $MYVIMRC="$XDG_CONFIG_HOME/vim/vimrc" | source $MYVIMRC'
export VIMDOTDIR="$XDG_CONFIG_HOME/vim"

# wget
export WGETRC="$XDG_CONFIG_HOME/wgetrc"
alias wget='wget --hsts-file="$XDG_STATE_HOME/wget-hsts"'

# Network proxy
# export HTTP_PROXY={{ .proxy.http | quote }}
# export HTTPS_PROXY={{ .proxy.https | quote }}

# Homebrew settings
BREW=$(which brew 2>/dev/null)
if [ -x "$BREW" ]; then
    export HOMEBREW_API_DOMAIN={{ .app.homebrew.api_domain | quote }}
    export HOMEBREW_BREW_GIT_REMOTE={{ .app.homebrew.brew_git_remote | quote }}
    export HOMEBREW_CORE_GIT_REMOTE={{ .app.homebrew.core_git_remote | quote }}
    export HOMEBREW_BOTTLE_DOMAIN={{ .app.homebrew.bottle_domain | quote }}
    export HOMEBREW_PIP_INDEX_URL={{ .app.homebrew.pip_index_url | quote }}
    eval "$($BREW shellenv)"
fi

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
export XMAKE_PKG_CACHEDIR="$XDG_CACHE_HOME/xmake/cache"

# Dev config
export DEV_SDK_ROOT={{ .lib.dev_sdk_root | quote }}
export PKG_CONFIG_PATH={{ .lib.pkg_config_path | quote }}:$PKG_CONFIG_PATH

export LLVM_ROOT={{ .lib.llvm_root | quote }}
# LLVM cmake prefix path
if [ -n "$LLVM_ROOT" ]; then
    export CMAKE_PREFIX_PATH="$LLVM_ROOT${CMAKE_PREFIX_PATH:+:$CMAKE_PREFIX_PATH}"
fi

if [ -d "$DEV_SDK_ROOT" ]; then
    # vcpkg config
    export VCPKG_ROOT="$DEV_SDK_ROOT/vcpkg"
    
    # Vulkan SDK
    export VULKAN_SDK_VERSION={{ .lib.vulkan_sdk_version }}
    export VULKAN_SDK_ROOT="$DEV_SDK_ROOT/VulkanSDK/$VULKAN_SDK_VERSION"
    if [ -f "$VULKAN_SDK_ROOT/setup-env.sh" ]; then
        source "$VULKAN_SDK_ROOT/setup-env.sh"
    else
        # WARNING: Vulkan SDK setup script not found at $VULKAN_SDK_ROOT/setup-env.sh
    fi
else
    # WARNING: DEV_SDK_ROOT directory not found, Vulkan SDK will not be configured
fi
