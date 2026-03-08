#!/bin/bash

# 捕获 chezmoi data 的 JSON 输出
JSON_OUTPUT=$(chezmoi data -f json)

# 使用 jq 递归遍历所有字段（跳过 chezmoi），找出值为空的字符串字段并输出警告
echo "$JSON_OUTPUT" | jq -r '
    # 定义递归遍历函数：参数1=当前路径，参数2=当前值（jq 1.7 要求参数用;分隔）
    def walk_empty(path_arr; val):
        val as $val
        | if $val | type == "object" then
            # 遍历对象的所有键
            $val | keys[] as $k
            | if $k == "chezmoi" then
                empty  # 跳过 chezmoi 字段
              else
                # 递归遍历子字段，路径追加当前键
                walk_empty(path_arr + [$k]; $val[$k])
              end
          elif $val | type == "string" and $val == "" then
            # 将路径数组转为点分隔的字符串（如 language.cpp.cc）
            (path_arr | join(".")) as $full_path
            | "WARNING: \($full_path) is empty. Set it in ~/.config/chezmoi/chezmoi.toml"
          else
            empty  # 非空字符串/非对象类型跳过
          end;

    # 启动递归：初始路径为空数组，初始值为整个JSON
    walk_empty([]; .)
'