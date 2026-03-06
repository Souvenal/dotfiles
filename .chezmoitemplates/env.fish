.chezmoitemplates/env.fish：
# User SDK Root
{{ if eq .user.dev_sdk_root "" -}}
set -gx DEV_SDK_ROOT $HOME/Library
{{ else -}}
set -gx DEV_SDK_ROOT {{ .user.dev_sdk_root }}
{{ end -}}

# XDG Config
set -gx XDG_CONFIG_HOME {{ .user.xdg_config_home }}

# Vulkan SDK
{{ if eq .tools.vulkan.version "" -}}
# WARNING: Vulkan SDK not configured
{{ else -}}
set -gx VULKAN_SDK_VERSION {{ .tools.vulkan.version }}
set -gx VULKAN_SDK_ROOT $DEV_SDK_ROOT/VulkanSDK/$VULKAN_SDK_VERSION
if test -f $VULKAN_SDK_ROOT/setup-env.sh
    bass source $VULKAN_SDK_ROOT/setup-env.sh
end
{{ end -}}

# CUDA
{{ if eq .tools.cuda.version "" -}}
# WARNING: CUDA not configured
{{ else -}}
set -gx CUDA_VERSION {{ .tools.cuda.version }}
set -gx CUDA_ROOT /usr/local/cuda-{{ .tools.cuda.version }}
set -gx PATH $CUDA_ROOT/bin $PATH
{{ end -}}