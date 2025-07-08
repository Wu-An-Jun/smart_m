#!/bin/bash

# 设置代理
export https_proxy=http://127.0.0.1:7890 
export http_proxy=http://127.0.0.1:7890 
export all_proxy=socks5://127.0.0.1:7890

echo "开始同步代码到GitHub..."

# 添加所有更改
git add .

# 获取当前时间作为提交信息
COMMIT_MSG="自动同步更新: $(date '+%Y-%m-%d %H:%M:%S')"

# 提交更改
git commit -m "$COMMIT_MSG"

# 推送到GitHub
git push -u origin main

echo "同步完成！" 