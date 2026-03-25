# 升级依赖到最新版本 Spec (2025-03)

## Why

当前项目有 13 个可升级的依赖被锁定在旧版本，包括 isar_community 系列包和 build_runner 等重要依赖。升级这些依赖可以获取最新的 bug 修复、性能改进和安全更新。

## What Changes

- 升级 isar_community 从 3.3.0 到 3.3.2
- 升级 isar_community_flutter_libs 从 3.3.0 到 3.3.2
- 升级 build_runner 从 2.7.1 到 2.13.1
- 升级 isar_community_generator 从 3.3.0 到 3.3.2
- 升级 mockito 到最新版本
- 升级 test 到最新版本
- 更新 pubspec.lock 中的传递依赖

## Impact

- Affected specs: 所有使用 Isar 数据库和代码生成的功能
- Affected code: pubspec.yaml, pubspec.lock

## ADDED Requirements

### Requirement: 依赖版本升级

系统应当使用最新稳定版本的依赖包。

#### Scenario: 成功升级依赖

- **WHEN** 执行依赖升级
- **THEN** 所有依赖应当升级到最新兼容版本
- **AND** 应用应当能够正常编译和运行
- **AND** 所有现有功能应当正常工作

#### Scenario: 处理已弃用包

- **WHEN** 遇到已弃用的包 (js, build_resolvers, build_runner_core)
- **THEN** 记录这些弃用警告
- **AND** 在后续版本中考虑迁移方案

## MODIFIED Requirements

无

## REMOVED Requirements

无
