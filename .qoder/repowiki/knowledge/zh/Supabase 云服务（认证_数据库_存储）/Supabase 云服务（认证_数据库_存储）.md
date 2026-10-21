---
kind: external_dependency
name: Supabase 云服务（认证/数据库/存储）
slug: supabase
category: external_dependency
category_hints:
    - vendor_identity
    - auth_protocol
scope:
    - '**'
---

### Supabase 云服务
- 角色：用户认证、云同步、远程数据库与存储的 BaaS 提供方
- 配置方式：`run.sh` 读取 `.env` 后转成 `--dart-define`；应用只读取编译时变量，未配置时跳过初始化不影响其他功能
- 使用模式：通过 Riverpod Provider `supabaseClientProvider` 获取 `SupabaseClient`；Session 持久化由 `flutter_secure_storage` 管理
- 验证：具体 API/参数以官方文档为准