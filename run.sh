#!/bin/bash
# 本地调试运行脚本
# 自动从 .env 文件加载 Supabase 配置
# 根据操作系统自动选择 Flutter 运行平台

set -a  # 自动导出所有变量
source .env 2>/dev/null || { echo "⚠️  .env 文件不存在"; exit 1; }
set +a

# 检测操作系统并选择对应的 Flutter 运行平台
OS_TYPE=$(uname -s)
case "$OS_TYPE" in
  Darwin)
    FLUTTER_DEVICE="macos"
    echo "🚀 启动 TinyCast macOS 调试..."
    ;;
  Linux)
    FLUTTER_DEVICE="linux"
    echo "🚀 启动 TinyCast Linux 调试..."
    ;;
  MINGW*|MSYS*|CYGWIN*)
    FLUTTER_DEVICE="windows"
    echo "🚀 启动 TinyCast Windows 调试..."
    ;;
  *)
    echo "❌ 不支持的操作系统: $OS_TYPE"
    echo "📋 支持的操作系统: macOS, Linux, Windows"
    exit 1
    ;;
esac

echo "📡 Supabase URL: ${SUPABASE_URL:0:20}..."

flutter run -d "$FLUTTER_DEVICE" \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY" \
  "$@"
