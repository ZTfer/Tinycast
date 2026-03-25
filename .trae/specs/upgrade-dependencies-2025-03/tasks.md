# Tasks

- [x] Task 1: 升级 Isar Community 依赖
  - [x] SubTask 1.1: 更新 pubspec.yaml 中 isar_community 版本从 3.3.0 到 3.3.2
  - [x] SubTask 1.2: 更新 pubspec.yaml 中 isar_community_flutter_libs 版本从 3.3.0 到 3.3.2
  - [x] SubTask 1.3: 更新 pubspec.yaml 中 isar_community_generator 版本从 3.3.0 到 3.3.2

- [x] Task 2: 升级开发依赖
  - [x] SubTask 2.1: 更新 pubspec.yaml 中 build_runner 版本从 2.7.1 到 2.13.1
  - [x] SubTask 2.2: 更新 pubspec.yaml 中 mockito 到最新兼容版本 5.6.4
  - [x] SubTask 2.3: 运行 `flutter pub get` 获取新版本

- [x] Task 3: 验证升级结果
  - [x] SubTask 3.1: 运行 `flutter pub outdated` 确认没有可升级的依赖
  - [x] SubTask 3.2: 运行 `flutter analyze` 检查代码问题
  - [x] SubTask 3.3: 运行应用进行手动测试

## Task Dependencies

- [Task 2] 依赖 [Task 1]
- [Task 3] 依赖 [Task 2]
