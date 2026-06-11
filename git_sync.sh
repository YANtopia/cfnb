#!/bin/bash
# git_sync.sh
# 功能：将当前目录下的 ip.txt 文件强制推送到 GitHub 仓库的指定分支
# 使用场景：配合 Cloudflare IP 优选工具，自动同步优选结果到远程仓库
#
# ⚠️ 安全提醒：使用前请将下方的 github_token 替换为你自己的 GitHub Personal Access Token
#    切勿将真实令牌提交到公开仓库！

# ==================== GitHub 认证信息（请修改为你的信息） ====================
# 个人访问令牌（Personal Access Token），用于身份验证
github_token="YOUR_GITHUB_TOKEN_HERE"
# GitHub 用户名
github_username="YANtopia"
# 仓库名称
repo_name="cfnb"
# 目标分支
branch="main"

# ==================== 代理设置 ====================
# 保存当前代理设置
_OLD_HTTP_PROXY="$http_proxy"
_OLD_HTTPS_PROXY="$https_proxy"
_OLD_ALL_PROXY="$ALL_PROXY"

# 设置代理（如果未设置）
if [ -z "$http_proxy" ]; then
  export http_proxy="http://127.0.0.1:7890"
  export https_proxy="http://127.0.0.1:7890"
  export ALL_PROXY="http://127.0.0.1:7890"
fi

# ==================== 切换到脚本所在目录 ====================
cd "$(dirname "$0")" || exit 1

# ==================== 拉取远程最新更新 ====================
git pull origin "$branch"

# ==================== 暂存并提交 ip.txt ====================
git add ip.txt
commit_msg="Update ip.txt on $(date '+%Y-%m-%d %H:%M:%S')"
git commit -m "$commit_msg"

# ==================== 强制推送到 GitHub ====================
git push "https://${github_token}@github.com/${github_username}/${repo_name}.git" "$branch" --force

# ==================== 恢复代理设置 ====================
export http_proxy="$_OLD_HTTP_PROXY"
export https_proxy="$_OLD_HTTPS_PROXY"
export ALL_PROXY="$_OLD_ALL_PROXY"
export HTTP_PROXY="$http_proxy" HTTPS_PROXY="$https_proxy" all_proxy="$ALL_PROXY"

echo "✅ ip.txt 已推送到 GitHub"