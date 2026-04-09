import 'package:isar_community/isar.dart';

part 'favorite_model.g.dart';

@collection
class Favorite {
  Id id = Isar.autoIncrement;

  @Index()
  late int episodeId;

  final DateTime createdAt = DateTime.now();
}
