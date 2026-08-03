---
kind: external_dependency
name: Isar 本地 NoSQL 嵌入式数据库
slug: isar
category: external_dependency
category_hints:
    - sdk_real_api
    - framework_behavior
scope:
    - '**'
---

### Isar 本地数据库
- 角色：Flutter 生态高性能嵌入式 NoSQL 数据库，存储播客订阅、剧集、收藏、播放历史、队列与应用设置
- Schema 代码生成：通过 `build_runner` 运行 `isar_community_generator` 生成 `*.g.dart` 中的 Schema
- 行为要点：字段修改后需重新生成 schema；新增字段自动使用默认值完成迁移；PlayHistory 采用软删除 (`isDeleted`) 而非物理删除
- 验证：具体集合定义与查询 API 以 `docs/database.md` 和源码为准