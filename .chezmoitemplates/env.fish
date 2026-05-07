# check https://wiki.archlinux.org.cn/title/XDG_Base_Directory for all software support
# XDG Base Directory
set -gx XDG_CACHE_HOME "$HOME/.cache"
set -gx XDG_CONFIG_HOME "$HOME/.config"
set -gx XDG_DATA_HOME "$HOME/.local/share"
set -gx XDG_STATE_HOME "$HOME/.local/state"

# wget
set -gx WGETRC "$XDG_CONFIG_HOME/wget/wgetrc"
alias wget 'wget --hsts-file="$XDG_STATE_HOME/wget-hsts"'

# npm
set -gx NPM_CONFIG_USERCONFIG "$XDG_CONFIG_HOME/npm/npmrc"
set -gx PATH "$XDG_DATA_HOME/npm:$PATH"

# bun
set -gx BUN_INSTALL "$XDG_DATA_HOME/bun"
set -gx PATH "$BUN_INSTALL/bin:$PATH"

# Homebrew settings
if test -x "brew"
    set BREW $(which brew 2>/dev/null)
    set -gx HOMEBREW_API_DOMAIN "https://mirrors.ustc.edu.cn/homebrew-bottles/api"
    set -gx HOMEBREW_BREW_GIT_REMOTE "https://mirrors.ustc.edu.cn/brew.git"
    set -gx HOMEBREW_CORE_GIT_REMOTE "https://mirrors.ustc.edu.cn/homebrew-core.git"
    set -gx HOMEBREW_BOTTLE_DOMAIN "https://mirrors.ustc.edu.cn/homebrew-bottles"
    set -gx HOMEBREW_PIP_INDEX_URL "https://mirrors.ustc.edu.cn/pypi/simple/"
    eval "$($BREW shellenv)"
end

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

# Nuget (partial)
set -gx NUGET_PACKAGES "$XDG_DATA_HOME/nuget/packages"

# Python
set -gx PYTHON_HISTORY "$XDG_STATE_HOME/python_history"
set -gx PYTHONPYCACHEPREFIX "$XDG_CACHE_HOME/python"
set -gx PYTHONUSERBASE "$XDG_DATA_HOME/python"

# ipython
set -gx IPYTHONDIR "$XDG_CONFIG_HOME/ipython"

# matplotlib
set -gx MPLCONFIGDIR "$XDG_CONFIG_HOME/matplotlib"

# vim with XDG config
set -gx VIMDOTDIR "$XDG_CONFIG_HOME/vim"
alias vim 'vim -u $VIMDOTDIR/vimrc'

# C/C++ settings
set -gx CC "{{ .language.cpp.cc }}"
set -gx CXX "{{ .language.cpp.cxx }}"
set -gx CMAKE_GENERATOR "{{ .language.cpp.cmake_generator }}"
set -gx CMAKE_BUILD_PARALLEL_LEVEL "8"

# xmake with XDG config
set -gx XMAKE_PKG_CACHEDIR "$XDG_CACHE_HOME/xmake/cache"

# Dev config
set -gx SDK_ROOT "{{ .sdk.sdk_path }}"
set -gx PKG_CONFIG_PATH "{{ .sdk.pkg_config_path }}:$PKG_CONFIG_PATH"

# LLVM
set -gx LLVM_PATH "{{ .sdk.llvm_path }}"
if test -d "$LLVM_PATH"
    set -gx PATH "$LLVM_PATH/bin:$PATH"
end

# vcpkg
if test -d "$SDK_ROOT"
    set -gx VCPKG_ROOT "$SDK_ROOT/vcpkg"
end

# Vulkan SDK
set -gx VULKAN_SDK_VERSION "{{ .sdk.vulkan_sdk_version }}"
set -gx VULKAN_SDK_PATH "$DEV_SDK_PATH/VulkanSDK/$VULKAN_SDK_VERSION"
if test -f "$VULKAN_SDK_PATH/setup-env.sh"
    source "$VULKAN_SDK_PATH/setup-env.sh"
end
