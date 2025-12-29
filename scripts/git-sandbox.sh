# ga [branch]: 创建隔离的 AI 实验环境
# 逻辑：在兄弟目录创建 "RepoName--BranchName" 格式的 worktree，若分支存在则复用，不存在则新建。
ga() {
  [[ -z "$1" ]] && echo "Usage: ga <branch>" && return 1
  
  local branch="$1"
  local root repo path
  
  # 获取仓库根目录与名称（支持在子目录运行）
  root="$(git rev-parse --show-toplevel 2>/dev/null)" || return 1
  repo="$(basename "$root")"
  path="../${repo}--${branch}"

  # 创建或检出 Worktree
  if git show-ref --verify --quiet "refs/heads/$branch"; then
    git worktree add "$path" "$branch"
  else
    git worktree add -b "$branch" "$path"
  fi

  # 环境信任与跳转
  command -v mise &>/dev/null && mise trust "$path"
  cd "$path" || return 1
}

# gd: 销毁当前 AI 实验环境
# 逻辑：检查是否在 Worktree 中，确认后强制清理当前目录及对应分支，并安全退回上一级。
gd() {
  # 安全检查：防止在主仓库执行
  if [[ "$(git rev-parse --git-dir)" == "$(git rev-parse --git-common-dir)" ]]; then
    echo "⚠️  Error: You are in the MAIN repository. Aborting."
    return 1
  fi

  local branch path
  branch="$(git branch --show-current)"
  path="$(pwd)"

  # 交互确认 (优先使用 gum)
  if command -v gum &>/dev/null; then
    gum confirm "🔥 Nuke worktree and branch '$branch'?" || return 1
  else
    read -p "🔥 Nuke worktree and branch '$branch'? [y/N] " -r
    [[ ! $REPLY =~ ^[Yy]$ ]] && return 1
  fi

  # 执行清理
  cd ..
  git worktree remove "$path" --force
  git branch -D "$branch"
}