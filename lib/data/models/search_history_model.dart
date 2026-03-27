import 'package:isar_community/isar.dart';

part 'search_history_model.g.dart';

@collection
class SearchHistoryModel {
  Id id = Isar.autoIncrement;

  late String keyword;

  @Index()
  late DateTime searchedAt;
}
