#!/bin/bash
set -e
# 读取验证开关
WARN_ON_EMPTY=$(chezmoi data | grep -A1 "validation" | grep "warn_on_empty" | cut -d'"' -f2)
if [ "$WARN_ON_EMPTY" = "false" ]; then
    exit 0
fi
# 使用 chezmoi data 检查空值
DATA=$(chezmoi data)
# 检查 tools 下的空版本号
for tool in vulkan cuda; do
    VERSION=$(echo "$DATA" | grep -A2 "\"$tool\"" | grep "version" | cut -d'"' -f4)
    if [ -z "$VERSION" ]; then
        echo "WARNING: tools.$tool.version is empty. Set it in .chezmoidata.toml" >&2
    fi
done