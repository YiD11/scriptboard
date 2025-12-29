#!/bin/bash

# 定义源目录（当前仓库路径）和目标目录
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$HOME/.scripts"

echo "🚀 Starting installation from $REPO_DIR to $TARGET_DIR..."

# 如果目标目录不存在，创建它
if [ ! -d "$TARGET_DIR" ]; then
    echo "📂 Creating directory $TARGET_DIR..."
    mkdir -p "$TARGET_DIR"
fi

# 遍历仓库里所有的 .sh 文件
for script in "$REPO_DIR"/scripts/*.sh; do
    filename=$(basename "$script")

    # 创建软链接 (ln -sf: s=soft, f=force 覆盖旧的)
    echo "🔗 Linking $filename..."
    ln -sf "$script" "$TARGET_DIR/$filename"
done

echo "✅ Installation complete!"
echo "------------------------------------------------"
echo "👉 Add the following line to your ~/.zshrc or ~/.bashrc to load them:"
echo ""
echo "   source $TARGET_DIR/*.sh"
echo ""
echo "------------------------------------------------"