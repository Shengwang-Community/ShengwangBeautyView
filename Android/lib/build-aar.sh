#!/bin/bash

# AAR 打包脚本
# 使用方法: 在项目根目录运行 ./lib/build-aar.sh 或在 lib 目录运行 ./build-aar.sh

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# 项目根目录（lib 的父目录）
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# 切换到项目根目录
cd "$PROJECT_ROOT"

echo "=========================================="
echo "开始打包 Shengwang Beauty Control View AAR"
echo "=========================================="

# 检查是否在项目根目录
if [ ! -f "build.gradle" ] && [ ! -f "build.gradle.kts" ]; then
    echo "错误: 找不到项目根目录，请确保在正确的目录运行此脚本"
    exit 1
fi

# 清理之前的构建
echo ""
echo "1. 清理之前的构建..."
./gradlew clean

# 打包 Release AAR（lib 模块）
echo ""
echo "2. 打包 Release AAR（lib 模块）..."
./gradlew :lib:assembleRelease

# 检查 AAR 文件是否生成
AAR_PATH="lib/build/outputs/aar/lib-release.aar"
if [ -f "$AAR_PATH" ]; then
    echo ""
    echo "=========================================="
    echo "✅ AAR 打包成功！"
    echo "=========================================="
    echo ""
    echo "AAR 文件位置: $AAR_PATH"
    echo ""
    
    # 显示文件大小
    FILE_SIZE=$(du -h "$AAR_PATH" | cut -f1)
    echo "文件大小: $FILE_SIZE"
    echo ""
    
    # 创建发布目录
    RELEASE_DIR="release"
    mkdir -p "$RELEASE_DIR"
    
    # 复制 AAR 文件到发布目录
    # 注意：lib 模块不支持 versionName，使用固定版本号或从文件名获取
    VERSION_NAME="1.0.0"
    RELEASE_AAR="$RELEASE_DIR/shengwang-beauty-view-${VERSION_NAME}.aar"
    cp "$AAR_PATH" "$RELEASE_AAR"
    
    echo "已复制到: $RELEASE_AAR"
    echo ""
    echo "=========================================="
    echo "📦 打包完成！"
    echo "=========================================="
    echo ""
    echo "注意：AAR 中 RTC SDK 为 compileOnly，客户需要自己添加依赖"
else
    echo ""
    echo "❌ 错误: AAR 文件未找到"
    echo "请检查构建日志"
    exit 1
fi
