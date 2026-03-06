#Requires -RunAsAdministrator
# 获取当前配置数据
$Data = chezmoi data | ConvertFrom-Json
# 读取上次管理的变量列表
$RegPath = "HKCU:\Software\Chezmoi\EnvVars"
$LastManaged = @()
if (Test-Path $RegPath) {
    $LastManagedRaw = (Get-ItemProperty -Path $RegPath -Name "ManagedList" -ErrorAction SilentlyContinue).ManagedList
    if ($LastManagedRaw) {
        $LastManaged = $LastManagedRaw -split ';'
    }
}
# 构建当前要管理的变量列表
$CurrentManaged = @("DEV_SDK_ROOT", "XDG_CONFIG_HOME")
# 添加 SDK 版本变量（如果设置了）
if ($Data.tools.vulkan.version) {
    $CurrentManaged += "VULKAN_SDK_VERSION"
}
if ($Data.tools.cuda.version) {
    $CurrentManaged += "CUDA_VERSION"
}
# 删除旧变量
foreach ($var in $LastManaged) {
    if ($var -and -not ($CurrentManaged -contains $var)) {
        if ($var -ne "PATH_ENTRIES") {
            Write-Host "Removing old environment variable: $var"
            [Environment]::SetEnvironmentVariable($var, $null, "User")
        }
    }
}
# 设置/更新变量
$DevSdkRoot = $Data.user.dev_sdk_root
if (-not $DevSdkRoot) {
    $DevSdkRoot = "$env:USERPROFILE\Library"
}
[Environment]::SetEnvironmentVariable("DEV_SDK_ROOT", $DevSdkRoot, "User")
[Environment]::SetEnvironmentVariable("XDG_CONFIG_HOME", $Data.user.xdg_config_home, "User")
if ($Data.tools.vulkan.version) {
    [Environment]::SetEnvironmentVariable("VULKAN_SDK_VERSION", $Data.tools.vulkan.version, "User")
}
if ($Data.tools.cuda.version) {
    [Environment]::SetEnvironmentVariable("CUDA_VERSION", $Data.tools.cuda.version, "User")
}
# 更新 PATH（追加模式）
$NewPathEntries = @()
if ($DevSdkRoot) {
    $NewPathEntries += "$DevSdkRoot\bin"
}
# 读取上次添加的 PATH 条目
$OldPathEntries = @()
if (Test-Path $RegPath) {
    $OldPathEntriesRaw = (Get-ItemProperty -Path $RegPath -Name "PATH_ENTRIES" -ErrorAction SilentlyContinue).PATH_ENTRIES
    if ($OldPathEntriesRaw) {
        $OldPathEntries = $OldPathEntriesRaw -split ';'
    }
}
# 从 PATH 中移除旧的 chezmoi 条目
$CurrentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
$PathList = $CurrentPath -split ';'
$CleanPathList = $PathList | Where-Object { $_ -and -not ($OldPathEntries -contains $_) }
# 添加新的条目
$FinalPath = ($CleanPathList + $NewPathEntries) -join ';'
[Environment]::SetEnvironmentVariable("PATH", $FinalPath, "User")
# 保存当前管理状态
if (-not (Test-Path $RegPath)) {
    New-Item -Path $RegPath -Force | Out-Null
}
$ManagedList = ($CurrentManaged -join ';')
Set-ItemProperty -Path $RegPath -Name "ManagedList" -Value $ManagedList
$PathEntriesValue = ($NewPathEntries -join ';')
Set-ItemProperty -Path $RegPath -Name "PATH_ENTRIES" -Value $PathEntriesValue
Write-Host "Environment variables updated. Restart applications to see changes."