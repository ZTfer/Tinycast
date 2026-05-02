#!/bin/bash
# 本地调试运行脚本
# 自动从 .env 文件加载 Supabase 配置

set -a  # 自动导出所有变量
source .env 2>/dev/null || { echo "⚠️  .env 文件不存在"; exit 1; }
set +a

echo "🚀 启动 TinyCast macOS 调试..."
echo "📡 Supabase URL: ${SUPABASE_URL:0:20}..."

flutter run -d macos \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY" \
  "$@"
