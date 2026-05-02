// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPodcastCollection on Isar {
  IsarCollection<Podcast> get podcasts => this.collection();
}

const PodcastSchema = CollectionSchema(
  name: r'Podcast',
  id: -1143728065732125040,
  properties: {
    r'artworkPath': PropertySchema(
      id: 0,
      name: r'artworkPath',
      type: IsarType.string,
    ),
    r'artworkUrl': PropertySchema(
      id: 1,
      name: r'artworkUrl',
      type: IsarType.string,
    ),
    r'author': PropertySchema(id: 2, name: r'author', type: IsarType.string),
    r'categories': PropertySchema(
      id: 3,
      name: r'categories',
      type: IsarType.stringList,
    ),
    r'copyright': PropertySchema(
      id: 4,
      name: r'copyright',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 5,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'description': PropertySchema(
      id: 6,
      name: r'description',
      type: IsarType.string,
    ),
    r'episodeCount': PropertySchema(
      id: 7,
      name: r'episodeCount',
      type: IsarType.long,
    ),
    r'isExplicit': PropertySchema(
      id: 8,
      name: r'isExplicit',
      type: IsarType.bool,
    ),
    r'isSubscribed': PropertySchema(
      id: 9,
      name: r'isSubscribed',
      type: IsarType.bool,
    ),
    r'itunesArtworkUrl': PropertySchema(
      id: 10,
      name: r'itunesArtworkUrl',
      type: IsarType.string,
    ),
    r'itunesCollectionExplicitness': PropertySchema(
      id: 11,
      name: r'itunesCollectionExplicitness',
      type: IsarType.string,
    ),
    r'itunesCollectionViewUrl': PropertySchema(
      id: 12,
      name: r'itunesCollectionViewUrl',
      type: IsarType.string,
    ),
    r'itunesContentAdvisoryRating': PropertySchema(
      id: 13,
      name: r'itunesContentAdvisoryRating',
      type: IsarType.string,
    ),
    r'itunesCountry': PropertySchema(
      id: 14,
      name: r'itunesCountry',
      type: IsarType.string,
    ),
    r'itunesGenreIds': PropertySchema(
      id: 15,
      name: r'itunesGenreIds',
      type: IsarType.stringList,
    ),
    r'itunesGenres': PropertySchema(
      id: 16,
      name: r'itunesGenres',
      type: IsarType.stringList,
    ),
    r'itunesId': PropertySchema(
      id: 17,
      name: r'itunesId',
      type: IsarType.string,
    ),
    r'itunesPrimaryGenreName': PropertySchema(
      id: 18,
      name: r'itunesPrimaryGenreName',
      type: IsarType.string,
    ),
    r'itunesReleaseDate': PropertySchema(
      id: 19,
      name: r'itunesReleaseDate',
      type: IsarType.dateTime,
    ),
    r'keywords': PropertySchema(
      id: 20,
      name: r'keywords',
      type: IsarType.stringList,
    ),
    r'language': PropertySchema(
      id: 21,
      name: r'language',
      type: IsarType.string,
    ),
    r'lastUpdated': PropertySchema(
      id: 22,
      name: r'lastUpdated',
      type: IsarType.dateTime,
    ),
    r'ownerEmail': PropertySchema(
      id: 23,
      name: r'ownerEmail',
      type: IsarType.string,
    ),
    r'ownerName': PropertySchema(
      id: 24,
      name: r'ownerName',
      type: IsarType.string,
    ),
    r'rssUrl': PropertySchema(id: 25, name: r'rssUrl', type: IsarType.string),
    r'subscribedAt': PropertySchema(
      id: 26,
      name: r'subscribedAt',
      type: IsarType.dateTime,
    ),
    r'subtitle': PropertySchema(
      id: 27,
      name: r'subtitle',
      type: IsarType.string,
    ),
    r'title': PropertySchema(id: 28, name: r'title', type: IsarType.string),
    r'websiteUrl': PropertySchema(
      id: 29,
      name: r'websiteUrl',
      type: IsarType.string,
    ),
  },

  estimateSize: _podcastEstimateSize,
  serialize: _podcastSerialize,
  deserialize: _podcastDeserialize,
  deserializeProp: _podcastDeserializeProp,
  idName: r'id',
  indexes: {
    r'title': IndexSchema(
      id: -7636685945352118059,
      name: r'title',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'title',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'rssUrl': IndexSchema(
      id: 5387595033344101436,
      name: r'rssUrl',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'rssUrl',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'lastUpdated': IndexSchema(
      id: 8989359681631629925,
      name: r'lastUpdated',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'lastUpdated',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _podcastGetId,
  getLinks: _podcastGetLinks,
  attach: _podcastAttach,
  version: '3.3.2',
);

int _podcastEstimateSize(
  Podcast object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.artworkPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.artworkUrl.length * 3;
  bytesCount += 3 + object.author.length * 3;
  {
    final list = object.categories;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount += value.length * 3;
        }
      }
    }
  }
  {
    final value = object.copyright;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.description.length * 3;
  {
    final value = object.itunesArtworkUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.itunesCollectionExplicitness;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.itunesCollectionViewUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.itunesContentAdvisoryRating;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.itunesCountry;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final list = object.itunesGenreIds;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount += value.length * 3;
        }
      }
    }
  }
  {
    final list = object.itunesGenres;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount += value.length * 3;
        }
      }
    }
  }
  {
    final value = object.itunesId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.itunesPrimaryGenreName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final list = object.keywords;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount += value.length * 3;
        }
      }
    }
  }
  {
    final value = object.language;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.ownerEmail;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.ownerName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.rssUrl.length * 3;
  {
    final value = object.subtitle;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.title.length * 3;
  {
    final value = object.websiteUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _podcastSerialize(
  Podcast object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.artworkPath);
  writer.writeString(offsets[1], object.artworkUrl);
  writer.writeString(offsets[2], object.author);
  writer.writeStringList(offsets[3], object.categories);
  writer.writeString(offsets[4], object.copyright);
  writer.writeDateTime(offsets[5], object.createdAt);
  writer.writeString(offsets[6], object.description);
  writer.writeLong(offsets[7], object.episodeCount);
  writer.writeBool(offsets[8], object.isExplicit);
  writer.writeBool(offsets[9], object.isSubscribed);
  writer.writeString(offsets[10], object.itunesArtworkUrl);
  writer.writeString(offsets[11], object.itunesCollectionExplicitness);
  writer.writeString(offsets[12], object.itunesCollectionViewUrl);
  writer.writeString(offsets[13], object.itunesContentAdvisoryRating);
  writer.writeString(offsets[14], object.itunesCountry);
  writer.writeStringList(offsets[15], object.itunesGenreIds);
  writer.writeStringList(offsets[16], object.itunesGenres);
  writer.writeString(offsets[17], object.itunesId);
  writer.writeString(offsets[18], object.itunesPrimaryGenreName);
  writer.writeDateTime(offsets[19], object.itunesReleaseDate);
  writer.writeStringList(offsets[20], object.keywords);
  writer.writeString(offsets[21], object.language);
  writer.writeDateTime(offsets[22], object.lastUpdated);
  writer.writeString(offsets[23], object.ownerEmail);
  writer.writeString(offsets[24], object.ownerName);
  writer.writeString(offsets[25], object.rssUrl);
  writer.writeDateTime(offsets[26], object.subscribedAt);
  writer.writeString(offsets[27], object.subtitle);
  writer.writeString(offsets[28], object.title);
  writer.writeString(offsets[29], object.websiteUrl);
}

Podcast _podcastDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Podcast();
  object.artworkPath = reader.readStringOrNull(offsets[0]);
  object.artworkUrl = reader.readString(offsets[1]);
  object.author = reader.readString(offsets[2]);
  object.categories = reader.readStringList(offsets[3]);
  object.copyright = reader.readStringOrNull(offsets[4]);
  object.description = reader.readString(offsets[6]);
  object.episodeCount = reader.readLong(offsets[7]);
  object.id = id;
  object.isExplicit = reader.readBool(offsets[8]);
  object.isSubscribed = reader.readBool(offsets[9]);
  object.itunesArtworkUrl = reader.readStringOrNull(offsets[10]);
  object.itunesCollectionExplicitness = reader.readStringOrNull(offsets[11]);
  object.itunesCollectionViewUrl = reader.readStringOrNull(offsets[12]);
  object.itunesContentAdvisoryRating = reader.readStringOrNull(offsets[13]);
  object.itunesCountry = reader.readStringOrNull(offsets[14]);
  object.itunesGenreIds = reader.readStringList(offsets[15]);
  object.itunesGenres = reader.readStringList(offsets[16]);
  object.itunesId = reader.readStringOrNull(offsets[17]);
  object.itunesPrimaryGenreName = reader.readStringOrNull(offsets[18]);
  object.itunesReleaseDate = reader.readDateTimeOrNull(offsets[19]);
  object.keywords = reader.readStringList(offsets[20]);
  object.language = reader.readStringOrNull(offsets[21]);
  object.lastUpdated = reader.readDateTime(offsets[22]);
  object.ownerEmail = reader.readStringOrNull(offsets[23]);
  object.ownerName = reader.readStringOrNull(offsets[24]);
  object.rssUrl = reader.readString(offsets[25]);
  object.subscribedAt = reader.readDateTimeOrNull(offsets[26]);
  object.subtitle = reader.readStringOrNull(offsets[27]);
  object.title = reader.readString(offsets[28]);
  object.websiteUrl = reader.readStringOrNull(offsets[29]);
  return object;
}

P _podcastDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readStringList(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readBool(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    case 14:
      return (reader.readStringOrNull(offset)) as P;
    case 15:
      return (reader.readStringList(offset)) as P;
    case 16:
      return (reader.readStringList(offset)) as P;
    case 17:
      return (reader.readStringOrNull(offset)) as P;
    case 18:
      return (reader.readStringOrNull(offset)) as P;
    case 19:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 20:
      return (reader.readStringList(offset)) as P;
    case 21:
      return (reader.readStringOrNull(offset)) as P;
    case 22:
      return (reader.readDateTime(offset)) as P;
    case 23:
      return (reader.readStringOrNull(offset)) as P;
    case 24:
      return (reader.readStringOrNull(offset)) as P;
    case 25:
      return (reader.readString(offset)) as P;
    case 26:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 27:
      return (reader.readStringOrNull(offset)) as P;
    case 28:
      return (reader.readString(offset)) as P;
    case 29:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _podcastGetId(Podcast object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _podcastGetLinks(Podcast object) {
  return [];
}

void _podcastAttach(IsarCollection<dynamic> col, Id id, Podcast object) {
  object.id = id;
}

extension PodcastByIndex on IsarCollection<Podcast> {
  Future<Podcast?> getByRssUrl(String rssUrl) {
    return getByIndex(r'rssUrl', [rssUrl]);
  }

  Podcast? getByRssUrlSync(String rssUrl) {
    return getByIndexSync(r'rssUrl', [rssUrl]);
  }

  Future<bool> deleteByRssUrl(String rssUrl) {
    return deleteByIndex(r'rssUrl', [rssUrl]);
  }

  bool deleteByRssUrlSync(String rssUrl) {
    return deleteByIndexSync(r'rssUrl', [rssUrl]);
  }

  Future<List<Podcast?>> getAllByRssUrl(List<String> rssUrlValues) {
    final values = rssUrlValues.map((e) => [e]).toList();
    return getAllByIndex(r'rssUrl', values);
  }

  List<Podcast?> getAllByRssUrlSync(List<String> rssUrlValues) {
    final values = rssUrlValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'rssUrl', values);
  }

  Future<int> deleteAllByRssUrl(List<String> rssUrlValues) {
    final values = rssUrlValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'rssUrl', values);
  }

  int deleteAllByRssUrlSync(List<String> rssUrlValues) {
    final values = rssUrlValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'rssUrl', values);
  }

  Future<Id> putByRssUrl(Podcast object) {
    return putByIndex(r'rssUrl', object);
  }

  Id putByRssUrlSync(Podcast object, {bool saveLinks = true}) {
    return putByIndexSync(r'rssUrl', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByRssUrl(List<Podcast> objects) {
    return putAllByIndex(r'rssUrl', objects);
  }

  List<Id> putAllByRssUrlSync(List<Podcast> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'rssUrl', objects, saveLinks: saveLinks);
  }
}

extension PodcastQueryWhereSort on QueryBuilder<Podcast, Podcast, QWhere> {
  QueryBuilder<Podcast, Podcast, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterWhere> anyLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'lastUpdated'),
      );
    });
  }
}

extension PodcastQueryWhere on QueryBuilder<Podcast, Podcast, QWhereClause> {
  QueryBuilder<Podcast, Podcast, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterWhereClause> titleEqualTo(String title) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'title', value: [title]),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterWhereClause> titleNotEqualTo(
    String title,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'title',
                lower: [],
                upper: [title],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'title',
                lower: [title],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'title',
                lower: [title],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'title',
                lower: [],
                upper: [title],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterWhereClause> rssUrlEqualTo(
    String rssUrl,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'rssUrl', value: [rssUrl]),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterWhereClause> rssUrlNotEqualTo(
    String rssUrl,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'rssUrl',
                lower: [],
                upper: [rssUrl],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'rssUrl',
                lower: [rssUrl],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'rssUrl',
                lower: [rssUrl],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'rssUrl',
                lower: [],
                upper: [rssUrl],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterWhereClause> lastUpdatedEqualTo(
    DateTime lastUpdated,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'lastUpdated',
          value: [lastUpdated],
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterWhereClause> lastUpdatedNotEqualTo(
    DateTime lastUpdated,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'lastUpdated',
                lower: [],
                upper: [lastUpdated],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'lastUpdated',
                lower: [lastUpdated],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'lastUpdated',
                lower: [lastUpdated],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'lastUpdated',
                lower: [],
                upper: [lastUpdated],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterWhereClause> lastUpdatedGreaterThan(
    DateTime lastUpdated, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'lastUpdated',
          lower: [lastUpdated],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterWhereClause> lastUpdatedLessThan(
    DateTime lastUpdated, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'lastUpdated',
          lower: [],
          upper: [lastUpdated],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterWhereClause> lastUpdatedBetween(
    DateTime lowerLastUpdated,
    DateTime upperLastUpdated, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'lastUpdated',
          lower: [lowerLastUpdated],
          includeLower: includeLower,
          upper: [upperLastUpdated],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension PodcastQueryFilter
    on QueryBuilder<Podcast, Podcast, QFilterCondition> {
  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> artworkPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'artworkPath'),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> artworkPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'artworkPath'),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> artworkPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'artworkPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> artworkPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'artworkPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> artworkPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'artworkPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> artworkPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'artworkPath',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> artworkPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'artworkPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> artworkPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'artworkPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> artworkPathContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'artworkPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> artworkPathMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'artworkPath',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> artworkPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'artworkPath', value: ''),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  artworkPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'artworkPath', value: ''),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> artworkUrlEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'artworkUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> artworkUrlGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'artworkUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> artworkUrlLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'artworkUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> artworkUrlBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'artworkUrl',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> artworkUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'artworkUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> artworkUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'artworkUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> artworkUrlContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'artworkUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> artworkUrlMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'artworkUrl',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> artworkUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'artworkUrl', value: ''),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> artworkUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'artworkUrl', value: ''),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> authorEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'author',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> authorGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'author',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> authorLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'author',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> authorBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'author',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> authorStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'author',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> authorEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'author',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> authorContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'author',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> authorMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'author',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> authorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'author', value: ''),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> authorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'author', value: ''),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> categoriesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'categories'),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> categoriesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'categories'),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  categoriesElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'categories',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  categoriesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'categories',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  categoriesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'categories',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  categoriesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'categories',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  categoriesElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'categories',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  categoriesElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'categories',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  categoriesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'categories',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  categoriesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'categories',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  categoriesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'categories', value: ''),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  categoriesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'categories', value: ''),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> categoriesLengthEqualTo(
    int length,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'categories', length, true, length, true);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> categoriesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'categories', 0, true, 0, true);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> categoriesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'categories', 0, false, 999999, true);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  categoriesLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'categories', 0, true, length, include);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  categoriesLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'categories', length, include, 999999, true);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> categoriesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'categories',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> copyrightIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'copyright'),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> copyrightIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'copyright'),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> copyrightEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'copyright',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> copyrightGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'copyright',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> copyrightLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'copyright',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> copyrightBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'copyright',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> copyrightStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'copyright',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> copyrightEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'copyright',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> copyrightContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'copyright',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> copyrightMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'copyright',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> copyrightIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'copyright', value: ''),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> copyrightIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'copyright', value: ''),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> createdAtEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'createdAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> descriptionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> descriptionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> descriptionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> descriptionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'description',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> descriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> descriptionContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> descriptionMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'description',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'description', value: ''),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'description', value: ''),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> episodeCountEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'episodeCount', value: value),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> episodeCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'episodeCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> episodeCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'episodeCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> episodeCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'episodeCount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> isExplicitEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isExplicit', value: value),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> isSubscribedEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isSubscribed', value: value),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesArtworkUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'itunesArtworkUrl'),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesArtworkUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'itunesArtworkUrl'),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> itunesArtworkUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'itunesArtworkUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesArtworkUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'itunesArtworkUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesArtworkUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'itunesArtworkUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> itunesArtworkUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'itunesArtworkUrl',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesArtworkUrlStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'itunesArtworkUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesArtworkUrlEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'itunesArtworkUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesArtworkUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'itunesArtworkUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> itunesArtworkUrlMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'itunesArtworkUrl',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesArtworkUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'itunesArtworkUrl', value: ''),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesArtworkUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'itunesArtworkUrl', value: ''),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesCollectionExplicitnessIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'itunesCollectionExplicitness'),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesCollectionExplicitnessIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(
          property: r'itunesCollectionExplicitness',
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesCollectionExplicitnessEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'itunesCollectionExplicitness',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesCollectionExplicitnessGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'itunesCollectionExplicitness',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesCollectionExplicitnessLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'itunesCollectionExplicitness',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesCollectionExplicitnessBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'itunesCollectionExplicitness',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesCollectionExplicitnessStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'itunesCollectionExplicitness',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesCollectionExplicitnessEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'itunesCollectionExplicitness',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesCollectionExplicitnessContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'itunesCollectionExplicitness',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesCollectionExplicitnessMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'itunesCollectionExplicitness',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesCollectionExplicitnessIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'itunesCollectionExplicitness',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesCollectionExplicitnessIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'itunesCollectionExplicitness',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesCollectionViewUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'itunesCollectionViewUrl'),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesCollectionViewUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'itunesCollectionViewUrl'),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesCollectionViewUrlEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'itunesCollectionViewUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesCollectionViewUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'itunesCollectionViewUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesCollectionViewUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'itunesCollectionViewUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesCollectionViewUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'itunesCollectionViewUrl',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesCollectionViewUrlStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'itunesCollectionViewUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesCollectionViewUrlEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'itunesCollectionViewUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesCollectionViewUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'itunesCollectionViewUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesCollectionViewUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'itunesCollectionViewUrl',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesCollectionViewUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'itunesCollectionViewUrl',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesCollectionViewUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'itunesCollectionViewUrl',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesContentAdvisoryRatingIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'itunesContentAdvisoryRating'),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesContentAdvisoryRatingIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(
          property: r'itunesContentAdvisoryRating',
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesContentAdvisoryRatingEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'itunesContentAdvisoryRating',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesContentAdvisoryRatingGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'itunesContentAdvisoryRating',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesContentAdvisoryRatingLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'itunesContentAdvisoryRating',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesContentAdvisoryRatingBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'itunesContentAdvisoryRating',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesContentAdvisoryRatingStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'itunesContentAdvisoryRating',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesContentAdvisoryRatingEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'itunesContentAdvisoryRating',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesContentAdvisoryRatingContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'itunesContentAdvisoryRating',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesContentAdvisoryRatingMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'itunesContentAdvisoryRating',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesContentAdvisoryRatingIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'itunesContentAdvisoryRating',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesContentAdvisoryRatingIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'itunesContentAdvisoryRating',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> itunesCountryIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'itunesCountry'),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesCountryIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'itunesCountry'),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> itunesCountryEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'itunesCountry',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesCountryGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'itunesCountry',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> itunesCountryLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'itunesCountry',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> itunesCountryBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'itunesCountry',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> itunesCountryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'itunesCountry',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> itunesCountryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'itunesCountry',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> itunesCountryContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'itunesCountry',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> itunesCountryMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'itunesCountry',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> itunesCountryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'itunesCountry', value: ''),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesCountryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'itunesCountry', value: ''),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> itunesGenreIdsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'itunesGenreIds'),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesGenreIdsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'itunesGenreIds'),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesGenreIdsElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'itunesGenreIds',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesGenreIdsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'itunesGenreIds',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesGenreIdsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'itunesGenreIds',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesGenreIdsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'itunesGenreIds',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesGenreIdsElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'itunesGenreIds',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesGenreIdsElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'itunesGenreIds',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesGenreIdsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'itunesGenreIds',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesGenreIdsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'itunesGenreIds',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesGenreIdsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'itunesGenreIds', value: ''),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesGenreIdsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'itunesGenreIds', value: ''),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesGenreIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'itunesGenreIds', length, true, length, true);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesGenreIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'itunesGenreIds', 0, true, 0, true);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesGenreIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'itunesGenreIds', 0, false, 999999, true);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesGenreIdsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'itunesGenreIds', 0, true, length, include);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesGenreIdsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'itunesGenreIds', length, include, 999999, true);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesGenreIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'itunesGenreIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> itunesGenresIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'itunesGenres'),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesGenresIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'itunesGenres'),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesGenresElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'itunesGenres',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesGenresElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'itunesGenres',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesGenresElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'itunesGenres',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesGenresElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'itunesGenres',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesGenresElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'itunesGenres',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesGenresElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'itunesGenres',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesGenresElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'itunesGenres',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesGenresElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'itunesGenres',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesGenresElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'itunesGenres', value: ''),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesGenresElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'itunesGenres', value: ''),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesGenresLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'itunesGenres', length, true, length, true);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> itunesGenresIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'itunesGenres', 0, true, 0, true);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesGenresIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'itunesGenres', 0, false, 999999, true);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesGenresLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'itunesGenres', 0, true, length, include);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesGenresLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'itunesGenres', length, include, 999999, true);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesGenresLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'itunesGenres',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> itunesIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'itunesId'),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> itunesIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'itunesId'),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> itunesIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'itunesId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> itunesIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'itunesId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> itunesIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'itunesId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> itunesIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'itunesId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> itunesIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'itunesId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> itunesIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'itunesId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> itunesIdContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'itunesId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> itunesIdMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'itunesId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> itunesIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'itunesId', value: ''),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> itunesIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'itunesId', value: ''),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesPrimaryGenreNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'itunesPrimaryGenreName'),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesPrimaryGenreNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'itunesPrimaryGenreName'),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesPrimaryGenreNameEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'itunesPrimaryGenreName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesPrimaryGenreNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'itunesPrimaryGenreName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesPrimaryGenreNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'itunesPrimaryGenreName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesPrimaryGenreNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'itunesPrimaryGenreName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesPrimaryGenreNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'itunesPrimaryGenreName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesPrimaryGenreNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'itunesPrimaryGenreName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesPrimaryGenreNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'itunesPrimaryGenreName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesPrimaryGenreNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'itunesPrimaryGenreName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesPrimaryGenreNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'itunesPrimaryGenreName', value: ''),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesPrimaryGenreNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'itunesPrimaryGenreName',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesReleaseDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'itunesReleaseDate'),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesReleaseDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'itunesReleaseDate'),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesReleaseDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'itunesReleaseDate', value: value),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesReleaseDateGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'itunesReleaseDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesReleaseDateLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'itunesReleaseDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  itunesReleaseDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'itunesReleaseDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> keywordsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'keywords'),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> keywordsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'keywords'),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> keywordsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'keywords',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  keywordsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'keywords',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> keywordsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'keywords',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> keywordsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'keywords',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  keywordsElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'keywords',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> keywordsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'keywords',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> keywordsElementContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'keywords',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> keywordsElementMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'keywords',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  keywordsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'keywords', value: ''),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  keywordsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'keywords', value: ''),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> keywordsLengthEqualTo(
    int length,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'keywords', length, true, length, true);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> keywordsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'keywords', 0, true, 0, true);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> keywordsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'keywords', 0, false, 999999, true);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> keywordsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'keywords', 0, true, length, include);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  keywordsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'keywords', length, include, 999999, true);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> keywordsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'keywords',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> languageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'language'),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> languageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'language'),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> languageEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'language',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> languageGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'language',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> languageLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'language',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> languageBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'language',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> languageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'language',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> languageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'language',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> languageContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'language',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> languageMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'language',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> languageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'language', value: ''),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> languageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'language', value: ''),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> lastUpdatedEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastUpdated', value: value),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> lastUpdatedGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastUpdated',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> lastUpdatedLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastUpdated',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> lastUpdatedBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastUpdated',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> ownerEmailIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'ownerEmail'),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> ownerEmailIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'ownerEmail'),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> ownerEmailEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'ownerEmail',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> ownerEmailGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'ownerEmail',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> ownerEmailLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'ownerEmail',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> ownerEmailBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'ownerEmail',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> ownerEmailStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'ownerEmail',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> ownerEmailEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'ownerEmail',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> ownerEmailContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'ownerEmail',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> ownerEmailMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'ownerEmail',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> ownerEmailIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'ownerEmail', value: ''),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> ownerEmailIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'ownerEmail', value: ''),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> ownerNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'ownerName'),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> ownerNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'ownerName'),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> ownerNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'ownerName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> ownerNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'ownerName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> ownerNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'ownerName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> ownerNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'ownerName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> ownerNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'ownerName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> ownerNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'ownerName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> ownerNameContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'ownerName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> ownerNameMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'ownerName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> ownerNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'ownerName', value: ''),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> ownerNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'ownerName', value: ''),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> rssUrlEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'rssUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> rssUrlGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'rssUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> rssUrlLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'rssUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> rssUrlBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'rssUrl',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> rssUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'rssUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> rssUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'rssUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> rssUrlContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'rssUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> rssUrlMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'rssUrl',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> rssUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'rssUrl', value: ''),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> rssUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'rssUrl', value: ''),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> subscribedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'subscribedAt'),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
  subscribedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'subscribedAt'),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> subscribedAtEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'subscribedAt', value: value),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> subscribedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'subscribedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> subscribedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'subscribedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> subscribedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'subscribedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> subtitleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'subtitle'),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> subtitleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'subtitle'),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> subtitleEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'subtitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> subtitleGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'subtitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> subtitleLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'subtitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> subtitleBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'subtitle',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> subtitleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'subtitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> subtitleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'subtitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> subtitleContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'subtitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> subtitleMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'subtitle',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> subtitleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'subtitle', value: ''),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> subtitleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'subtitle', value: ''),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'title',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> titleContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> titleMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'title',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> websiteUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'websiteUrl'),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> websiteUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'websiteUrl'),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> websiteUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'websiteUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> websiteUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'websiteUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> websiteUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'websiteUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> websiteUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'websiteUrl',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> websiteUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'websiteUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> websiteUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'websiteUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> websiteUrlContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'websiteUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> websiteUrlMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'websiteUrl',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> websiteUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'websiteUrl', value: ''),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> websiteUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'websiteUrl', value: ''),
      );
    });
  }
}

extension PodcastQueryObject
    on QueryBuilder<Podcast, Podcast, QFilterCondition> {}

extension PodcastQueryLinks
    on QueryBuilder<Podcast, Podcast, QFilterCondition> {}

extension PodcastQuerySortBy on QueryBuilder<Podcast, Podcast, QSortBy> {
  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByArtworkPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artworkPath', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByArtworkPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artworkPath', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByArtworkUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artworkUrl', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByArtworkUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artworkUrl', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByAuthor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'author', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByAuthorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'author', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByCopyright() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'copyright', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByCopyrightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'copyright', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByEpisodeCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeCount', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByEpisodeCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeCount', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByIsExplicit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isExplicit', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByIsExplicitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isExplicit', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByIsSubscribed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSubscribed', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByIsSubscribedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSubscribed', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByItunesArtworkUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itunesArtworkUrl', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByItunesArtworkUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itunesArtworkUrl', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy>
  sortByItunesCollectionExplicitness() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itunesCollectionExplicitness', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy>
  sortByItunesCollectionExplicitnessDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itunesCollectionExplicitness', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByItunesCollectionViewUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itunesCollectionViewUrl', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy>
  sortByItunesCollectionViewUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itunesCollectionViewUrl', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy>
  sortByItunesContentAdvisoryRating() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itunesContentAdvisoryRating', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy>
  sortByItunesContentAdvisoryRatingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itunesContentAdvisoryRating', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByItunesCountry() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itunesCountry', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByItunesCountryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itunesCountry', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByItunesId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itunesId', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByItunesIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itunesId', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByItunesPrimaryGenreName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itunesPrimaryGenreName', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy>
  sortByItunesPrimaryGenreNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itunesPrimaryGenreName', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByItunesReleaseDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itunesReleaseDate', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByItunesReleaseDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itunesReleaseDate', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByLanguage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByLanguageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByOwnerEmail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerEmail', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByOwnerEmailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerEmail', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByOwnerName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerName', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByOwnerNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerName', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByRssUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rssUrl', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByRssUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rssUrl', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortBySubscribedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subscribedAt', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortBySubscribedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subscribedAt', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortBySubtitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtitle', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortBySubtitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtitle', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByWebsiteUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'websiteUrl', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByWebsiteUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'websiteUrl', Sort.desc);
    });
  }
}

extension PodcastQuerySortThenBy
    on QueryBuilder<Podcast, Podcast, QSortThenBy> {
  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByArtworkPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artworkPath', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByArtworkPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artworkPath', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByArtworkUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artworkUrl', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByArtworkUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artworkUrl', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByAuthor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'author', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByAuthorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'author', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByCopyright() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'copyright', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByCopyrightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'copyright', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByEpisodeCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeCount', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByEpisodeCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeCount', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByIsExplicit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isExplicit', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByIsExplicitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isExplicit', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByIsSubscribed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSubscribed', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByIsSubscribedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSubscribed', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByItunesArtworkUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itunesArtworkUrl', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByItunesArtworkUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itunesArtworkUrl', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy>
  thenByItunesCollectionExplicitness() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itunesCollectionExplicitness', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy>
  thenByItunesCollectionExplicitnessDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itunesCollectionExplicitness', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByItunesCollectionViewUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itunesCollectionViewUrl', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy>
  thenByItunesCollectionViewUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itunesCollectionViewUrl', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy>
  thenByItunesContentAdvisoryRating() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itunesContentAdvisoryRating', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy>
  thenByItunesContentAdvisoryRatingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itunesContentAdvisoryRating', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByItunesCountry() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itunesCountry', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByItunesCountryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itunesCountry', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByItunesId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itunesId', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByItunesIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itunesId', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByItunesPrimaryGenreName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itunesPrimaryGenreName', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy>
  thenByItunesPrimaryGenreNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itunesPrimaryGenreName', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByItunesReleaseDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itunesReleaseDate', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByItunesReleaseDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itunesReleaseDate', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByLanguage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByLanguageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByOwnerEmail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerEmail', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByOwnerEmailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerEmail', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByOwnerName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerName', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByOwnerNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerName', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByRssUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rssUrl', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByRssUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rssUrl', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenBySubscribedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subscribedAt', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenBySubscribedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subscribedAt', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenBySubtitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtitle', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenBySubtitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtitle', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByWebsiteUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'websiteUrl', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByWebsiteUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'websiteUrl', Sort.desc);
    });
  }
}

extension PodcastQueryWhereDistinct
    on QueryBuilder<Podcast, Podcast, QDistinct> {
  QueryBuilder<Podcast, Podcast, QDistinct> distinctByArtworkPath({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'artworkPath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Podcast, Podcast, QDistinct> distinctByArtworkUrl({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'artworkUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Podcast, Podcast, QDistinct> distinctByAuthor({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'author', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Podcast, Podcast, QDistinct> distinctByCategories() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'categories');
    });
  }

  QueryBuilder<Podcast, Podcast, QDistinct> distinctByCopyright({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'copyright', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Podcast, Podcast, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<Podcast, Podcast, QDistinct> distinctByDescription({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Podcast, Podcast, QDistinct> distinctByEpisodeCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'episodeCount');
    });
  }

  QueryBuilder<Podcast, Podcast, QDistinct> distinctByIsExplicit() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isExplicit');
    });
  }

  QueryBuilder<Podcast, Podcast, QDistinct> distinctByIsSubscribed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSubscribed');
    });
  }

  QueryBuilder<Podcast, Podcast, QDistinct> distinctByItunesArtworkUrl({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'itunesArtworkUrl',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QDistinct>
  distinctByItunesCollectionExplicitness({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'itunesCollectionExplicitness',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QDistinct> distinctByItunesCollectionViewUrl({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'itunesCollectionViewUrl',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QDistinct>
  distinctByItunesContentAdvisoryRating({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'itunesContentAdvisoryRating',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QDistinct> distinctByItunesCountry({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'itunesCountry',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QDistinct> distinctByItunesGenreIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'itunesGenreIds');
    });
  }

  QueryBuilder<Podcast, Podcast, QDistinct> distinctByItunesGenres() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'itunesGenres');
    });
  }

  QueryBuilder<Podcast, Podcast, QDistinct> distinctByItunesId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'itunesId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Podcast, Podcast, QDistinct> distinctByItunesPrimaryGenreName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'itunesPrimaryGenreName',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QDistinct> distinctByItunesReleaseDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'itunesReleaseDate');
    });
  }

  QueryBuilder<Podcast, Podcast, QDistinct> distinctByKeywords() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'keywords');
    });
  }

  QueryBuilder<Podcast, Podcast, QDistinct> distinctByLanguage({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'language', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Podcast, Podcast, QDistinct> distinctByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdated');
    });
  }

  QueryBuilder<Podcast, Podcast, QDistinct> distinctByOwnerEmail({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ownerEmail', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Podcast, Podcast, QDistinct> distinctByOwnerName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ownerName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Podcast, Podcast, QDistinct> distinctByRssUrl({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rssUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Podcast, Podcast, QDistinct> distinctBySubscribedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subscribedAt');
    });
  }

  QueryBuilder<Podcast, Podcast, QDistinct> distinctBySubtitle({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subtitle', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Podcast, Podcast, QDistinct> distinctByTitle({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Podcast, Podcast, QDistinct> distinctByWebsiteUrl({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'websiteUrl', caseSensitive: caseSensitive);
    });
  }
}

extension PodcastQueryProperty
    on QueryBuilder<Podcast, Podcast, QQueryProperty> {
  QueryBuilder<Podcast, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Podcast, String?, QQueryOperations> artworkPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'artworkPath');
    });
  }

  QueryBuilder<Podcast, String, QQueryOperations> artworkUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'artworkUrl');
    });
  }

  QueryBuilder<Podcast, String, QQueryOperations> authorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'author');
    });
  }

  QueryBuilder<Podcast, List<String>?, QQueryOperations> categoriesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'categories');
    });
  }

  QueryBuilder<Podcast, String?, QQueryOperations> copyrightProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'copyright');
    });
  }

  QueryBuilder<Podcast, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<Podcast, String, QQueryOperations> descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<Podcast, int, QQueryOperations> episodeCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'episodeCount');
    });
  }

  QueryBuilder<Podcast, bool, QQueryOperations> isExplicitProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isExplicit');
    });
  }

  QueryBuilder<Podcast, bool, QQueryOperations> isSubscribedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSubscribed');
    });
  }

  QueryBuilder<Podcast, String?, QQueryOperations> itunesArtworkUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'itunesArtworkUrl');
    });
  }

  QueryBuilder<Podcast, String?, QQueryOperations>
  itunesCollectionExplicitnessProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'itunesCollectionExplicitness');
    });
  }

  QueryBuilder<Podcast, String?, QQueryOperations>
  itunesCollectionViewUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'itunesCollectionViewUrl');
    });
  }

  QueryBuilder<Podcast, String?, QQueryOperations>
  itunesContentAdvisoryRatingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'itunesContentAdvisoryRating');
    });
  }

  QueryBuilder<Podcast, String?, QQueryOperations> itunesCountryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'itunesCountry');
    });
  }

  QueryBuilder<Podcast, List<String>?, QQueryOperations>
  itunesGenreIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'itunesGenreIds');
    });
  }

  QueryBuilder<Podcast, List<String>?, QQueryOperations>
  itunesGenresProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'itunesGenres');
    });
  }

  QueryBuilder<Podcast, String?, QQueryOperations> itunesIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'itunesId');
    });
  }

  QueryBuilder<Podcast, String?, QQueryOperations>
  itunesPrimaryGenreNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'itunesPrimaryGenreName');
    });
  }

  QueryBuilder<Podcast, DateTime?, QQueryOperations>
  itunesReleaseDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'itunesReleaseDate');
    });
  }

  QueryBuilder<Podcast, List<String>?, QQueryOperations> keywordsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'keywords');
    });
  }

  QueryBuilder<Podcast, String?, QQueryOperations> languageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'language');
    });
  }

  QueryBuilder<Podcast, DateTime, QQueryOperations> lastUpdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdated');
    });
  }

  QueryBuilder<Podcast, String?, QQueryOperations> ownerEmailProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ownerEmail');
    });
  }

  QueryBuilder<Podcast, String?, QQueryOperations> ownerNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ownerName');
    });
  }

  QueryBuilder<Podcast, String, QQueryOperations> rssUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rssUrl');
    });
  }

  QueryBuilder<Podcast, DateTime?, QQueryOperations> subscribedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subscribedAt');
    });
  }

  QueryBuilder<Podcast, String?, QQueryOperations> subtitleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subtitle');
    });
  }

  QueryBuilder<Podcast, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<Podcast, String?, QQueryOperations> websiteUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'websiteUrl');
    });
  }
}
