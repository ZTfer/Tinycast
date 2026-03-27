class SearchHistory {
  final int id;
  final String keyword;
  final DateTime searchedAt;

  SearchHistory({
    required this.id,
    required this.keyword,
    required this.searchedAt,
  });
}
