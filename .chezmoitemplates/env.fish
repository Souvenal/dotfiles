# XDG config
set -gx XDG_CONFIG_HOME "{{ .user.xdg_config_home }}"

# Network proxy
set -gx HTTP_PROXY "{{ .proxy.http }}"
set -gx HTTPS_PROXY "{{ .proxy.https }}"

# Dev config
set -gx DEV_SDK_ROOT "{{ .lib.dev_sdk_root }}"
if test -n "$PKG_CONFIG_PATH"
    set -gx PKG_CONFIG_PATH "{{ .lib.pkg_config_path }}:$PKG_CONFIG_PATH"
else
    set -gx PKG_CONFIG_PATH "{{ .lib.pkg_config_path }}"
end

# C/C++ settings
set -gx CC "{{ .language.cpp.cc }}"
set -gx CXX "{{ .language.cpp.cxx }}"
set -gx CMAKE_GENERATOR "{{ .language.cpp.cmake_generator }}"
{{- if eq .chezmoi.os "darwin" }}
set -gx CMAKE_BUILD_PARALLEL_LEVEL (sysctl -n hw.ncpu)
{{- else if eq .chezmoi.os "linux" }}
set -gx CMAKE_BUILD_PARALLEL_LEVEL (nproc)
{{- else }}
set -gx CMAKE_BUILD_PARALLEL_LEVEL 8
{{ end }}

# Vulkan SDK
if test -d "$DEV_SDK_ROOT"
    set -gx VULKAN_SDK_VERSION {{ .lib.vulkan_sdk_version }}
    set -gx VULKAN_SDK_ROOT "$DEV_SDK_ROOT/VulkanSDK/$VULKAN_SDK_VERSION"
    if test -f "$VULKAN_SDK_ROOT/setup-env.sh"
        bass source "$VULKAN_SDK_ROOT/setup-env.sh"
    else
        # WARNING: Vulkan SDK setup script not found at $VULKAN_SDK_ROOT/setup-env.sh
    end
else
    # WARNING: DEV_SDK_ROOT directory not found, Vulkan SDK will not be configured
end

# Homebrew settings
if type -q brew
    set -gx HOMEBREW_PIP_INDEX_URL "{{ .app.homebrew.pip_index_url }}"
    set -gx HOMEBREW_API_DOMAIN "{{ .app.homebrew.api_domain }}"
    set -gx HOMEBREW_BOTTLE_DOMAIN "{{ .app.homebrew.bottle_domain }}"
    eval (brew shellenv)
end
