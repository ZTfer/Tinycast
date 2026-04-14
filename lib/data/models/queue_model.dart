import 'package:isar_community/isar.dart';

part 'queue_model.g.dart';

@collection
class Queue {
  Id id = Isar.autoIncrement;

  @Index()
  late int episodeId;

  @Index()
  late int position;

  final DateTime addedAt = DateTime.now();
}
