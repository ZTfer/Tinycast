# TinyCast 原生多客户端 Monorepo 重构设计

- 状态：待评审
- 日期：2026-10-22
- 决策：方案 B — 三端独立实现 + 共享契约
- 影响范围：仓库组织、客户端架构、后端契约、交付流程
- 不包含：具体代码实现、存量数据迁移、服务端功能重写

## 1. 背景与约束

### 1.1 当前仓库事实

- 当前是单一 Flutter 客户端，覆盖 Android、iOS、macOS、Windows、Linux；仓库中另有 `web/` 目录，但不在产品目标内。
- `lib/` 下 267 个 Dart 文件、约 57,785 行，其中约 2 万行是 Isar 生成代码；`test/` 下 29 个文件、约 8,013 行。
- 架构为 Presentation / Domain / Data 三层，Riverpod 3 状态管理，Isar Community 本地数据库，自定义 `AppRouter`，HOCON 主题系统，Supabase 云同步。
- 现有能力：RSS 订阅与定时刷新、后台播放与锁屏控制、播放队列、收藏、播放历史、单个/批量/整档下载、缓存清理、本地搜索、设置、Supabase 登录与增量同步。
- 当前 Flutter 工程的部署下限是 iOS 14、macOS 10.15；Android 使用 Flutter 默认 `minSdk`。
- 后端是 Supabase。仓库内 `supabase/` 只有 `.temp/`，没有 migrations、RLS 策略或 seed 文件，真实 schema 只存在于远端项目。
- 测试夹具只有一个 RSS 样本：`test/test-data/anyway_rss.xml`。
- 文档与代码存在一处不一致：`README.md` 和 `AGENTS.md` 把 OPML 导入列为已有功能，但 `lib/presentation/features/subscribe/subscribe_by_opml/opml_import_form.dart` 只实现了文件选择，`onFileSelected` 没有被接线，导入逻辑实际不存在。本设计按“未实现”处理，并把修正文档列为 P0 任务。
- 现有同步的核心行为集中在 `lib/core/services/sync_service.dart`（1,694 行）、`lib/data/datasources/remote_sync_datasource.dart`（458 行）和 `lib/core/services/sync_tombstone_store.dart`（228 行）。这些文件是本设计第 3 节的事实来源。

### 1.2 重构动因

以下四项同时成立：

- 原生体验与系统集成：CarPlay、Android Auto、桌面小组件、App Intents、Live Activities、系统媒体控制、原生手势与无障碍等能力，Flutter 难以完整覆盖。
- 性能与稳定性：启动速度、大列表滚动、播放与下载稳定性、内存占用需要更直接的控制。
- 技术栈与协作分工：各平台由熟悉 Swift、Kotlin、Flutter 的维护者分别负责。
- 技术探索与长期布局：愿意承担更高成本，为长期产品形态做准备。

### 1.3 约束

- 长期维护人力为 1–2 人。
- 当前没有真实用户，可以清库、重装，不需要迁移旧 Isar 数据。
- 用户已明确选择“三端独立实现 + 共享契约”，不引入 KMP 或 Rust 共享运行时。
- 现有 Flutter 客户端在过渡期仍需可构建、可运行，作为 Windows/Linux 客户端和功能参考实现。
- 项目当前没有托管 CI。拆分后 CI 从“可选”变成“必需”。

### 1.4 方案对比与选择

评估过三条路线：

- 方案 A：KMP 共享内核 + 原生 UI。Kotlin 写一次领域与数据层，Android 直接使用，Apple 通过 KMP framework 使用；桌面 Flutter 短期保留 Dart 实现。优点是业务逻辑只写一次；代价是 KMP→Swift 桥接、Kotlin/Native 构建以及桌面端逻辑重复。
- 方案 B：三端独立实现 + 共享契约。Swift、Kotlin、Dart 各自实现领域与数据层，只共享后端 schema、同步协议、解析夹具、设计 token 和功能矩阵。工具链最简单、每端最地道；代价是三套业务逻辑，长期维护成本最高。
- 方案 C：Rust 共享内核 + FFI。Rust 写一次内核，UniFFI 供 Swift/Kotlin，flutter_rust_bridge 供 Dart。共享最彻底；代价是新增 Rust 与三层 FFI 构建链。

选择方案 B。理由是它满足“每端用原生语言、工具链相互独立”的目标，同时不引入第四种语言或跨语言运行时。B 的代价必须通过契约测试、黄金用例和分阶段交付来控制，否则三端会迅速漂移。

### 1.5 目标与非目标

目标：

- 建立 monorepo，三个客户端各自使用原生技术栈，构建系统相互独立。
- 建立唯一的后端 schema、同步协议、RSS 归一化契约、设计 token 和功能矩阵。
- 现有 Flutter 客户端迁移为 Windows/Linux 桌面客户端，并在过渡期保持可运行。
- 用可执行的黄金用例约束三端行为一致。
- 按平台逐个交付，每阶段有明确退出标准，不并行重写三端。

非目标：

- 不共享领域模型、用例、数据库、播放器、下载实现、后台调度、凭证存储或 UI 代码。
- 不追求三端像素级一致的界面；交互遵循各平台习惯。
- 不让桌面端承担新功能首发；桌面端是二级客户端。
- 不迁移旧 Isar 数据；不保留旧本地数据库兼容层。
- 不在本设计中重写 Supabase 服务端；只补齐 schema 版本化、协议版本和安全审计。
- 不在 v1 契约中支持 Atom feed。现有解析器只处理 RSS 2.0 的 `channel`/`item` 结构；Atom 支持属于新功能。

## 2. 总体架构

### 2.1 仓库布局

```text
tinycast/
├── apps/
│   ├── apple/
│   │   ├── TinyCast.xcworkspace
│   │   ├── TinyCastApp/              # iOS 与 macOS 应用 target
│   │   └── Packages/
│   │       ├── TinyCastKit/          # 领域、用例、同步引擎、RSS 解析、远端 API
│   │       ├── TinyCastData/         # GRDB、迁移、文件存储、Keychain
│   │       └── TinyCastDesign/       # 生成的 token 与共享 SwiftUI 组件
│   ├── android/
│   │   ├── app/
│   │   ├── core/                     # model、data、network、database
│   │   ├── designsystem/
│   │   └── feature/                  # subscriptions、player、library、settings
│   └── desktop/                      # 现有 Flutter 应用，Windows/Linux
│       ├── lib/
│       ├── test/
│       ├── assets/
│       ├── windows/
│       ├── linux/
│       ├── android/                  # 过渡期保留，P3 删除
│       ├── ios/                      # 过渡期保留，P3 删除
│       ├── macos/                    # 过渡期保留，P3 删除
│       ├── web/                      # 过渡期保留，P3 决定是否删除
│       ├── run.sh                    # 原根目录调试脚本
│       └── pubspec.yaml
├── packages/
│   ├── contracts/
│   │   ├── schema/                   # schema 说明、OpenAPI 快照、字段映射
│   │   ├── sync/                     # 同步协议 v1 与黄金用例
│   │   ├── feeds/                    # RSS/OPML 样本与期望归一化 JSON
│   │   └── parity/                   # 功能矩阵与平台差异
│   ├── design/
│   │   ├── generator/                # HOCON → Swift/Kotlin/Dart 生成器
│   │   └── generated/                # 入库的生成物
│   └── i18n/                         # 文案 key 与翻译源（第二阶段）
├── supabase/
│   ├── config.toml
│   ├── migrations/
│   └── seed.sql
├── docs/
├── scripts/
├── justfile
├── VERSION
├── README.md
└── AGENTS.md
```

### 2.2 共享与不共享的边界

共享的内容只以文本、数据和生成物形式存在，不引入跨语言运行时：

- Supabase 表结构、索引、RLS、冲突键和迁移历史。
- 同步协议 v1：拉取顺序、推送顺序、分页与分块大小、合并规则、墓碑、失败语义、游标推进规则。
- 同步与解析的黄金用例：输入是 JSON/XML，输出是期望的本地状态或归一化结果。
- RSS 2.0 与 iTunes 命名空间的归一化规则，以及 OPML 导入的目标行为。
- 设计 token：颜色、字体、字号、间距、圆角、阴影，按 light/dark 和 desktop/tablet/mobile 变体生成。
- 功能矩阵与平台差异清单。
- 文档与故障排查手册。

不共享的内容：

- 领域模型、用例、仓库接口和业务规则实现。
- 本地数据库 schema、查询、迁移和 ORM。
- 音频播放、后台播放、锁屏控制、CarPlay/Android Auto。
- 下载传输、断点续传、文件存储和缓存清理实现。
- 后台刷新调度、通知、小组件、App Intents 等平台能力。
- 凭证存储和会话管理。
- UI 组件、导航和交互。

共享边界带来的直接后果：一个行为修复可能需要在三端各做一次。缓解手段是黄金用例、功能矩阵和 PR 检查清单，而不是共享代码。

### 2.3 工具链原则

- 每个 app 保持自包含：Apple 用 Xcode workspace 与 Swift Package Manager；Android 用 Gradle；桌面用 Flutter 工具链。
- 根目录只提供任务封装，不参与各平台的编译。建议使用 `justfile`：
  - `just bootstrap`：安装/检查各平台工具链与依赖。
  - `just generate`：生成设计 token 与各平台资源。
  - `just contract-test`：运行各端已接入的契约用例；未接入的端明确标记为跳过并写入报告。
  - `just desktop-test`、`just android-test`、`just apple-test`：运行各端测试与构建。
  - `just ci`：本地 CI 入口，依次执行契约、桌面、Android、Apple 的检查。
- 不引入 Turborepo、Nx 或跨语言构建插件。三套构建系统之间只通过文件和命令交互。
- 每个平台自有 `.gitignore` 规则；仓库统一 LF 换行，遵守现有跨平台文件名与路径约束。
- 版本号由一个根 `VERSION` 文件维护产品版本，各平台构建号独立；发布脚本把版本注入各端。

## 3. 契约层

### 3.1 Supabase schema 与 migrations

P0 的第一项硬任务是把远端 schema 落进仓库。当前仓库没有任何 migrations，三端无法据此实现。

执行步骤：

1. 使用 Supabase CLI 关联远端项目，执行 `supabase db pull` 拉取 `public` schema；或者用 `pg_dump --schema-only` 导出。
2. 把表、索引、外键、RLS 策略、触发器和函数写入 `supabase/migrations/`，按时间顺序命名；其中包含 3.3.3 所需的 `server_updated_at` 列、触发器和索引。
3. 增加 `supabase/config.toml` 和 `supabase/seed.sql`，保证本地可以 `supabase start` 启动一套测试数据库。
4. 从 PostgREST 的 OpenAPI 端点导出快照，保存到 `packages/contracts/schema/openapi.json`。快照用于对照字段、类型和可空性，不作为代码生成器的唯一来源。
5. 在 `packages/contracts/schema/README.md` 记录每张表的用途、写入方、冲突键、RLS 假设，以及 `server_updated_at` 的维护方式。

同步涉及的表：

- `podcasts`：全局播客目录，冲突键 `itunes_id`。
- `episodes`：全局剧集目录，冲突键 `(guid, podcast_id)`。
- `user_podcast_subscriptions`：用户订阅，冲突键 `(user_id, podcast_id)`。
- `playback_history`：用户播放历史，冲突键 `(user_id, episode_id)`。
- `favorites`：用户收藏，冲突键 `(user_id, episode_id)`。
- `queue_items`：用户播放队列，冲突键 `(user_id, episode_id)`。
- `profiles`：用户资料；同步开始时确保当前用户记录存在，失败不阻塞同步。

增量游标不能依赖客户端写入的内容时间。`podcasts.updated_at`、`episodes.updated_at` 与 `playback_history.last_update_time` 都由客户端按内容时间写入，旧 feed 的更新时间可能早于其他设备的游标，导致新上传的记录永远不会被增量拉到。P0 在三张表增加服务端管理的 `server_updated_at timestamptz not null default now()`，由 `insert/update` 触发器强制设为 `now()`，并建立 `(server_updated_at, id)` 索引；触发器必须覆盖客户端传入的值，不能只靠客户端约定。若 P0 无法修改 schema，三张增量表必须降级为全量拉取，并把该降级列为 v1 已知缺陷；不得静默把 `updated_at` 当作可信游标。

`podcasts` 和 `episodes` 是全局目录，不属于单个用户。当前客户端直接 upsert 目录数据；远端 RLS 策略尚未入库，仓库内无法确认写入边界。P0 必须审计 RLS，确认是否存在跨用户篡改风险。若策略过宽，在阶段 P1 把目录写入收敛到受校验的 RPC 或 Edge Function，客户端只读目录。

### 3.2 传输 DTO 与字段映射

- 传输格式是 PostgREST 的 JSON，字段名为 snake_case；时间统一为 UTC ISO-8601 字符串。
- 三端手写传输 DTO（Swift Codable、Kotlin kotlinx.serialization、Dart 手动映射），不做跨语言代码生成。原因是同步业务表只有六张（不含 `profiles`），1–2 人维护生成器的成本高于收益；契约测试负责防止漂移。
- OpenAPI 快照和真实 payload 样本入库；每端的 DTO 解码测试必须覆盖这些样本。
- 领域模型与传输 DTO 分离。传输 DTO 只描述线上字段；领域模型包含本地字段、UI 状态和平台能力。
- 可空字段的语义必须明确：
  - 字段缺失表示“本次不更新该字段”；插入新行时，缺失字段使用服务端默认值。
  - 字段显式为 `null` 表示“清空该字段”。
  - 三端在 push 映射中遵循同一规则，不允许把本地默认值无条件覆盖云端。
- 关键映射约束：
  - `podcasts` 推送要求 `itunes_id` 非空。没有 iTunes ID 的播客只保存在本地，不参与云同步；这是 v1 的已知限制，见第 8 节。
  - `episodes` 推送要求 `guid` 非空，并且所属播客已经有云端 ID；`podcast_id` 由本地播客的云端 ID 解析得到。
  - `playback_history`、`favorites`、`queue_items` 推送要求关联剧集已经有云端 ID。
  - 推送返回的行必须用于回写本地云端 ID；分块推送时每块都要回写，避免尾部记录丢失映射。
- 协议版本：客户端在每个同步请求上带 `X-TinyCast-Sync-Protocol: 1`。v1 不要求服务端强制校验；破坏性变更必须升级到 v2，并通过新表、新列或服务端网关实现，不得原地改变 v1 语义。

### 3.3 同步协议 v1

本节把现有 Dart 实现固化为跨端协议。三端必须实现同一套状态机，不得各自发明合并规则。

#### 3.3.1 前置条件与触发

同步只在以下条件全部满足时执行：

- Supabase 已用真实凭据初始化。
- 用户已登录。
- 当前客户端支持协议 v1。

触发时机统一为：

- 登录成功后立即同步一次。
- 应用回到前台时同步一次。
- 应用在前台时每 5 分钟同步一次。
- 任意会被同步的本地写操作（订阅、取消订阅、收藏、取消收藏、队列变更、播放进度/历史变化、Feed 刷新写入的播客/剧集变更）触发 10 秒防抖同步；连续操作只保留最后一次。
- 用户在设置页手动触发。
- 账号切换时，先清理旧账号的本地数据与同步簿记，再为新账号同步。
- 登出时停止周期同步，并清理该用户的 `lastSyncTime`、墓碑和推送快照。

同一时刻只允许一轮同步。已有同步进行中时，新的触发返回 `skipped`（忙），不排队。前置条件不满足时同样返回 `skipped`，不发起网络请求，也不改变游标。

与当前实现的差异：

- 当前只有播放行为接入 10 秒防抖；收藏、队列、订阅要等 5 分钟周期同步。v1 统一为所有本地写操作都触发防抖同步。
- 当前没有“回到前台同步”。v1 增加这一触发点。
- v1 不保证后台同步。用户数据同步只在前台运行；后台只允许刷新 Feed 和下载，具体由各平台能力决定。

#### 3.3.2 同步循环

一轮同步固定执行以下步骤：

1. 确保 `profiles` 中存在当前用户记录（`ensure_profile`，失败只记录，不阻塞同步）。
2. 读取当前用户的 `lastSyncTime`、待删除墓碑、最后一次成功推送的订阅快照。
3. 计算拉取起点 `pullSince = lastSyncTime - 2 分钟`；首次同步为 `null`，表示全量拉取。
4. 按固定顺序拉取并合并：播客、剧集、订阅、播放历史、收藏、队列。
5. 任意一个拉取请求失败，立即中止本轮，跳过推送，返回 `pullFailed`，不推进游标。
6. 拉取合并失败不中止后续拉取，但记录失败步骤，并跳过该实体的推送步骤；游标不推进。
7. 按固定顺序推送：播客、剧集、订阅、播放历史、收藏、队列；跳过本轮合并失败的实体。
8. 每个推送步骤独立容错；某一步失败后继续执行剩余推送步骤，但记录失败步骤，游标不推进。
9. 只有全部拉取、合并、推送步骤成功，才推进游标 `lastSyncTime`：取本轮增量拉取观察到的最大 `server_updated_at`，不使用本地完成时间；若本轮没有观察到任何增量行，游标保持原值。同时单独记录本地完成时间供 UI 展示，不参与游标。返回 `success`。
10. 存在任何记录在案的失败步骤，返回 `partial`，游标保持原值，下一轮重试同一窗口。
11. 未预期异常返回 `failed`，游标不推进。

步骤名在三端保持一致，便于跨平台日志检索和用例断言：

- 拉取：`pull_podcasts`、`pull_episodes`、`pull_subscriptions`、`pull_playback_history`、`pull_favorites`、`pull_queue_items`。
- 推送：`push_podcasts`、`push_episodes`、`push_subscriptions`、`push_playback_history`、`push_favorites`、`push_queue_items`。
- 资料：`ensure_profile`，在拉取前执行；失败只记录，不进入失败步骤列表。

#### 3.3.3 拉取

- `pull_podcasts`：`server_updated_at > pullSince`，按 `id` 升序分页，每页 1,000 行；`pullSince` 为空时全量。
- `pull_episodes`：`server_updated_at > pullSince`，按 `id` 升序分页，每页 1,000 行。
- `pull_subscriptions`：当前用户的全部订阅，不按时间过滤；按 `id` 升序分页。
- `pull_playback_history`：`server_updated_at > pullSince`，按 `id` 升序分页。
- `pull_favorites`：当前用户的全部收藏，按 `id` 升序分页。
- `pull_queue_items`：当前用户的全部队列项，按 `id` 升序分页。

分页规则：每页大小 1,000；必须使用唯一列 `id` 作为稳定排序；返回行数小于页大小即停止。任何列表拉取都不得依赖单次请求返回全集，因为 PostgREST 默认 `max-rows` 为 1,000。

`server_updated_at` 是三张增量表唯一的拉取过滤字段；`podcasts.last_updated`、`episodes.updated_at`、`playback_history.last_update_time` 只用于合并时判断内容新旧。首次同步后必须能拉到“内容时间很旧、但刚由其他设备上传”的记录，这是黄金用例之一。

游标取本轮观察到的最大 `server_updated_at`，因此不依赖设备时钟；2 分钟重叠窗口用于吸收事务可见性边界和并发写入。所有合并必须幂等，重复拉取同一行不得产生重复记录或回退状态。若本轮增量拉取没有返回任何行，游标保持不变，下一轮重复查询同一窗口，由 `(server_updated_at, id)` 索引保证空查询开销可控。

#### 3.3.4 合并规则

通用规则：云端行匹配到本地行后，若本地缺少云端 ID，必须回写；内容字段是否覆盖由各实体规则决定。回写云端 ID 不得置位 `pendingSync`；云端内容覆盖本地内容时必须清除该记录的 `pendingSync`；本地内容保留时保持原值。

播客：

- 先按 `itunes_id` 匹配本地播客；找不到再按云端 `id` 匹配。
- 已存在时，比较云端 `last_updated`（缺失时回退 `updated_at`，二者都只作为内容时间）与本地 `lastUpdated`。云端更新才覆盖内容字段；本地更新则保留本地。内容字段以 `packages/contracts/schema/README.md` 的字段表为准；覆盖时不得改变本地 `isSubscribed`、`subscribedAt`、下载状态与缓存路径。
- 不存在时插入本地，`isSubscribed` 默认为 `false`。云端目录记录不等于已订阅；订阅状态只来自 `user_podcast_subscriptions`。
- `last_updated` 是播客内容新旧判断的唯一依据；增量拉取使用服务端维护的 `server_updated_at`。两者不得混用。

剧集：

- 先按 `guid` 匹配本地剧集；找不到再按云端 `id` 匹配。
- 已存在时，云端 `updated_at` 晚于本地才覆盖；否则保留本地。
- 不存在时，按云端 `podcast_id` 找本地播客；找到才插入，找不到则跳过，等待下一轮播客先合并。
- 合并不得覆盖本地字段：`isDownloaded`、`downloadedPath`、`downloadProgress`、`isPlayed`、`playProgress`、`lastPlayedAt`。

订阅：

- 遍历云端订阅，按 `podcast_id` 找本地播客并标记为已订阅；找不到本地播客则跳过并记录；跳过本地已记录待删除的播客。
- 对本地已订阅、已有云端 ID、且出现在“最后一次成功推送快照”中的播客，如果云端订阅列表里不存在，则本地取消订阅。这是远端取消订阅的传播路径。
- 从未成功推送过的订阅不受云端列表缺失影响，避免推送失败被误判为远端删除。
- 本地新增的订阅在本轮推送阶段上传。
- 本地重新订阅正在等待推送时，必须先把该播客从“最后一次成功推送快照”中移除；否则云端列表缺失会把这次重新订阅再次取消。推送成功后快照重新包含它。

播放历史：

- 先按云端 `id` 匹配；找不到再按云端 `episode_id` 找到本地剧集，再按 `episodeId` 匹配本地历史。
- 云端 `last_update_time` 晚于本地才覆盖；否则保留本地。
- 新记录按云端 `episode_id` 找本地剧集；找不到则跳过。
- `is_deleted` 是软删除标记，随记录合并；它不进入墓碑存储。

收藏：

- 先按云端 `id` 匹配；找不到再按云端 `episode_id` 找到本地剧集，再按 `episodeId` 匹配本地收藏。
- 云端存在而本地不存在时插入。
- 本地收藏已有云端 ID、但云端列表中不存在时，视为远端取消收藏，删除本地记录。
- 云端列表为空也要执行上述删除传播，不能因为列表为空就提前返回。
- 本地待删除的收藏在合并时跳过，避免“删除后又被拉回来”。

队列：

- 先按云端 `id` 匹配；找不到再按云端 `episode_id` 找到本地剧集，再按 `episodeId` 匹配本地队列项。
- 新记录插入时采用云端 `position`，UI 按 `position` 排序。
- 已存在的本地记录不覆盖 `position`。当前实现是本地位置优先，因为队列行没有内容时间戳；如果拉取时直接采用云端位置，本地刚做的重排会在每轮同步被丢弃。
- 队列重排是“最后推送者胜”：本端不采纳远端位置，下一轮推送会用本端位置覆盖云端。v1 接受这一限制，并在功能矩阵中标注。
- 本地队列项已有云端 ID、但云端列表中不存在时，视为远端移除，删除本地记录。
- 本地待删除的队列项在合并时跳过，避免“删除后又被拉回来”。
- 云端列表为空也要执行删除传播。

#### 3.3.5 推送

推送顺序固定，后面的步骤依赖前面的云端 ID 回写。

变化判定不使用本地时钟与 `lastSyncTime` 比较。播客、剧集、播放历史、收藏维护本地 `pendingSync` 标记：本地用户操作或 Feed 刷新导致同步字段变化时置位；对应推送块成功并完成云端 ID 回写后清除；失败保留。拉取合并写入的本地记录不置位，避免把刚拉下来的云端数据立刻推回去。订阅和队列每轮全量推送，不依赖该标记。这样推送选择不受设备时钟与游标（服务端时间）影响。

`push_podcasts`：

- 选取 `pendingSync` 为真、或还没有云端 ID 的本地播客。
- 只推送 `itunes_id` 非空的播客；映射时移除 `id`，按 `itunes_id` upsert。
- 使用返回行回写本地 `supabaseId` 对应的云端 ID；该块全部回写成功后清除这些记录的 `pendingSync`。
- 没有 iTunes ID 的播客保留在本地，不参与云同步。

`push_episodes`：

- 选取 `pendingSync` 为真、或还没有云端 ID 的本地剧集。
- 先回填剧集的 `podcast_itunes_id`（从所属播客读取）。
- 只推送 `guid` 非空、且所属播客已有云端 ID 的剧集。
- 映射时移除 `id`，用所属播客的云端 ID 填入 `podcast_id`，按 `(guid, podcast_id)` upsert。
- 使用返回行回写云端 ID；该块全部回写成功后清除这些剧集的 `pendingSync`。

`push_subscriptions`：

- 收集本地所有已订阅且有云端 ID 的播客，按 `(user_id, podcast_id)` upsert，写入 `subscribed_at`。
- 本地重新订阅会清除对应的待删除墓碑，并在推送成功前把该播客从“最后一次成功推送快照”中移除。
- 对本轮仍在本地订阅集合中的云端 ID，清除墓碑。
- 对仍未解决的墓碑执行远端删除；删除成功才清除墓碑，失败保留到下一轮。
- 本轮成功后保存“最后一次成功推送的订阅快照”，内容是本轮所有已订阅且有云端 ID 的播客集合。

`push_playback_history`：

- 选取 `pendingSync` 为真、或还没有云端 ID 的播放历史。
- 关联剧集必须有云端 ID；按 `(user_id, episode_id)` upsert。
- 删除通过 `is_deleted = true` 推送，不使用墓碑表。
- 本地软删除必须同时更新 `last_update_time` 并置 `pendingSync`；只置标记不更新时间会导致云端合并保留旧状态。
- 使用返回行回写云端 ID；该块全部回写成功后清除这些记录的 `pendingSync`。

`push_favorites`：

- 选取 `pendingSync` 为真、或还没有云端 ID 的收藏。
- 关联剧集必须有云端 ID；按 `(user_id, episode_id)` upsert。
- 本地重新收藏会清除对应的待删除墓碑。
- 对仍未解决的墓碑执行远端删除；成功才清除墓碑。
- 推送成功后清除已推送记录的 `pendingSync`。

`push_queue_items`：

- 队列顺序可能变化，因此本轮推送全部本地队列项，而不是只推送 `pendingSync` 为真的项。
- 关联剧集必须有云端 ID；按 `(user_id, episode_id)` upsert，写入 `position` 和 `added_at`。
- 本地重新加入会清除对应的待删除墓碑。
- 对仍未解决的墓碑执行远端删除；成功才清除墓碑。

`ensure_profile`：

- 在拉取前执行，确保 `profiles` 中存在当前用户记录。
- 失败只记录日志，不阻塞同步，不进入失败步骤列表。

#### 3.3.6 删除与墓碑

- 订阅、收藏、队列项使用显式墓碑，记录待删除的云端 ID，按用户隔离存储。
- 墓碑只在本地删除“已经同步过、有云端 ID”的记录时产生。
- 远端删除失败时墓碑保留，下一轮重试。
- 收藏和队列项重新添加时，墓碑被清除，本地状态优先；重新添加应创建不带云端 ID 的新本地行（或显式标记为本地新增），不要复用旧云端 ID 直接复活，否则拉取的远端缺失规则会再次删除它。
- 订阅重新添加时，播客本身保留云端 ID；清除订阅墓碑，并按 3.3.4 在推送前把该播客从“最后一次成功推送快照”中移除，避免拉取阶段把它当成远端取消。
- 不使用“当前本地集合与云端列表做差集”的方式做镜像删除，因为这会删除其他设备刚上传、但本设备尚未拉取的数据。订阅的远端删除传播只使用“最后一次成功推送快照”这一受限例外，规则见 3.3.4。
- 播客和剧集是全局目录，客户端不删除云端记录。
- 播放历史不使用墓碑，使用 `is_deleted` 软删除。本地删除必须保留行、置 `is_deleted = true`、更新 `last_update_time` 并置 `pendingSync`；硬删除会导致云端收不到删除。
- 订阅的远端取消传播受“最后一次成功推送快照”保护，规则见 3.3.4。

#### 3.3.7 失败语义与游标

- 拉取请求失败：中止本轮，跳过所有推送，游标不推进，返回 `pullFailed`。这是为了避免用陈旧的本地状态覆盖云端。
- 拉取合并失败：记录失败步骤，跳过该实体的推送，继续其他实体的拉取与推送，游标不推进，返回 `partial`。合并可能已经部分写入本地，这一点必须在日志和 UI 状态中体现。
- 推送步骤失败：记录失败步骤，继续剩余推送步骤，游标不推进，返回 `partial`。使用 `pendingSync` 的步骤中，成功块清除标记，失败块保留标记等待下一轮重试。
- 未预期异常：返回 `failed`，游标不推进。
- 前置条件不满足或已有同步进行中：返回 `skipped`，不发起网络请求，不改变游标。
- 只有 `success` 推进游标；`partial`、`pullFailed`、`skipped`、`failed` 都不推进。
- 游标、墓碑和推送快照都按用户 ID 隔离；登出和账号切换必须清理。
- 游标值来自服务端 `server_updated_at`，不使用设备时钟；2 分钟重叠窗口用于吸收事务可见性边界与并发写入，不承担时钟校准职责。
- `lastSyncTime` 是同步游标，不等于本轮完成时间；UI 的“上次同步时间”单独记录本地完成时间，两者不得混用。
- 单条记录持续失败会导致游标停滞，下一轮反复重试同一窗口；v1 用失败步骤日志暴露问题，并在阶段 P1 评估按步骤游标或手动跳过机制。

#### 3.3.8 版本化与兼容

- v1 是冻结协议。新增可选字段属于兼容变更；改变字段含义、删除字段、改变合并规则、改变删除语义都属于破坏性变更。
- 破坏性变更升级到 v2，通过新表、新列或服务端网关实现；旧客户端继续按 v1 读写，不得被新客户端破坏。
- 客户端在每个同步请求带 `X-TinyCast-Sync-Protocol: 1`。服务端强制校验需要 Edge Function 或网关；v1 先记录和观测，P1 视情况增加服务端 gate。
- 每个客户端的本地数据库有自己的 schema 版本；本地迁移与协议版本独立管理。

#### 3.3.9 相对现状的契约修正

为了三端可测试和可一致，v1 明确修正以下行为；桌面端在阶段 P0 对齐，P3 做回归：

- 解析器不在核心逻辑中注入中文兜底文案（如“未知播客”“节目 $i”）；缺失值保留为空，由 UI 按当前语言显示本地化占位。
- 移除 `https://via.placeholder.com/...` 远程占位图；UI 使用本地占位资源。
- 收藏、队列项、播放历史在推送前必须解析出关联剧集的云端 ID；解析不到就跳过并记录，不发送缺少 `episode_id` 的半关联行。
- 缺失日期时使用可注入的时钟，而不是在核心逻辑里直接调用 `DateTime.now()`；测试使用固定时钟，保证黄金用例可重复。
- 增量拉取改用服务端写入时间 `server_updated_at`；客户端内容时间不再作为同步游标。
- 推送选择改用本地 `pendingSync` 标记；不再用本地内容时间与上次同步时间比较，拉取合并不得置位。
- UI 的“上次同步时间”与游标分离；桌面端新增本地完成时间字段，不把游标值展示为完成时间。
- 所有本地写操作都触发 10 秒防抖同步，不再只有播放行为触发。
- 应用回到前台触发同步。
- 三端统一步骤名、结果状态和失败分类，日志可以跨平台检索。

### 3.4 黄金用例

同步与解析的正确性不靠人工比对，靠三端共同执行的用例。

目录结构：

```text
packages/contracts/sync/cases/v1/<case-id>/
├── meta.json          # 协议版本、场景说明、lastSyncTime、userId、固定时钟、故障注入
├── local.json         # 同步前本地状态
├── remote.json        # 同步前远端状态
├── expected_local.json
├── expected_remote.json
└── actions.json       # 可选的本地操作序列，例如取消收藏、重排队列
```

要求：

- 每个客户端把同步引擎实现为可注入“本地存储”和“远端客户端”的纯逻辑组件，测试时使用内存存储和由 `remote.json` 驱动的假远端，同步结束后比较本地与远端状态。
- 同步引擎不得直接依赖 UI、播放器、文件系统或平台调度器；这些通过接口注入。
- runner 使用 `meta.json` 中的 `now` 作为同步引擎的本地固定时钟；同步引擎不得直接读取系统时间。
- `meta.json` 可包含 `serverNow`；假远端用它生成 `server_updated_at` 等服务端时间戳，缺省等于 `now`。两者可以不同，用于覆盖设备时钟偏差。
- `local.json` 中可推送实体带 `pendingSync` 标记；runner 与同步引擎用它决定推送集合，不用本地时间与游标比较。
- 失败类用例通过 `meta.json` 的 `faults` 数组（或独立 `faults.json`）声明在第几个请求或步骤注入哪类失败；runner 让假远端或合并器按声明抛错，故障注入逻辑不进入同步引擎。
- 用例按协议版本归档（`cases/v1/`、`cases/v2/`）；v1 用例在 v1 生命周期内不得修改期望结果，只能新增。
- `just contract-test` 必须能在三端分别执行；CI 中三端都跑同一套用例。

v1 至少覆盖以下场景：

- 首次同步，本地与远端都为空。
- 首次同步，远端已有目录和订阅。
- 增量拉取：播客和剧集在远端更新。
- 内容时间很旧、但刚上传的播客/剧集：其他设备仍能通过 `server_updated_at` 增量拉到。
- 播客/剧集本地较新：拉取不覆盖本地内容。
- 远端新增订阅。
- 远端取消订阅。
- 本地取消订阅并推送墓碑。
- 本地取消订阅后，同轮拉取不得把它重新加回。
- 从未成功推送的本地订阅，不因云端列表缺失被删除。
- 本地重新订阅与远端取消并发：重新订阅不被拉取阶段取消。
- 收藏新增与远端取消收藏。
- 队列新增、重排、远端移除。
- 本地移除队列项后，同轮拉取不得把它重新加回。
- 队列本地位置优先：本地重排后拉取不覆盖，下一轮推送把本地位置写回云端。
- 播放历史：本地进度较新。
- 播放历史：远端进度较新。
- 播放历史软删除。
- 本地删除与远端新增并发：墓碑优先，不得复活。
- 收藏/队列本地重新添加与远端删除并发：重新添加不被拉取阶段删除。
- 分页边界：远端返回 1,000 行与 1,001 行。
- 推送分块边界：501 条记录分成两块，且尾部记录的云端 ID 正确回写。
- 推送分块部分失败：成功块清除 `pendingSync`，失败块保留并在下一轮重试。
- 拉取合并不置 `pendingSync`：刚拉下来的记录不会在下一轮被回推。
- 拉取覆盖本地内容时清除 `pendingSync`：被云端覆盖的本地修改不会在下一轮被回推。
- 设备时钟明显落后或领先服务端：本地修改仍被推送，游标只由服务端 `server_updated_at` 推进。
- 拉取请求失败：中止推送，游标不推进。
- 合并失败：跳过该实体推送，其他步骤继续，游标不推进。
- 推送失败：继续剩余推送，游标不推进。
- `profiles` 写入失败：同步仍成功，游标推进。
- 身份回退：iTunes ID 匹配、GUID 匹配、云端 ID 匹配。
- 播客目录合并不改变本地 `isSubscribed`、`subscribedAt` 与下载状态。
- 账号切换：旧账号墓碑和游标不泄漏到新账号。
- 收藏与队列：本地为空而远端非空、远端为空而本地非空（删除传播）；订阅的等价场景由“远端取消订阅”覆盖。

### 3.5 RSS 与 OPML 归一化契约

范围：RSS 2.0 与 iTunes 命名空间。Atom 不在 v1 范围内。以下 fallback 链中的“缺失”同时包括元素不存在与去除空白后为空字符串。

播客级归一化：

- 标题：`channel.title`，缺失为空字符串；UI 显示本地化占位。
- 作者：`itunes:author`，其次 Dublin Core `dc:creator`，其次 `channel.title`，缺失为空字符串。
- 描述：`channel.description`，其次 `itunes:summary`，缺失为空字符串。
- 封面：`itunes:image` 的 `href`，其次 `channel.image.url`；缺失为 `null`，UI 使用本地占位。v1 契约统一用 `null` 表示缺失；本地模型必须允许空值，桌面端需相应把 `Podcast.artworkUrl` 改为可空。
- 站点链接：`channel.link`，缺失为空字符串。
- 语言：`channel.language`，缺失为 `null`。
- 版权：`channel.copyright`，其次 `dc:rights`，缺失为 `null`。
- 分类：按文档顺序收集所有 `itunes:category` 的 `text`，去重保序；缺失为 `null`。
- 关键词：`itunes:keywords`，按逗号分隔、去除首尾空白、去重保序；缺失为 `null`。
- 显式标志：`itunes:explicit` 为 `yes`、`true` 或 `1` 时为真，其余情况为假。
- Owner：`itunes:owner/name` 与 `itunes:owner/email`，缺失为 `null`。
- iTunes 搜索结果字段（`itunesPrimaryGenreName`、`itunesGenres`、`itunesGenreIds`、`itunesCollectionViewUrl`、`itunesCountry`、`itunesReleaseDate`、`itunesCollectionExplicitness`、`itunesContentAdvisoryRating`）不属于 RSS v1 归一化输出；它们只在搜索/详情流程中填充，不进入 Feed 夹具的期望结果。
- 最后更新时间：`channel.lastBuildDate`；解析失败或缺失时使用本轮抓取时间（通过可注入时钟）。
- 剧集数量：`item` 元素数量。

剧集级归一化：

- 标题：`item.title`，缺失为空字符串。
- 描述：`item.description`，其次 `itunes:summary`，缺失为空字符串。
- 链接：`item.link`，缺失为空字符串。
- GUID：`item.guid`；缺失时用 `auto_guid:<enclosure url>`；连 enclosure URL 也缺失时用 `auto_guid:index_<序号>`。同一 feed 内 GUID 重复时保留第一条，跳过后续。
- 发布日期：`item.pubDate`；解析失败或缺失时使用本轮抓取时间（可注入时钟）。
- 音频：取第一个 `enclosure` 的 `url` 和 `type`；`type` 缺失为 `audio/mpeg`；没有 `enclosure` 时 `audioUrl` 为空字符串，剧集仍保留但由 UI 视为不可播放。
- 时长：优先 `itunes:duration`，支持 `HH:MM:SS`、`MM:SS` 和纯秒数；解析失败为 `null`。
- 显式标志：`itunes:explicit` 为 `yes`、`true` 或 `1` 时为真。
- 封面：`itunes:image` 的 `href`；缺失为 `null`。
- 作者：`item.author`，其次 `itunes:author`，其次 Dublin Core `dc:creator`；缺失为 `null`。
- iTunes 字段：`itunes:id`；`itunesArtworkUrl` 取 `itunes:image` 的 `href`，当前实现不读取 `itunes:artwork`，v1 不把它作为来源。`itunesReleaseDate`、`itunesExplicitness`、`itunesContentAdvisoryRating` 不属于 RSS v1 归一化输出，只在后续搜索/详情流程使用。

日期解析规则：

- 先尝试 ISO 8601。
- 再尝试 RFC 822：可选的星期前缀、日、英文月份、四位年份、时、分、可选秒，以及数值时区或英文时区缩写。
- 支持 `EST`、`EDT`、`CST`、`CDT`、`MST`、`MDT`、`PST`、`PDT` 的固定偏移；未知缩写按 UTC 处理。
- 解析失败返回 `null`；播客 `lastBuildDate` 与剧集 `pubDate` 回退到本轮抓取时间（可注入时钟），其他日期字段保留 `null`。

OPML：

- 当前代码只有文件选择 UI，没有导入逻辑，按新功能设计。
- 目标行为：读取 OPML 文件，遍历所有 `outline` 节点，取 `xmlUrl` 属性作为 RSS 地址；忽略没有 `xmlUrl` 的分类节点；按 URL 去重并保留首次出现顺序。
- 对每个 URL 执行订阅流程：抓取、解析、展示预览，用户确认后写入本地并加入同步队列。单个 feed 失败不阻塞其余 feed，结果按成功、重复、失败分类汇总。
- 不在后台静默批量订阅全部 feed；用户必须能看到失败项并重试。
- 文件访问遵循各平台沙盒规则：iOS/macOS 使用文件选择器的安全作用域书签或临时读取权限；Android 使用 Storage Access Framework；桌面使用文件路径。

夹具：

- 输入放在 `packages/contracts/feeds/cases/<case-id>/input.xml`，期望结果放在 `expected.json`，元信息放在 `meta.json`；OPML 用例的输入文件为 `input.opml`。
- 至少覆盖：基础 RSS、缺 GUID、GUID 重复、多个 enclosure、CDATA、iTunes 命名空间、日期格式异常、非 UTF-8 编码、空 channel、缺图片、时长格式变体、OPML 嵌套分类、重复 OPML URL、损坏 XML。
- 非 UTF-8：至少覆盖可解码的 UTF-16 样本；GBK 等平台解析器不支持的编码作为错误用例，断言返回明确的解析错误，不产生半条记录。
- 空 channel：播客字段按缺失规则归一化，剧集列表为空。
- 损坏 XML：整份 feed 解析失败，不写入任何播客或剧集，错误可展示并重试。
- 现有 `test/test-data/anyway_rss.xml` 作为第一个基础样本迁入。
- 三端解析器都跑同一套用例；桌面端现有解析测试迁移到该夹具。

已知弱点：

- `auto_guid:index_<序号>` 依赖 feed 内条目顺序，feed 重排会导致身份变化。v1 保留该规则以兼容现有数据路径，但夹具中必须显式覆盖，后续版本优先使用音频 URL 或标题+日期生成稳定标识。
- 现有 `via.placeholder.com` 占位图不再进入契约；UI 使用本地资源。

### 3.6 设计 token

- HOCON 仍是唯一设计源：当前位于 `assets/themes/colors.conf`、`typography.conf`、`styles.conf`，P0 随 Flutter 工程移入 `apps/desktop/assets/themes/`。
- 现有 `HoconParser` 在 `lib/core/theme/theme_loader.dart` 中，依赖 Flutter。P0 把它抽取为纯 Dart CLI，放入 `packages/design/generator/`，去掉 Flutter 依赖。
- 生成器输出：
  - `packages/design/generated/Tokens.swift`：颜色、字体、字号、间距、圆角、阴影，按 light/dark 与 desktop/tablet/mobile 变体。
  - `packages/design/generated/Tokens.kt`：Compose 可消费的常量与主题对象。
  - `packages/design/generated/theme_tokens.g.dart`：Flutter 常量。
- 生成物入库。CI 重新生成并检查 `git diff --exit-code`，防止源与生成物不一致。
- 三端只消费生成物，不在 Swift/Kotlin 中重新实现 HOCON 解析。
- 各 app 的 design 模块通过构建脚本引用 `packages/design/generated/`，不手工复制生成物，避免两份来源。
- 桌面端在 P0 保留现有运行时 HOCON 加载；P3 切换到生成的 Dart token，并移除运行时 HOCON 解析路径。HOCON 文件继续作为生成源保留。
- 颜色格式保持 `#AARRGGBB`；生成器负责转换为 SwiftUI `Color`、Compose `Color` 和 Flutter `Color`。
- 字体族与 fallback 在三端分别映射；生成器只输出族名、字号、行高、字重，不嵌字体文件。

### 3.7 国际化

- 作为独立工作流实施，不阻塞 P0/P1；最迟在 Apple 客户端进入实现前建立共享 key 与生成流程。
- 共享源是 `packages/i18n/strings.json`，按 key 组织，至少包含 zh-CN 与 en。
- 生成 Swift String Catalog、Android `strings.xml`、Flutter ARB 或常量类。
- 解析器不再注入中文兜底文案；UI 从共享 key 取占位文案。
- 无障碍标签、错误提示、空状态、权限说明都进入共享 key。
- 三端文案允许按平台习惯调整措辞，但 key 和语义必须一致。

### 3.8 功能矩阵

功能矩阵放在 `packages/contracts/parity/features.md`，按功能域列出 Apple、Android、Desktop 的目标级别。以下用 F0/F1/F2 表示功能级别，避免与第 6 节的交付阶段 P0–P4 混淆：

- F0：该平台首发必须具备，缺一不可。
- F1：首发不阻塞的增强项，安排在 P4 随首发或紧随首发交付；延期不影响首发。
- F2：长期增强，不设交付期限，不阻塞发布。
- N/A：该平台不适用。

F0 功能域：

- 订阅：RSS URL 订阅、预览后确认、取消订阅、定时刷新、刷新失败退避。
- 播放：后台播放、锁屏/系统媒体控制、倍速、快进快退、连续播放、睡眠定时器。
- 队列：加入队首/队尾、移除、重排、跨设备同步。
- 收藏与历史：收藏、取消收藏、播放进度、已完成/跳过状态、跨设备同步。
- 下载：单集/批量/整档下载、暂停/恢复/取消、断点续传、自动下载策略、按类型/播客/保留数量清理。
- 本地库：订阅列表、剧集列表、本地搜索、下载列表。
- 设置：播放、下载、刷新、通知、缓存、账号与云同步。
- 云同步：登录、登出、账号切换、手动同步、同步状态与失败提示。
- 主题：跟随系统亮暗、共享 token、无 Material 默认视觉。

OPML 导入当前未实现，默认排入阶段 P1；其功能级别（F0 或 F1）在评审时确认，本稿不预先把它列为 F0。

F1 功能域：

- 新剧集通知。
- CarPlay 与 Android Auto。
- 主屏幕/锁屏小组件。
- App Intents/Shortcuts。
- Live Activities。
- 分享扩展。
- macOS 多窗口与菜单栏增强。

F2 功能域：

- 更复杂的队列规则、智能播放列表、统计等产品增强。
- 桌面端多窗口高级能力。

桌面端级别：

- 保持现有 F0 能力，除依赖移动端后台能力的部分外。
- 桌面端已经实现的 F1 能力不强制移除；未实现的不作为桌面端义务。
- 不要求 CarPlay、Android Auto、移动端小组件、App Intents、Live Activities。
- 必须通过同步与 Feed 契约测试。
- 新功能允许晚于原生端；具体冻结范围在 P3 评审时确认。

## 4. 平台实现

### 4.1 Apple（iOS + macOS）

目标版本：

- iOS 17 起，macOS 14 起。相比现有 Flutter 的 iOS 14/macOS 10.15 有所提高；当前没有用户，评审时确认是否接受。
- Swift 6，启用严格并发检查。

模块划分：

- `TinyCastKit`：领域模型、用例、仓库协议、同步引擎、RSS 解析、Supabase 远端客户端、设置模型。不依赖 UI 和平台框架；第三方依赖限于网络与序列化 SDK，便于单元测试和契约夹具。
- `TinyCastData`：GRDB 数据库、迁移、DAO、文件存储、Keychain 封装。
- `TinyCastDesign`：生成的设计 token、共享 SwiftUI 组件、图标与占位资源。
- `TinyCastApp`：iOS 与 macOS 两个 app target；SwiftUI 页面、导航、应用生命周期；平台服务适配层。

本地数据库：

- 选择 GRDB（SQLite），不使用 SwiftData。
- 理由：播客库可能有数千到数万集，需要稳定分页、复杂查询、FTS5 搜索、明确的迁移和并发控制；GRDB 提供直接的 SQL 与事务控制，适合同步合并和性能调优。SwiftData 更省样板代码，但在大表、复杂谓词和迁移控制上风险更高。
- 本地 schema 包含同步字段和本地字段：下载状态、下载路径、播放瞬时状态、缓存路径等只存本地，不进入云端 DTO。

同步引擎：

- 实现为纯 Swift actor 或结构体，注入 `LocalStore`、`RemoteAPI`、`Clock`、`TombstoneStore` 接口。
- 步骤名、结果状态、失败分类与 3.3 保持一致。
- 黄金用例通过 Swift Testing 运行，使用内存 GRDB 或临时 SQLite 文件。

播放：

- AVPlayer + AVAudioSession；后台音频模式；`MPNowPlayingInfoCenter` 与 `MPRemoteCommandCenter`；耳机与中断处理；倍速、快进快退、连续播放、睡眠定时器。
- CarPlay 在阶段 P4 实现，需要 CarPlay entitlement 与 scene 配置。

下载：

- `URLSession` background configuration；断点续传使用 resume data；文件写入 Application Support 下的专用目录；文件保护等级按后台下载需求设置。
- App 被系统终止后重新关联后台 session；下载完成回调更新本地数据库。
- 缓存清理按设置执行，删除文件与数据库标记在同一逻辑事务中完成。

Feed 刷新：

- 前台定时器 + iOS `BGAppRefreshTask`；macOS 使用后台任务或前台定时器。
- 刷新失败按 `refreshFailedCount` 退避；设置中的刷新间隔映射到系统允许的调度窗口。

认证：

- 使用 Supabase Swift SDK 或直接 REST；访问令牌与刷新令牌存 Keychain。
- 登录方式与现有客户端一致：Google OAuth（ASWebAuthenticationSession）；iOS 需同时提供 Sign in with Apple 或符合 App Store 4.8 的等价方案，具体在 Apple 客户端实现阶段评审。
- 令牌可访问性选择 `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`，满足后台刷新与安全要求。
- 登出与账号切换清理该用户的同步簿记和本地数据。

UI：

- SwiftUI；iOS 使用 `NavigationStack`/`TabView`，macOS 使用 `NavigationSplitView` 与 Settings scene，按平台习惯组织信息架构。
- 不使用默认表单/列表外观覆盖品牌；颜色、字体、间距来自生成 token。
- 平台集成：通知、URL scheme、分享扩展、App Intents、小组件按 F1/F2 排期。

测试：

- Swift Testing 单元测试；GRDB 内存数据库；契约夹具；UI 测试覆盖关键路径；真机测试覆盖后台播放、后台下载、锁屏控制与 CarPlay（阶段 P4）。
- macOS 需要沙盒 entitlements：网络客户端、用户选择文件读写（OPML）、应用容器内文件读写。参考现有 `docs/reference/platform_permissions.md`，但原生工程的 entitlement 需重新配置。

### 4.2 Android

目标版本：

- minSdk 26（Android 8.0），targetSdk 使用当时最新稳定版。
- Kotlin 2.x，Compose BOM，KSP。

模块划分（1–2 人规模，避免过度拆分）：

- `:app`：应用入口、导航、DI 装配。
- `:core`：领域模型、用例、仓库、网络、数据库、同步引擎。内部按包分层，不强制多模块。
- `:designsystem`：生成的 token、Compose 主题、共享组件。
- `:feature:subscriptions`、`:feature:player`、`:feature:library`、`:feature:settings`：按功能拆分的 Compose 页面。
- 如果维护成本过高，可以合并 feature 模块；模块边界服务于独立编译和测试，不追求形式。

本地数据库：

- Room + SQLite；FTS4/FTS5 做本地搜索；显式迁移。
- 本地字段与云端字段分离；下载状态、路径、进度只存本地。
- 同步引擎使用内存 Room 数据库或临时文件数据库跑契约用例。

播放：

- Media3 ExoPlayer + MediaSessionService；通知与锁屏控制；音频焦点与 noisy 处理；后台播放；倍速、快进快退、睡眠定时器。
- Android Auto 在阶段 P4 实现，使用 Media3 的 Automotive 支持与 Manifest 声明。

下载：

- WorkManager + OkHttp；前台服务承载活跃下载（Android 14+ 声明 dataSync 类型）；断点续传；文件存应用专属目录；下载完成更新 Room 并发送通知。
- 自动下载策略在 WorkManager 约束下执行；网络类型与充电条件按设置映射。

Feed 刷新：

- 前台定时器 + WorkManager 周期任务；周期下限受系统限制，设置中的短间隔在后台只能近似执行。
- 失败按 `refreshFailedCount` 退避。

网络与认证：

- 推荐 supabase-kt（Auth + PostgREST）+ Ktor engine + kotlinx.serialization；也可用 Retrofit 包装 PostgREST，但 auth 仍需 Supabase SDK 或手写刷新逻辑。
- 登录方式与现有客户端一致：Google OAuth；Android 使用 Custom Tabs/AppAuth，回调 URI 按平台在 Supabase 注册。
- 会话令牌存入加密存储（EncryptedSharedPreferences/DataStore + Android Keystore），不使用明文 SharedPreferences。
- 登出与账号切换清理该用户的同步簿记和本地数据。

依赖注入：

- 使用 Hilt。理由是 WorkManager、MediaSessionService、ViewModel 的集成成熟；如果构建时间成为问题，可退到 Koin 或手写装配。

UI：

- Compose；Material3 组件用于交互、无障碍和手势，但颜色、字体、组件外观由生成 token 驱动，不沿用默认 Material 视觉。
- 信息架构与 iOS 对齐到功能级，不要求页面级一致。
- 通知渠道、运行时通知权限（Android 13+）、前台服务类型按目标 SDK 要求配置。

测试：

- JUnit4 + Truth + Turbine；Room 内存数据库；契约夹具；Compose UI 测试；Media3 Test ExoPlayer。
- 真机/模拟器覆盖 Android 8、12、14、16；后台播放、下载、通知与 WorkManager 是重点。
- 发布前跑 `lint`、单元测试、`assembleRelease`（或 AAB）与基线签名验证。

### 4.3 Desktop（Windows + Linux，Flutter）

定位：

- 过渡期的现有客户端，迁移到 `apps/desktop`。
- 长期作为二级客户端：保持 F0 核心能力，新功能可以晚于原生端。
- 必须通过同步与 Feed 契约测试，保证与原生端共享同一云端状态。

P0 动作：

- 把现有 Flutter 工程整体移入 `apps/desktop`，包括 `lib/`、`test/`、`assets/`、`pubspec.yaml`、`run.sh`、`windows/`、`linux/`、`android/`、`ios/`、`macos/`、`web/`。
- 把 `run.sh` 移入 `apps/desktop`；根目录保留同名转发脚本或改用 `just`，并更新 README、AGENTS.md、docs 中的路径。
- 迁移完成后运行 `flutter analyze` 与 `flutter test`，全部通过才算完成。
- 过渡期保留 Android/iOS/macOS target，作为原生客户端未就绪时的回退；P3 删除这些 target，只保留 Windows/Linux（`web/` 若确定不维护也一并删除）。

技术栈保持：

- Riverpod 3、Isar Community（`isar_community`）、just_audio/audio_service、Dio、现有路由与主题系统。
- 不把桌面端迁到原生数据库；Isar Community 继续服务桌面端。
- 不要求桌面端实现 CarPlay、Android Auto、移动端小组件等能力。

契约对齐：

- 把现有 `SyncService` 的注入缝（Isar、远端数据源、墓碑存储、用户 ID）用于契约测试；补齐 3.3 的 v1 行为差异。
- 把现有 RSS 解析测试迁移到 `packages/contracts/feeds` 夹具，解析器按 3.5 的新归一化规则调整。
- 补齐同步黄金用例，至少覆盖墓碑、远端删除传播、播放历史 LWW、队列本地位置优先、分页与分块边界。
- 步骤名、结果状态和日志字段与 3.3 对齐。

设计 token：

- P0 保留运行时 HOCON 加载，同时引入生成器。
- P3 切换到生成的 Dart token，移除运行时解析；增加一致性测试，确保生成值与 HOCON 解析值完全一致后再切换。
- 主题仍跟随系统亮暗，不持久化主题模式。

发布：

- Windows：MSIX 或 Inno Setup 安装包；代码签名按分发渠道要求。
- Linux：AppImage 或 Flatpak；若进 Flutter Linux 构建，注意发行版依赖与沙盒权限。
- 版本号从根 `VERSION` 注入。

### 4.4 三端一致性规则

- 同步步骤名、结果状态（`success`、`partial`、`pullFailed`、`skipped`、`failed`）和失败分类三端一致。
- 日志字段至少包含：步骤名、实体类型、云端 ID、错误类型；允许平台追加字段，不允许改变已有字段含义。
- 所有时间写 UTC；展示层按本地时区。
- 所有时长、进度使用整数毫秒或整数秒，避免浮点误差；进度百分比在 UI 层计算。
- 空值、缺失值、默认值的处理遵循 3.2 和 3.5，不在各端自行发挥。
- PR 检查清单包含：契约是否变化；三端是否需要同步修改；是否新增黄金用例；功能矩阵是否更新。

## 5. 数据与安全

### 5.1 逻辑实体与归属

云端同步的实体：

- 播客目录 `podcasts`。
- 剧集目录 `episodes`。
- 用户订阅 `user_podcast_subscriptions`。
- 播放历史与进度 `playback_history`。
- 收藏 `favorites`。
- 播放队列 `queue_items`。
- 用户资料 `profiles`。

只存在本地的数据：

- 搜索历史。
- 应用设置。
- 下载状态、下载路径、下载进度、缓存路径。
- 播放器的瞬时状态、当前音频会话、通知状态。
- 本地 UI 偏好与窗口状态。

同步簿记（本地维护，不上传）：`pendingSync` 标记、云端 ID、游标、墓碑、最后一次成功推送快照。

剧集上的 `isPlayed`、`playProgress`、`lastPlayedAt` 是播放历史的本地投影；同步的权威来源是 `playback_history`，客户端不得把剧集上的本地投影直接当作云端状态推送。

### 5.2 身份与 fallback

- 本地主键使用各平台数据库的自增 ID 或 UUID；云端 ID 作为独立字段保存。
- 播客的云端冲突键是 `itunes_id`；本地匹配优先 iTunes ID，其次云端 ID。
- 剧集的云端冲突键是 `(guid, podcast_id)`；本地匹配优先 GUID，其次云端 ID。
- 订阅、收藏、队列、播放历史使用 `(user_id, episode_id)` 或 `(user_id, podcast_id)` 作为云端身份。
- 云端匹配优先级与 3.3.4 一致：播客为 iTunes ID → 云端 ID，剧集为 GUID → 云端 ID；本地 ID 只作为本地兜底，不参与云端匹配。RSS URL 只是播客的本地唯一标识，不参与云端匹配。
- 推送前必须解析出关联对象的云端 ID；解析不到就跳过并记录，不得写入半关联记录。

### 5.3 本地数据库

- Apple：GRDB/SQLite。
- Android：Room/SQLite。
- Desktop：Isar Community（`isar_community`）。
- 不共享物理 schema。共享的是逻辑字段、同步语义和黄金用例。
- 每个平台维护自己的迁移版本；本地 schema 变更不得改变云端协议语义。
- 本地搜索：Apple 用 GRDB FTS5；Android 用 Room FTS；桌面保持现有实现。

### 5.4 认证与凭证

- 使用 Supabase Auth 登录；首版保持现有的 Google OAuth（`signInWithOAuth`）。Apple 端在阶段 P2 评估 Sign in with Apple，以满足 App Store 对第三方登录的等价选项要求；邮箱/密码不在首版范围内。
- Apple：Keychain。
- Android：EncryptedSharedPreferences 或加密 DataStore + Keystore。
- Desktop：现有 `flutter_secure_storage`。
- 严禁把令牌、密码、API Key 明文存入 SharedPreferences、UserDefaults 或普通文件。
- 登出时清理该用户的游标、墓碑和推送快照；账号切换时再清理旧账号的本地数据，避免跨账号泄漏。清理策略与现状一致。
- Supabase anon key 是客户端公开凭据，可以随构建注入；service role key 不得进入客户端仓库或分发包。

### 5.5 全局目录写入风险

- `podcasts` 和 `episodes` 是全局表，当前客户端直接 upsert。若 RLS 允许任意已登录用户写入，恶意客户端可以污染所有用户的目录数据。
- P0 审计 RLS 与写入路径；P1 之前决定是否把目录写入收敛到 RPC/Edge Function，增加字段校验、冲突处理和速率限制。
- 在收敛之前，至少增加服务端约束：必填字段、URL 格式、字符串长度、`server_updated_at` 触发器等。
- 这是安全与数据完整性问题，优先级高于 UI 打磨；不得因为“当前没有用户”而跳过。

## 6. 交付顺序

不给出日历承诺；每个阶段以退出标准界定。1–2 人维护时，P1 与 P2 不得并行。以下按默认顺序描述：P1 为 Android、P2 为 Apple；若评审决定对调，所有以阶段号指代具体客户端的表述随之互换，架构与退出标准不变。

### 6.1 P0：仓库与契约基础

任务：

- 把 Flutter 工程移入 `apps/desktop`，更新脚本、文档和路径；`flutter analyze` 与 `flutter test` 通过。
- 创建 `apps/apple`、`apps/android` 的骨架与 README，不写业务代码。
- 拉取 Supabase schema、RLS、触发器和函数，提交 migrations、config 与 seed。
- 建立 `packages/contracts`：schema 说明、同步协议 v1、黄金用例、Feed 夹具、功能矩阵初稿。
- 抽取 HOCON 解析器为纯 Dart 生成器，生成 Swift/Kotlin/Dart token；生成物入库。
- 建立 `justfile` 与四类 CI 任务；先本地可跑，再接托管 CI。
- 修正 README/AGENTS 中 OPML 的失实描述；补一份功能现状审计。
- 桌面端对齐 3.3.9 的契约修正，跑通 v1 黄金用例。

退出标准：

- 现有 Flutter 桌面端构建、分析、测试全部通过。
- `supabase/migrations` 能本地启动并与远端 schema 对照通过。
- 契约用例格式、runner 约定与故障注入方式冻结；桌面端执行全部 v1 用例并全绿；Apple/Android 骨架提供 runner 入口，用例标记为跳过。
- 设计 token 生成成功，CI 能检测生成物漂移。
- 功能矩阵初稿完成，OPML 状态修正。
- CI 四个 job 可运行（Apple/Android 此阶段只构建骨架，契约用例跳过并计入报告）。

### 6.2 P1：Android 原生客户端

默认先做 Android，理由：

- Kotlin/Compose 与现有 Flutter/Riverpod 的心智模型最接近。
- Google Play 迭代快，不需要 App Review。
- 先用第二个语言验证契约层，能尽早暴露协议和夹具问题。
- Apple 端随后可以拿 Android 实现和契约用例做参照。

如果维护者更熟 Swift，或 Apple 是首要市场，P1/P2 对调；总体架构不变。

范围：

- 工程骨架、DI、设计系统、本地数据库、网络与认证。
- 同步引擎与全部 v1 黄金用例。
- RSS 解析与 Feed 刷新；OPML 导入按评审确认的范围实现。
- 播放、队列、收藏、历史、下载、本地搜索、设置。
- 通知与前台服务；Android Auto、小组件等放阶段 P4。

退出标准：

- F0 功能在 Android 上可用。
- 全部同步与 Feed 契约用例通过。
- 真机覆盖 Android 8、12、14、16；后台播放、下载、通知通过手工验收。
- 内部测试包可安装、可登录、可跨设备同步。
- 已知问题清单和性能基线记录。

### 6.3 P2：Apple 客户端（iOS + macOS）

范围：

- Xcode workspace、Swift packages、GRDB、SwiftUI 页面、平台服务。
- 同步引擎与全部 v1 黄金用例。
- 播放、后台下载、Feed 刷新、通知、设置。
- iOS 与 macOS 共享 `TinyCastKit`/`TinyCastData`/`TinyCastDesign`，UI 按平台适配。
- CarPlay、小组件、App Intents、Live Activities 放阶段 P4。

退出标准：

- F0 功能在 iOS 与 macOS 上可用。
- 契约用例通过；iOS 与 macOS 的后台播放、后台下载、锁屏控制通过真机验收。
- TestFlight 可分发；macOS 可公证并生成安装包。
- macOS 沙盒 entitlements 与用户选择文件路径验证通过；OPML 纳入范围时一并验收。

### 6.4 P3：桌面收口

- 回归桌面端在 P0 完成的 3.3.9 行为对齐；P0 之后新增的协议与 Feed 用例全部通过。
- 切换到生成的设计 token，移除运行时 HOCON 解析路径。
- 删除 `apps/desktop` 中的 Android/iOS/macOS target；确认 `web/` 是否保留。
- 更新文档、启动脚本、CI；桌面端定位为二级客户端。
- 评估是否冻结桌面端新功能；默认只做兼容性修复和同步/解析修复。

退出标准：

- 桌面端只保留 Windows/Linux 目标，构建与测试通过。
- 三端在同一云端账号下的订阅、收藏、历史、队列互通。
- 文档与实际功能一致。

### 6.5 P4：平台集成与发布

- CarPlay、Android Auto、小组件、App Intents、Live Activities、分享扩展、通知增强。
- App Store / Google Play / Windows 安装包 / Linux 包发布。
- 性能与稳定性长跑；崩溃与同步失败监控。
- 按功能矩阵关闭 F1 项；F2 不设关闭期限。

退出标准：

- 三个平台达到各自发布标准。
- 关键路径有监控和回滚方案。
- 发布文档、签名、版本号流程可重复执行。

## 7. 质量与发布

### 7.1 CI

拆分后必须接入托管 CI，至少四个 job：

- `contracts`：schema 快照校验、黄金用例格式校验、设计 token 生成漂移检查。
- `desktop`：`flutter analyze`、`flutter test`、Windows/Linux 构建（至少一个平台）。
- `android`：lint、单元测试、契约测试、assemble/AAB。
- `apple`：Swift 测试、契约测试、iOS 模拟器构建、macOS 构建。

Apple job 需要 macOS runner；Android 与桌面的分析与测试可在 Linux runner。Windows 安装包构建需要 Windows runner，放在发布流水线或 nightly，不阻塞每次 PR。CI 密钥只存平台签名与测试 Supabase 凭据，不存 service role key。

本地必须能通过 `just ci` 复现 CI 的关键步骤，避免“只有 CI 能跑”。

### 7.2 测试分层

- 契约测试：三端执行同一套同步与 Feed 用例，是跨端一致性的核心。
- 单元测试：领域规则、映射、日期/时长解析、墓碑、游标。
- 集成测试：内存数据库 + 假远端；真实 Supabase 测试项目做端到端同步。
- UI 测试：关键路径；不做像素级跨端对比。
- 手工验收：后台播放、后台下载、锁屏控制、通知、CarPlay/Android Auto、沙盒权限；OPML 文件选择在功能落地后加入。
- 端到端同步至少覆盖两台“客户端”：可以用两个内存客户端，或用脚本模拟一端，避免只能靠人工双设备验证。

### 7.3 发布

- Apple：TestFlight → App Store；macOS Developer ID 签名与公证，DMG/PKG 分发。
- Android：内部测试轨道 → 封闭测试 → 生产；AAB + Play App Signing。
- Windows：MSIX 或 Inno Setup；按渠道做代码签名。
- Linux：AppImage 或 Flatpak；明确沙盒权限与文件访问说明。
- 版本：根 `VERSION` 为产品版本，各平台构建号独立递增；发布脚本注入。
- 每个平台维护自己的发布检查清单；三端不要求同时发布。

### 7.4 文档

- 本设计作为架构决策记录，后续变更以 ADR 形式追加到 `docs/adr/`。
- `AGENTS.md` 更新为 monorepo 命令、契约测试和交付门。
- 每个 app 有独立 README：工具链、构建、测试、发布。
- 同步协议、Feed 归一化、墓碑与游标规则必须有独立文档，不能只存在于代码注释中。
- 每次协议或 schema 变更，同时更新契约文档、夹具和功能矩阵。

## 8. 风险与对策

- 三套业务逻辑漂移：黄金用例、功能矩阵、PR 检查清单；接受“同一修复做三次”的成本，不引入共享运行时。
- 1–2 人容量不足：严格按 P0→P1→P2→P3→P4 顺序；桌面端降为二级；CarPlay/Auto/小组件延后；不并行三端。
- Supabase schema 不可见：P0 先拉取并提交 migrations；CI 校验 schema 快照。
- 客户端内容时间被当作增量游标：旧内容上传后可能漏拉；P0 增加服务端 `server_updated_at` 触发器，黄金用例覆盖。
- 推送选择依赖 `pendingSync`：任何新的本地写路径忘记置位都会漏推；把置位封装在仓库写入层，PR 检查清单确认，并用单元测试覆盖所有写路径。
- 全局目录的拉取范围未收敛：v1 沿用现状，`podcasts`/`episodes` 的所有变更都会下发给每个客户端，不按订阅过滤；目录规模增大后首同步与增量同步的带宽、耗时会失控。P1 记录单轮拉取行数与耗时，v2 评估按订阅范围过滤或服务端聚合。
- 全局目录表写入边界未验证：P0 审计 RLS；P1 收敛到 RPC/Edge Function。
- 后台播放与下载的平台差异：不假设跨端一致；每端单独手工验收；把平台限制写入功能矩阵。
- 契约夹具维护成本：夹具保持纯 JSON/XML + 简单 runner，不引入共享运行时；用例数量宁少勿滥，优先覆盖删除、冲突、分页、失败语义。
- 发布面积从 1 个变 3 个：先做内部测试包，不急于上架；自动化签名与构建；每端发布检查清单。
- 协议随版本漂移：v1 冻结；破坏性变更走 v2；客户端声明协议版本。
- 无 iTunes ID 的播客无法跨设备同步：v1 沿用 `itunes_id` 冲突键，纯 RSS feed 只留在本地；v2 需评估以规范化 feed URL 作为第二唯一键。
- 桌面端长期分叉：契约测试 + 生成 token；默认冻结新功能（待评审确认）；P3 明确二级定位。
- 设备与系统覆盖不足：Android 覆盖 8/12/14/16；iOS 覆盖最低版本与最新版本；macOS 覆盖最低版本与最新版本。
- CarPlay entitlement 与 App Store 审核：在 Apple 客户端实现阶段提前申请与验证，不把它当作纯技术任务。
- Google OAuth 在 iOS 的审核风险：App Store 4.8 可能要求同时提供 Sign in with Apple 或等价选项；Apple 客户端实现前确认登录方案。
- 工具链与依赖升级：固定 Swift/Kotlin/Flutter 版本；升级单独提交并跑三端测试。
- 文档再次与代码脱节：功能矩阵由代码与测试驱动；每个阶段结束做一次文档审计。

## 9. 决策记录

已定决策：

- 采用方案 B：三端独立实现 + 共享契约，不共享运行时。
- 默认 Android 先行，Apple 随后；如果维护者更熟 Swift 或 Apple 是首要市场，可对调。
- Apple 使用 GRDB；Android 使用 Room；桌面继续使用 Isar Community。
- Apple 最低 iOS 17 / macOS 14；Android minSdk 26。相比现状提高下限，评审时最终确认。
- 传输 DTO 三端手写，不做跨语言代码生成；OpenAPI 快照和 payload 样本作为校验依据。
- 设计 token 从 HOCON 生成 Swift/Kotlin/Dart 常量；桌面 P3 切换到生成物。
- 同步协议 v1 冻结；客户端声明 `X-TinyCast-Sync-Protocol: 1`；破坏性变更走 v2。
- 增量拉取以服务端 `server_updated_at` 为游标；内容时间只用于合并新旧判断。
- 推送选择使用本地 `pendingSync` 标记，不依赖本地时钟；拉取合并不置位。
- `lastSyncTime` 只作同步游标，UI 的“上次同步时间”单独记录本地完成时间。
- 桌面端定位为二级客户端，保留 F0 核心能力，不要求平台集成功能。
- 无用户数据迁移；新客户端从空库开始，通过云端同步恢复数据。
- CI 从“没有”升级为四个 job；本地 `just ci` 与 CI 对齐。
- 过渡期保留桌面工程中的 Android/iOS/macOS target，原生端就绪后（P3）删除。

需要评审确认：

- P1/P2 是否按 Android → Apple 的顺序执行，还是对调。
- 是否接受 iOS 17 / macOS 14 / Android 8 的最低版本下限。
- OPML 导入是否纳入阶段 P1 首发；当前是未实现功能，不应继续在文档中宣称可用。
- 是否在 P1 就把全局目录写入收敛到 RPC/Edge Function，还是先审计 RLS、公开测试后再收敛。
- 桌面端 P3 是否冻结新功能，还是保留与原生端同步的功能节奏。
- 新剧集通知放在阶段 P4，还是提前到阶段 P1/P2 的功能迭代。
- v1 是否限制全局目录的拉取范围（仅已订阅播客及其剧集），还是沿用现状的全量增量拉取；若限制，拉取顺序需要改为订阅优先。
- 是否在 v2 优先设计基于 feed URL 的播客身份，解决无 iTunes ID feed 的跨设备同步。

## 10. 附录

### 10.1 现有实现参考

以下路径为 P0 移动前的当前仓库路径；P0 完成后桌面端代码位于 `apps/desktop/`。

- 同步核心：`lib/core/services/sync_service.dart`。
- 远端数据源与分页/分块：`lib/data/datasources/remote_sync_datasource.dart`。
- 墓碑与推送快照：`lib/core/services/sync_tombstone_store.dart`。
- 云字段映射：`lib/core/services/sync_mappers.dart`。
- RSS 解析与归一化：`lib/data/services/rss_parser_service.dart`。
- 主题解析：`lib/core/theme/theme_loader.dart`。
- 数据库与同步文档：`docs/reference/database.md`、`docs/debugging/sync_debug_guide.md`。
- 现有同步测试：`test/core/services/sync_service_test.dart`、`test/data/datasources/remote_sync_datasource_test.dart`、`test/data/datasources/remote_sync_datasource_pagination_test.dart`。
- 现有 RSS 测试与样本：`test/data/services/rss_parser_service_test.dart`、`test/test-data/anyway_rss.xml`。

### 10.2 契约目录示例

```text
packages/contracts/
├── schema/
│   ├── README.md
│   └── openapi.json
├── sync/
│   ├── PROTOCOL.md
│   ├── cases/
│   │   └── v1/
│   │       ├── first-sync-empty/
│   │       │   ├── meta.json
│   │       │   ├── local.json
│   │       │   ├── remote.json
│   │       │   ├── expected_local.json
│   │       │   └── expected_remote.json
│   │       └── ...
│   └── README.md
├── feeds/
│   ├── cases/
│   │   ├── rss-basic/
│   │   │   ├── meta.json
│   │   │   ├── input.xml
│   │   │   └── expected.json
│   │   └── ...
│   └── README.md
└── parity/
    └── features.md
```

### 10.3 同步用例格式示例

`meta.json`：

```json
{
  "protocolVersion": 1,
  "description": "本地取消收藏并移除队列项后，同轮拉取不得把它们加回",
  "userId": "user-a",
  "lastSyncTime": "2026-10-22T10:00:00.000Z",
  "now": "2026-10-22T10:05:00.000Z",
  "serverNow": "2026-10-22T10:05:00.000Z",
  "faults": []
}
```

`actions.json` 可选，用于描述同步前执行的本地操作：

```json
[
  { "type": "unfavorite", "episodeGuid": "ep-1" },
  { "type": "removeFromQueue", "episodeGuid": "ep-2" }
]
```

用例 runner 的职责：

1. 读取 `local.json` 初始化本地存储。
2. 读取 `remote.json` 初始化假远端。
3. 执行 `actions.json` 中的本地操作。
4. 运行同步引擎。
5. 比较本地与远端状态与期望文件。
6. 以 `meta.now` 作为本地固定时钟、`meta.serverNow`（缺省 `meta.now`）作为假远端时钟，按 schema 过滤非契约字段后再比较。
7. 输出差异路径，便于定位。

### 10.4 术语

- 游标：本地记录的 `lastSyncTime`，每用户独立；值取本轮增量拉取观察到的最大服务端 `server_updated_at`，只有同步完全成功才推进，不等于 UI 展示的同步完成时间。
- 墓碑：本地删除已同步记录后记录的待删除云端 ID 集合。
- 推送快照：本设备最后一次成功推送的订阅云端 ID 集合，用于防止远端列表缺失误删未推送成功的订阅。
- 黄金用例：三端共同执行的输入/期望输出样本。
- 契约：schema、协议、归一化规则、token 和功能矩阵的统称；不是运行时代码。
