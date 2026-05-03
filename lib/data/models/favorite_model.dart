import 'package:isar_community/isar.dart';

part 'favorite_model.g.dart';

@collection
class Favorite {
  Id id = Isar.autoIncrement;

  @Index()
  late int episodeId;

  String? episodeGuid;

  String? episodeITunesId;

  final DateTime createdAt = DateTime.now();
}
