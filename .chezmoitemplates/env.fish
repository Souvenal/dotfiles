# check https://wiki.archlinux.org.cn/title/XDG_Base_Directory for all software support
# XDG Base Directory
set -gx XDG_CACHE_HOME "$HOME/.cache"
set -gx XDG_CONFIG_HOME "$HOME/.config"
set -gx XDG_DATA_HOME "$HOME/.local/share"
set -gx XDG_STATE_HOME "$HOME/.local/state"

# Docker
set -gx DOCKER_CONFIG "$XDG_CONFIG_HOME/docker"
set -gx MACHINE_STORAGE_PATH "$XDG_DATA_HOME/docker-machine"

# dotnet
set -gx DOTNET_CLI_HOME "$XDG_DATA_HOME/dotnet"

# go
set -gx GOPATH "$XDG_DATA_HOME/go"

# GPG
set -gx GNUPGHOME "$XDG_DATA_HOME/gnupg"
set -gx GPG_TTY "$(tty)"
set -gx SSH_AUTH_SOCK "$(gpgconf --list-dirs agent-ssh-socket)"

# Gradle
set -gx GRADLE_USER_HOME "$XDG_DATA_HOME/gradle"

# Node.js
set -gx NODE_REPL_HISTORY "$XDG_DATA_HOME/node_repl_history"

# npm
set -gx NPM_CONFIG_USERCONFIG "$XDG_CONFIG_HOME/npm/npmrc"

# Nuget (partial)
set -gx NUGET_PACKAGES "$XDG_DATA_HOME/nuget/packages"

# Python
set -gx PYTHON_HISTORY "$XDG_STATE_HOME/python_history"
set -gx PYTHONPYCACHEPREFIX "$XDG_CACHE_HOME/python"
set -gx PYTHONUSERBASE "$XDG_DATA_HOME/python"

# vim with XDG config
set -gx VIMINIT "let $MYVIMRC=\"$XDG_CONFIG_HOME/vim/vimrc\" | source $MYVIMRC"
set -gx VIMDOTDIR "$XDG_CONFIG_HOME/vim"

# wget
set -gx WGETRC "$XDG_CONFIG_HOME/wgetrc"
alias wget 'wget --hsts-file="$XDG_STATE_HOME/wget-hsts"'

# Homebrew settings
if test -x "$(which brew)" 
    set BREW $(which brew 2>/dev/null)
    set -gx HOMEBREW_API_DOMAIN "https://mirrors.ustc.edu.cn/homebrew-bottles/api"
    set -gx HOMEBREW_BREW_GIT_REMOTE "https://mirrors.ustc.edu.cn/brew.git"
    set -gx HOMEBREW_CORE_GIT_REMOTE "https://mirrors.ustc.edu.cn/homebrew-core.git"
    set -gx HOMEBREW_BOTTLE_DOMAIN "https://mirrors.ustc.edu.cn/homebrew-bottles"
    set -gx HOMEBREW_PIP_INDEX_URL "https://mirrors.ustc.edu.cn/pypi/simple/"
    eval "$($BREW shellenv)"
end

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
set -gx XMAKE_PKG_CACHEDIR "$XDG_CACHE_HOME/xmake/cache"

# Dev config
export DEV_SDK_ROOT={{ .lib.dev_sdk_root | quote }}
export PKG_CONFIG_PATH={{ .lib.pkg_config_path | quote }}:$PKG_CONFIG_PATH
export LLVM_ROOT={{ .lib.llvm_root | quote }}

# LLVM cmake prefix path
if test -n "$LLVM_ROOT" 
    set -gx CMAKE_PREFIX_PATH "$LLVM_ROOT${CMAKE_PREFIX_PATH:+:$CMAKE_PREFIX_PATH}"
end

# vcpkg and Vulkan SDK
if test -d "$DEV_SDK_ROOT" 
    set -gx VCPKG_ROOT "$DEV_SDK_ROOT/vcpkg"
    export VULKAN_SDK_VERSION={{ .lib.vulkan_sdk_version }}
    set -gx VULKAN_SDK_ROOT "$DEV_SDK_ROOT/VulkanSDK/$VULKAN_SDK_VERSION"
    if test -f "$VULKAN_SDK_ROOT/setup-env.sh" 
        source "$VULKAN_SDK_ROOT/setup-env.sh"
    end
end
