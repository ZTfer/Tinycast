---
kind: external_dependency
name: HTTP 客户端与 HTTP/2 适配器
slug: dio
category: external_dependency
category_hints:
    - sdk_real_api
scope:
    - '**'
---

### Dio HTTP 客户端
- 角色：统一网络请求层，支持拦截器、重试、HTTP/2 适配
- 集成点：`dio_http2_adapter` 作为底层传输实现；`connectivity_plus` 检测 WiFi/蜂窝/无网络状态
- 行为要点：下载任务通过 Dio 发起，配合断点续传与并发控制（默认最多 3 个并行）
- 验证：具体拦截器/适配器用法以官方文档为准