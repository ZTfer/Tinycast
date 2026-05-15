/// Theme source toggle
///
/// [true]  - 使用 lib/core/theme 中的硬编码常量（编译时常量，性能最佳）
/// [false] - 使用 assets/themes 下的 .conf 文件（可热更新，直接编辑配置文件即可生效）
///
/// 默认 false，即优先使用 .conf 文件。
class ThemeSource {
  ThemeSource._();

  static const bool useHardcoded = false;
}
