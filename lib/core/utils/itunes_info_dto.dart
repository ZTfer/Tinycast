/// iTunes 信息数据传输对象
///
/// 封装从 iTunes Search API 获取的播客完整信息，
/// 用于数据库更新和模型转换。
class ITunesInfoDTO {
  /// iTunes 播客 ID
  final String? itunesId;

  /// 600x600 封面图 URL
  final String? itunesArtworkUrl600;

  /// 主要流派名称
  final String? itunesPrimaryGenreName;

  /// 流派列表
  final List<String>? itunesGenres;

  /// 流派 ID 列表
  final List<String>? itunesGenreIds;

  /// iTunes 详情页链接
  final String? itunesCollectionViewUrl;

  /// 国家代码
  final String? itunesCountry;

  /// 发布日期
  final DateTime? itunesReleaseDate;

  /// 播客成人内容标识
  final String? itunesCollectionExplicitness;

  /// 内容分级评级
  final String? itunesContentAdvisoryRating;

  const ITunesInfoDTO({
    this.itunesId,
    this.itunesArtworkUrl600,
    this.itunesPrimaryGenreName,
    this.itunesGenres,
    this.itunesGenreIds,
    this.itunesCollectionViewUrl,
    this.itunesCountry,
    this.itunesReleaseDate,
    this.itunesCollectionExplicitness,
    this.itunesContentAdvisoryRating,
  });

  /// 从 ITunesSearchResult 创建 DTO
  factory ITunesInfoDTO.fromSearchResult({
    required String? itunesId,
    required String? artworkUrl600,
    required String? primaryGenreName,
    required List<String>? genres,
    required List<String>? genreIds,
    required String? collectionViewUrl,
    required String? country,
    required DateTime? releaseDate,
    required String? collectionExplicitness,
    required String? contentAdvisoryRating,
  }) {
    return ITunesInfoDTO(
      itunesId: itunesId,
      itunesArtworkUrl600: artworkUrl600,
      itunesPrimaryGenreName: primaryGenreName,
      itunesGenres: genres,
      itunesGenreIds: genreIds,
      itunesCollectionViewUrl: collectionViewUrl,
      itunesCountry: country,
      itunesReleaseDate: releaseDate,
      itunesCollectionExplicitness: collectionExplicitness,
      itunesContentAdvisoryRating: contentAdvisoryRating,
    );
  }
}
