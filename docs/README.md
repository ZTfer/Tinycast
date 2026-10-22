# TinyCast 文档索引

本目录存放 TinyCast 的领域文档与专题手册。根级 [AGENTS.md](../AGENTS.md) 是开发约定与 AI agent 的入口；本文件只负责文档导航。

## 按任务查找

| 你要做的事 | 文档 |
|------------|------|
| 配置 Supabase 凭据、排查初始化 | [guides/supabase_setup.md](guides/supabase_setup.md) |
| 理解本地 Isar 数据库、修改 Collection | [reference/database.md](reference/database.md) |
| 调用下载、暂停/恢复、清理缓存 | [guides/audio_download_usage.md](guides/audio_download_usage.md) |
| 了解下载文件命名与路径规则 | [reference/uuid_filename_guide.md](reference/uuid_filename_guide.md) |
| 下载失败、找不到文件、检索日志 | [debugging/download_debug_guide.md](debugging/download_debug_guide.md) |
| 下载队列不执行或卡住 | [debugging/download_queue_debug.md](debugging/download_queue_debug.md) |
| 云同步不生效、步骤失败、删除未传播 | [debugging/sync_debug_guide.md](debugging/sync_debug_guide.md) |
| 处理各平台沙盒、权限与文件访问 | [reference/platform_permissions.md](reference/platform_permissions.md) |
| 理解或扩展 HOCON 主题 | [theme/overview.md](theme/overview.md)、[colors.md](theme/colors.md)、[typography.md](theme/typography.md) |
| 查看原生多客户端 monorepo 重构方案 | [superpowers/specs/2026-10-22-native-monorepo-design.md](superpowers/specs/2026-10-22-native-monorepo-design.md) |

## 目录结构

```text
docs/
├── guides/        # 配置与使用：Supabase、下载 API
├── debugging/     # 故障排查：同步、下载、下载队列
├── reference/     # 事实与规格：数据库、平台权限、文件命名
├── theme/         # HOCON 主题系统
└── superpowers/   # 设计与实施规格
```

## 文档约定

- 文档描述仓库当前的 Flutter 实现；`superpowers/` 下的重构设计是提案，不代表已经落地。
- 新增专题文档按用途放入对应目录，并在本索引补一行；文件名使用 snake_case，设计规格沿用 `superpowers/` 的日期前缀命名。
- 文档之间的链接使用相对路径，移动文件时同步修正引用。
