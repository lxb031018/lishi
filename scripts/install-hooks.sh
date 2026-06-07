# =============================================================================
# 安装所有 git hooks 到本仓库
# 用法:  bash scripts/install-hooks.sh
# =============================================================================

set -e

REPO_ROOT="$(git rev-parse --show-toplevel)"
HOOKS_DIR="$REPO_ROOT/.githooks"

if [ ! -d "$HOOKS_DIR" ]; then
  echo "❌ 找不到 $HOOKS_DIR"
  exit 1
fi

# 把 .githooks 设为全局 hooks 路径
git config core.hooksPath .githooks

# 给所有 hook 加执行权限 (Windows Git Bash 也认这个)
chmod +x "$HOOKS_DIR"/* 2>/dev/null || true

echo "✅ hooks 已就位 (core.hooksPath = .githooks)"
echo "   当前启用的 hooks:"
ls -1 "$HOOKS_DIR" | sed 's/^/     - /'
