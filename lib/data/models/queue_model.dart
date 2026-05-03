import 'package:isar_community/isar.dart';

part 'queue_model.g.dart';

@collection
class Queue {
  Id id = Isar.autoIncrement;

  @Index()
  late int episodeId;

  String? episodeGuid;

  String? episodeITunesId;

  int? podcastId;

  String? podcastGuid;

  String? podcastITunesId;

  @Index()
  late int position;

  final DateTime addedAt = DateTime.now();
}
