import 'package:isar/isar.dart';

part 'podcast_model.g.dart';

/// Podcast 实体类
///
/// 表示一个播客节目，包含播客的基本信息。
@Collection()
class Podcast {
  /// 播客 ID
  final Id id = Isar.autoIncrement;

  /// 播客标题
  late String title;

  /// 播客作者
  late String author;

  /// 播客描述
  late String description;

  /// 封面 URL
  late String artworkUrl;

  /// RSS 订阅源 URL
  late String rssUrl;

  /// 最后更新时间
  late DateTime lastUpdated;

  /// 创建时间
  final DateTime createdAt = DateTime.now();
}
