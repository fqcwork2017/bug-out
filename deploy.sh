#!/bin/bash

# Flutter Web 部署脚本
# 部署到 GitHub Pages: fqcwork20217.github.io

set -e

echo "🚀 开始构建 Flutter Web 应用..."
flutter build web --release

echo "📦 克隆 GitHub 仓库..."
REPO_URL="git@github.com:fqcwork2017/fqcwork20217.github.io.git"
DEPLOY_DIR="deploy_temp"

# 如果目录存在则删除
if [ -d "$DEPLOY_DIR" ]; then
    rm -rf "$DEPLOY_DIR"
fi

# 克隆仓库
git clone "$REPO_URL" "$DEPLOY_DIR" || {
    echo "⚠️  仓库可能已存在，尝试拉取最新内容..."
    mkdir -p "$DEPLOY_DIR"
    cd "$DEPLOY_DIR"
    git init
    git remote add origin "$REPO_URL" || git remote set-url origin "$REPO_URL"
    git pull origin main || echo "仓库为空，继续..."
    cd ..
}

echo "📋 复制构建文件..."
cd "$DEPLOY_DIR"

# 删除旧文件（保留 .git）
find . -mindepth 1 ! -name '.git' -delete

# 复制新的构建文件
cp -r ../build/web/* .

echo "💾 提交更改..."
git add -A
git commit -m "Deploy Flutter Web app - $(date '+%Y-%m-%d %H:%M:%S')" || echo "没有更改需要提交"

echo "🚀 推送到 GitHub..."
git push -u origin main || {
    echo "❌ 推送失败！"
    echo ""
    echo "可能的原因："
    echo "1. 没有写入权限 - 请确认你是仓库的协作者"
    echo "2. 仓库名称错误 - 请确认仓库地址是否正确"
    echo "3. SSH 密钥问题 - 请确认 SSH 密钥已添加到 GitHub"
    echo ""
    echo "你可以："
    echo "1. 检查仓库权限设置"
    echo "2. 手动执行: cd $DEPLOY_DIR && git push -u origin main"
    exit 1
}

echo "✅ 部署成功！"
echo "🌐 你的应用将在以下地址可用："
echo "   https://fqcwork2017.github.io/fqcwork20217.github.io/"

cd ..
rm -rf "$DEPLOY_DIR"

echo "🎉 部署完成！"

