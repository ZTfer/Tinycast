/// Theme source toggle
///
/// [true]  - 使用 lib/core/theme 中的硬编码常量（编译时常量，性能最佳）
/// [false] - 使用 assets/themes 下的 .conf 文件（可热更新，直接编辑配置文件即可生效）
///
/// 切换为 false 前，请确保已通过 ThemeLoader 加载主题配置。
class ThemeSource {
  ThemeSource._();

  static const bool useHardcoded = true;
}
