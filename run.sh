#!/bin/bash
# 本地调试运行脚本
# 自动从 .env 文件加载 Supabase 配置
# 支持传入平台参数：iOS / ios / Android / android
# 默认使用 macOS 桌面平台

set -a  # 自动导出所有变量
source .env 2>/dev/null || { echo "⚠️  .env 文件不存在"; exit 1; }
set +a

# 解析传入的平台参数（不区分大小写）
INPUT_DEVICE=""
if [ -n "$1" ]; then
  INPUT_DEVICE=$(echo "$1" | tr '[:upper:]' '[:lower:]')
fi

# 根据输入参数选择运行平台
case "$INPUT_DEVICE" in
  ios)
    FLUTTER_DEVICE="${iOS_Device_ID:-iphone}"
    echo "🚀 启动 TinyCast iOS 调试..."
    ;;
  android)
    FLUTTER_DEVICE="${Android_Device_ID}"
    if [ -z "$FLUTTER_DEVICE" ] || [ "$FLUTTER_DEVICE" = "your-android-device-id-here" ]; then
      echo "⚠️  .env 文件中未配置有效的 Android_Device_ID"
      echo "📋 请修改 .env 文件中的 Android_Device_ID 字段"
      exit 1
    fi
    echo "🚀 启动 TinyCast Android 调试 (设备ID: $FLUTTER_DEVICE)..."
    ;;
  *)
    # 默认行为：检测操作系统并选择对应的桌面平台
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
    ;;
esac

echo "📡 Supabase URL: ${SUPABASE_URL:0:20}..."

# 移除已处理的平台参数，避免传递给 flutter run
shift

flutter run -d "$FLUTTER_DEVICE" \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY" \
  "$@"
