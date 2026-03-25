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
    r'artworkUrl': PropertySchema(
      id: 0,
      name: r'artworkUrl',
      type: IsarType.string,
    ),
    r'author': PropertySchema(id: 1, name: r'author', type: IsarType.string),
    r'categories': PropertySchema(
      id: 2,
      name: r'categories',
      type: IsarType.stringList,
    ),
    r'copyright': PropertySchema(
      id: 3,
      name: r'copyright',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 4,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'description': PropertySchema(
      id: 5,
      name: r'description',
      type: IsarType.string,
    ),
    r'episodeCount': PropertySchema(
      id: 6,
      name: r'episodeCount',
      type: IsarType.long,
    ),
    r'isExplicit': PropertySchema(
      id: 7,
      name: r'isExplicit',
      type: IsarType.bool,
    ),
    r'isSubscribed': PropertySchema(
      id: 8,
      name: r'isSubscribed',
      type: IsarType.bool,
    ),
    r'keywords': PropertySchema(
      id: 9,
      name: r'keywords',
      type: IsarType.stringList,
    ),
    r'language': PropertySchema(
      id: 10,
      name: r'language',
      type: IsarType.string,
    ),
    r'lastUpdated': PropertySchema(
      id: 11,
      name: r'lastUpdated',
      type: IsarType.dateTime,
    ),
    r'ownerEmail': PropertySchema(
      id: 12,
      name: r'ownerEmail',
      type: IsarType.string,
    ),
    r'ownerName': PropertySchema(
      id: 13,
      name: r'ownerName',
      type: IsarType.string,
    ),
    r'rssUrl': PropertySchema(id: 14, name: r'rssUrl', type: IsarType.string),
    r'subscribedAt': PropertySchema(
      id: 15,
      name: r'subscribedAt',
      type: IsarType.dateTime,
    ),
    r'subtitle': PropertySchema(
      id: 16,
      name: r'subtitle',
      type: IsarType.string,
    ),
    r'title': PropertySchema(id: 17, name: r'title', type: IsarType.string),
    r'websiteUrl': PropertySchema(
      id: 18,
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
  writer.writeString(offsets[0], object.artworkUrl);
  writer.writeString(offsets[1], object.author);
  writer.writeStringList(offsets[2], object.categories);
  writer.writeString(offsets[3], object.copyright);
  writer.writeDateTime(offsets[4], object.createdAt);
  writer.writeString(offsets[5], object.description);
  writer.writeLong(offsets[6], object.episodeCount);
  writer.writeBool(offsets[7], object.isExplicit);
  writer.writeBool(offsets[8], object.isSubscribed);
  writer.writeStringList(offsets[9], object.keywords);
  writer.writeString(offsets[10], object.language);
  writer.writeDateTime(offsets[11], object.lastUpdated);
  writer.writeString(offsets[12], object.ownerEmail);
  writer.writeString(offsets[13], object.ownerName);
  writer.writeString(offsets[14], object.rssUrl);
  writer.writeDateTime(offsets[15], object.subscribedAt);
  writer.writeString(offsets[16], object.subtitle);
  writer.writeString(offsets[17], object.title);
  writer.writeString(offsets[18], object.websiteUrl);
}

Podcast _podcastDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Podcast();
  object.artworkUrl = reader.readString(offsets[0]);
  object.author = reader.readString(offsets[1]);
  object.categories = reader.readStringList(offsets[2]);
  object.copyright = reader.readStringOrNull(offsets[3]);
  object.description = reader.readString(offsets[5]);
  object.episodeCount = reader.readLong(offsets[6]);
  object.id = id;
  object.isExplicit = reader.readBool(offsets[7]);
  object.isSubscribed = reader.readBool(offsets[8]);
  object.keywords = reader.readStringList(offsets[9]);
  object.language = reader.readStringOrNull(offsets[10]);
  object.lastUpdated = reader.readDateTime(offsets[11]);
  object.ownerEmail = reader.readStringOrNull(offsets[12]);
  object.ownerName = reader.readStringOrNull(offsets[13]);
  object.rssUrl = reader.readString(offsets[14]);
  object.subscribedAt = reader.readDateTimeOrNull(offsets[15]);
  object.subtitle = reader.readStringOrNull(offsets[16]);
  object.title = reader.readString(offsets[17]);
  object.websiteUrl = reader.readStringOrNull(offsets[18]);
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
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readStringList(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readStringList(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readDateTime(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 16:
      return (reader.readStringOrNull(offset)) as P;
    case 17:
      return (reader.readString(offset)) as P;
    case 18:
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
