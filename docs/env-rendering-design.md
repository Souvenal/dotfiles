# env.json 渲染系统设计

## 概述

`generate_env.py` 负责将 `env.json` 中的配置渲染为各 shell 特定的环境变量设置脚本。系统支持 bash、zsh、fish 和 PowerShell 四种 shell。

## 数据结构

### env.json 结构

```json
{
  "blocks": [
    {
      "block": "block_name",
      "comment": ["注释行"],
      "shell": ["bash", "zsh"],  // 可选，默认 "all"
      "dir": ["$PATH/to/dir"],   // 可选，创建目录
      "condition": {             // 可选，条件判断
        "type": "executable",
        "value": "brew"
      },
      "env": [
        {
          "key": "VAR_NAME",
          "value": "var_value",
          "type": "export",       // 可选，默认 "export"
          "quote": '"',           // 可选，默认 '"'
          "condition": {          // 可选，单个变量条件判断
            "type": "not_empty",
            "value": "OTHER_VAR"
          }
        }
      ]
    }
  ]
}
```

### Condition 格式

Condition 使用抽象语义格式，支持 shell independent 的条件判断：

```json
{
  "type": "executable|not_empty|dir_exists|file_exists|empty|path_exists",
  "value": "命令名或变量路径"
}
```

### 支持的条件类型

| Type | 说明 | Value 示例 |
|------|------|-----------|
| `executable` | 命令可执行 | `brew` |
| `not_empty` | 变量非空 | `LLVM_ROOT` |
| `dir_exists` | 目录存在 | `$DEV_SDK_ROOT` |
| `file_exists` | 文件存在 | `$VULKAN_SDK_ROOT/setup-env.sh` |
| `empty` | 变量为空 | `VAR` |
| `path_exists` | 路径存在 | `$PATH` |

### Env 类型

| Type | 说明 |
|------|------|
| `export` | 导出环境变量（默认） |
| `alias` | Shell 别名 |
| `eval` | 执行命令 |
| `source` | 加载脚本 |
| `local` | 本地变量 |

## Shell 映射

### Condition 映射表

| Type | Bash | Fish | PowerShell |
|------|------|------|------------|
| `executable` | `[ -x "$(which brew)" ]` | `test -x "$(which brew)"` | `(Get-Command brew).Source \| Test-Path -PathType Leaf -ErrorAction SilentlyContinue` |
| `not_empty` | `[ -n "$LLVM_ROOT" ]` | `test -n "$LLVM_ROOT"` | `[string]::IsNullOrEmpty($env:LLVM_ROOT) -eq $false` |
| `dir_exists` | `[ -d "$DEV_SDK_ROOT" ]` | `test -d "$DEV_SDK_ROOT"` | `Test-Path $env:DEV_SDK_ROOT -PathType Container` |
| `file_exists` | `[ -f "$VULKAN_SDK_ROOT/setup-env.sh" ]` | `test -f "$VULKAN_SDK_ROOT/setup-env.sh"` | `Test-Path "$env:VULKAN_SDK_ROOT/setup-env.sh" -PathType Leaf` |
| `empty` | `[ -z "$VAR" ]` | `test -z "$VAR"` | `[string]::IsNullOrEmpty($env:VAR)` |
| `path_exists` | `[ -e "$PATH" ]` | `test -e "$PATH"` | `Test-Path $env:PATH` |

### 变量处理规则

- **Bash/Fish/Zsh**: value 保持原样（`$VAR`）
- **PowerShell**: 将 `$VAR` 转换为 `$env:VAR`

## ShellBackend 接口

```python
@dataclass
class ShellBackend:
    name: str                          # Shell 名称
    indent: str                        # 缩进字符串
    export_line: Callable              # 生成 export 语句
    local_line: Callable               # 生成 local 变量语句
    alias_line: Callable               # 生成 alias 语句
    eval_line: Callable                # 生成 eval 语句
    source_line: Callable              # 生成 source 语句
    mkdir_line: Callable               # 生成创建目录语句
    translate_condition: Callable      # 将条件字符串包装为 if 语句
    render_condition: Callable         # 将抽象条件转换为 shell 特定语法
    close_block: str                   # 条件块结束语法
    close_template: str                # Chezmoi 模板结束语法
```

## 渲染流程

1. **遍历 blocks**: 按 shell 过滤（`block.shell`）
2. **处理注释**: 生成 `# comment` 行
3. **创建目录**: 生成 `mkdir` 语句
4. **处理 block condition**:
   - 如果是对象格式：通过 `render_condition()` 转换
   - 如果是字符串格式：通过 `translate_condition()` 包装
5. **处理 env 变量**:
   - 处理 env condition（同 block condition）
   - 根据 `env.type` 生成对应语句
6. **关闭条件块**: 添加 `close_block`

## 使用方法

### 生成所有 shell 脚本

```bash
python generate_env.py --shell all
```

### 生成特定 shell 脚本

```bash
python generate_env.py --shell bash
python generate_env.py --shell fish
python generate_env.py --shell ps1
```

### 指定输出路径

```bash
python generate_env.py --shell bash --output .chezmoitemplates/env.bash
```

## 示例

### env.json 示例

```json
{
  "blocks": [
    {
      "block": "homebrew",
      "comment": ["Homebrew settings"],
      "shell": ["bash", "fish", "zsh"],
      "condition": {
        "type": "executable",
        "value": "brew"
      },
      "env": [
        {
          "key": "BREW",
          "value": "$(which brew 2>/dev/null)",
          "type": "local"
        },
        {
          "key": "HOMEBREW_API_DOMAIN",
          "value": "https://mirrors.ustc.edu.cn/homebrew-bottles/api"
        }
      ]
    },
    {
      "block": "llvm",
      "comment": ["LLVM cmake prefix path"],
      "condition": {
        "type": "not_empty",
        "value": "LLVM_ROOT"
      },
      "env": [
        {
          "key": "CMAKE_PREFIX_PATH",
          "value": "$LLVM_ROOT${CMAKE_PREFIX_PATH:+:$CMAKE_PREFIX_PATH}"
        }
      ]
    }
  ]
}
```

### 生成结果 (bash)

```bash
# Homebrew settings
if [ -x "$(which brew)" ]; then
    BREW=$(which brew 2>/dev/null)
    export HOMEBREW_API_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles/api"
fi

# LLVM cmake prefix path
if [ -n "$LLVM_ROOT" ]; then
    export CMAKE_PREFIX_PATH="$LLVM_ROOT${CMAKE_PREFIX_PATH:+:$CMAKE_PREFIX_PATH}"
fi
```

### 生成结果 (PowerShell)

```powershell
# Homebrew settings
if ((Get-Command brew).Source | Test-Path -PathType Leaf -ErrorAction SilentlyContinue) {
    $BREW = "$(which brew 2>/dev/null)"
    $env:HOMEBREW_API_DOMAIN = "https://mirrors.ustc.edu.cn/homebrew-bottles/api"
}

# LLVM cmake prefix path
if ([string]::IsNullOrEmpty($env:LLVM_ROOT) -eq $false) {
    $env:CMAKE_PREFIX_PATH = "$env:LLVM_ROOT${CMAKE_PREFIX_PATH:+:$CMAKE_PREFIX_PATH}"
}
```

## 设计原则

1. **Shell Independent**: condition 使用抽象语义，自动适配各 shell
2. **YAGNI**: 只实现当前需要的 6 种条件类型
3. **向后兼容**: 支持字符串格式的 condition（legacy）
4. **可扩展**: 新增 shell 只需实现 ShellBackend 接口
