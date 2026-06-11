#!/bin/bash
# git_sync.sh

# ==================== GitHub 认证信息 ====================
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
github_token="$(cat "$SCRIPT_DIR/.github_token" 2>/dev/null | tr -d '[:space:]')"
github_username="YANtopia"
repo_name="cfnb"
branch="main"
REMOTE_URL="https://${github_token}@github.com/${github_username}/${repo_name}.git"

if [ -z "$github_token" ]; then
  echo "❌ .github_token 文件不存在或为空，跳过推送" >&2
  exit 1
fi

# ==================== 代理设置 ====================
_OLD_HTTP_PROXY="$http_proxy"
_OLD_HTTPS_PROXY="$https_proxy"
_OLD_ALL_PROXY="$ALL_PROXY"
if [ -z "$http_proxy" ]; then
  export http_proxy="http://127.0.0.1:7890"
  export https_proxy="http://127.0.0.1:7890"
  export ALL_PROXY="http://127.0.0.1:7890"
fi

cd "$SCRIPT_DIR" || exit 1

# ==================== 拉取远程最新更新 ====================
git fetch "$REMOTE_URL" "$branch":refs/remotes/origin/"$branch" --no-tags 2>/dev/null || true

# ==================== 暂存并提交 ip.txt ====================
git add ip.txt
commit_msg="Update ip.txt on $(date '+%Y-%m-%d %H:%M:%S')"
git commit -m "$commit_msg" || true   # 若无变化则跳过

# ==================== 强制推送到 GitHub ====================
if git push "$REMOTE_URL" "$branch" --force; then
  echo "✅ ip.txt 已推送到 GitHub"
else
  echo "❌ git push 失败" >&2
  exit 1
fi

# ==================== 恢复代理设置 ====================
[ -n "$_OLD_HTTP_PROXY" ]  && export http_proxy="$_OLD_HTTP_PROXY"  || unset http_proxy HTTP_PROXY
[ -n "$_OLD_HTTPS_PROXY" ] && export https_proxy="$_OLD_HTTPS_PROXY" || unset https_proxy HTTPS_PROXY
[ -n "$_OLD_ALL_PROXY" ]   && export ALL_PROXY="$_OLD_ALL_PROXY" all_proxy="$_OLD_ALL_PROXY" || unset ALL_PROXY all_proxy
