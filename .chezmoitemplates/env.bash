# XDG config
export XDG_CONFIG_HOME="{{ .user.xdg_config_home }}"

# Network proxy
export HTTP_PROXY="{{ .proxy.http }}"
export HTTPS_PROXY="{{ .proxy.https }}"

# Dev config
export DEV_SDK_ROOT="{{ .lib.dev_sdk_root }}"
export PKG_CONFIG_PATH="{{ .lib.pkg_config_path }}:$PKG_CONFIG_PATH"

# C/C++ settings
export CC="{{ .language.cpp.cc }}"
export CXX="{{ .language.cpp.cxx }}"
export CMAKE_GENERATOR="{{ .language.cpp.cmake_generator }}"
export CMAKE_BUILD_PARALLEL_LEVEL=
{{- if eq .chezmoi.os "darwin" -}}
$(sysctl -n hw.ncpu)
{{- else if eq .chezmoi.os "linux" -}}
$(nproc)
{{- else -}}
8
{{ end }}

# Vulkan SDK
if [ -d "$DEV_SDK_ROOT" ]; then
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

# Homebrew settings
BREW=$(which brew 2>/dev/null)
if [ -x "$BREW" ]; then
    export HOMEBREW_PIP_INDEX_URL="{{ .app.homebrew.pip_index_url }}"
    export HOMEBREW_API_DOMAIN="{{ .app.homebrew.api_domain }}"
    export HOMEBREW_BOTTLE_DOMAIN="{{ .app.homebrew.bottle_domain }}"
    eval "$($BREW shellenv)"
fi