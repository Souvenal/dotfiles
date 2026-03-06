# User SDK Root
{{ if eq .user.dev_sdk_root "" -}}
export DEV_SDK_ROOT="$HOME/Library"
{{ else -}}
export DEV_SDK_ROOT="{{ .user.dev_sdk_root }}"
{{ end -}}

# XDG Config
export XDG_CONFIG_HOME="{{ .user.xdg_config_home }}"

# Vulkan SDK
{{ if eq .tools.vulkan.version "" -}}
# WARNING: Vulkan SDK not configured
{{ else -}}
export VULKAN_SDK_VERSION="{{ .tools.vulkan.version }}"
export VULKAN_SDK_ROOT="$DEV_SDK_ROOT/VulkanSDK/$VULKAN_SDK_VERSION"
if [ -f "$VULKAN_SDK_ROOT/setup-env.sh" ]; then
    source "$VULKAN_SDK_ROOT/setup-env.sh"
fi
{{ end -}}

# CUDA
{{ if eq .tools.cuda.version "" -}}
# WARNING: CUDA not configured
{{ else -}}
export CUDA_VERSION="{{ .tools.cuda.version }}"
export CUDA_ROOT="/usr/local/cuda-{{ .tools.cuda.version }}"
export PATH="$CUDA_ROOT/bin:$PATH"
{{ end -}}