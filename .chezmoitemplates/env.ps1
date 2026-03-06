# User SDK Root
{{ if eq .user.dev_sdk_root "" -}}
$env:DEV_SDK_ROOT = "$env:USERPROFILE\Library"
{{ else -}}
$env:DEV_SDK_ROOT = "{{ .user.dev_sdk_root }}"
{{ end -}}

# XDG Config
$env:XDG_CONFIG_HOME = "{{ .user.xdg_config_home }}"

# Note: Vulkan and CUDA environment variables are set system-wide via registry
# by run_after_apply.ps1. They will be available after restarting PowerShell.