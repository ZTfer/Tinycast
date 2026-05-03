// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'play_history_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPlayHistoryCollection on Isar {
  IsarCollection<PlayHistory> get playHistorys => this.collection();
}

const PlayHistorySchema = CollectionSchema(
  name: r'PlayHistory',
  id: 6118132194974220027,
  properties: {
    r'artworkUrl': PropertySchema(
      id: 0,
      name: r'artworkUrl',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'description': PropertySchema(
      id: 2,
      name: r'description',
      type: IsarType.string,
    ),
    r'episodeGuid': PropertySchema(
      id: 3,
      name: r'episodeGuid',
      type: IsarType.string,
    ),
    r'episodeITunesId': PropertySchema(
      id: 4,
      name: r'episodeITunesId',
      type: IsarType.string,
    ),
    r'episodeId': PropertySchema(
      id: 5,
      name: r'episodeId',
      type: IsarType.long,
    ),
    r'isDeleted': PropertySchema(
      id: 6,
      name: r'isDeleted',
      type: IsarType.bool,
    ),
    r'isPlayed': PropertySchema(id: 7, name: r'isPlayed', type: IsarType.bool),
    r'lastPlayedPositionMs': PropertySchema(
      id: 8,
      name: r'lastPlayedPositionMs',
      type: IsarType.long,
    ),
    r'lastUpdateTime': PropertySchema(
      id: 9,
      name: r'lastUpdateTime',
      type: IsarType.dateTime,
    ),
    r'playedDuration': PropertySchema(
      id: 10,
      name: r'playedDuration',
      type: IsarType.long,
    ),
    r'podcastGuid': PropertySchema(
      id: 11,
      name: r'podcastGuid',
      type: IsarType.string,
    ),
    r'podcastITunesId': PropertySchema(
      id: 12,
      name: r'podcastITunesId',
      type: IsarType.string,
    ),
    r'podcastId': PropertySchema(
      id: 13,
      name: r'podcastId',
      type: IsarType.long,
    ),
    r'status': PropertySchema(
      id: 14,
      name: r'status',
      type: IsarType.byte,
      enumMap: _PlayHistorystatusEnumValueMap,
    ),
    r'title': PropertySchema(id: 15, name: r'title', type: IsarType.string),
  },

  estimateSize: _playHistoryEstimateSize,
  serialize: _playHistorySerialize,
  deserialize: _playHistoryDeserialize,
  deserializeProp: _playHistoryDeserializeProp,
  idName: r'id',
  indexes: {
    r'episodeId': IndexSchema(
      id: -5445487708405506290,
      name: r'episodeId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'episodeId',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'podcastId': IndexSchema(
      id: -1067219606322714012,
      name: r'podcastId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'podcastId',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'lastUpdateTime': IndexSchema(
      id: 6922215392961312209,
      name: r'lastUpdateTime',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'lastUpdateTime',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _playHistoryGetId,
  getLinks: _playHistoryGetLinks,
  attach: _playHistoryAttach,
  version: '3.3.2',
);

int _playHistoryEstimateSize(
  PlayHistory object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.artworkUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.description;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.episodeGuid;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.episodeITunesId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.podcastGuid;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.podcastITunesId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _playHistorySerialize(
  PlayHistory object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.artworkUrl);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeString(offsets[2], object.description);
  writer.writeString(offsets[3], object.episodeGuid);
  writer.writeString(offsets[4], object.episodeITunesId);
  writer.writeLong(offsets[5], object.episodeId);
  writer.writeBool(offsets[6], object.isDeleted);
  writer.writeBool(offsets[7], object.isPlayed);
  writer.writeLong(offsets[8], object.lastPlayedPositionMs);
  writer.writeDateTime(offsets[9], object.lastUpdateTime);
  writer.writeLong(offsets[10], object.playedDuration);
  writer.writeString(offsets[11], object.podcastGuid);
  writer.writeString(offsets[12], object.podcastITunesId);
  writer.writeLong(offsets[13], object.podcastId);
  writer.writeByte(offsets[14], object.status.index);
  writer.writeString(offsets[15], object.title);
}

PlayHistory _playHistoryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PlayHistory();
  object.artworkUrl = reader.readStringOrNull(offsets[0]);
  object.description = reader.readStringOrNull(offsets[2]);
  object.episodeGuid = reader.readStringOrNull(offsets[3]);
  object.episodeITunesId = reader.readStringOrNull(offsets[4]);
  object.episodeId = reader.readLong(offsets[5]);
  object.id = id;
  object.isDeleted = reader.readBool(offsets[6]);
  object.isPlayed = reader.readBool(offsets[7]);
  object.lastPlayedPositionMs = reader.readLong(offsets[8]);
  object.lastUpdateTime = reader.readDateTime(offsets[9]);
  object.playedDuration = reader.readLong(offsets[10]);
  object.podcastGuid = reader.readStringOrNull(offsets[11]);
  object.podcastITunesId = reader.readStringOrNull(offsets[12]);
  object.podcastId = reader.readLong(offsets[13]);
  object.status =
      _PlayHistorystatusValueEnumMap[reader.readByteOrNull(offsets[14])] ??
      PlayHistoryStatus.playing;
  object.title = reader.readString(offsets[15]);
  return object;
}

P _playHistoryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readDateTime(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    case 13:
      return (reader.readLong(offset)) as P;
    case 14:
      return (_PlayHistorystatusValueEnumMap[reader.readByteOrNull(offset)] ??
              PlayHistoryStatus.playing)
          as P;
    case 15:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _PlayHistorystatusEnumValueMap = {
  'playing': 0,
  'completed': 1,
  'skipped': 2,
};
const _PlayHistorystatusValueEnumMap = {
  0: PlayHistoryStatus.playing,
  1: PlayHistoryStatus.completed,
  2: PlayHistoryStatus.skipped,
};

Id _playHistoryGetId(PlayHistory object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _playHistoryGetLinks(PlayHistory object) {
  return [];
}

void _playHistoryAttach(
  IsarCollection<dynamic> col,
  Id id,
  PlayHistory object,
) {
  object.id = id;
}

extension PlayHistoryQueryWhereSort
    on QueryBuilder<PlayHistory, PlayHistory, QWhere> {
  QueryBuilder<PlayHistory, PlayHistory, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterWhere> anyEpisodeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'episodeId'),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterWhere> anyPodcastId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'podcastId'),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterWhere> anyLastUpdateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'lastUpdateTime'),
      );
    });
  }
}

extension PlayHistoryQueryWhere
    on QueryBuilder<PlayHistory, PlayHistory, QWhereClause> {
  QueryBuilder<PlayHistory, PlayHistory, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
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

  QueryBuilder<PlayHistory, PlayHistory, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterWhereClause> idBetween(
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

  QueryBuilder<PlayHistory, PlayHistory, QAfterWhereClause> episodeIdEqualTo(
    int episodeId,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'episodeId', value: [episodeId]),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterWhereClause> episodeIdNotEqualTo(
    int episodeId,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'episodeId',
                lower: [],
                upper: [episodeId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'episodeId',
                lower: [episodeId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'episodeId',
                lower: [episodeId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'episodeId',
                lower: [],
                upper: [episodeId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterWhereClause>
  episodeIdGreaterThan(int episodeId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'episodeId',
          lower: [episodeId],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterWhereClause> episodeIdLessThan(
    int episodeId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'episodeId',
          lower: [],
          upper: [episodeId],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterWhereClause> episodeIdBetween(
    int lowerEpisodeId,
    int upperEpisodeId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'episodeId',
          lower: [lowerEpisodeId],
          includeLower: includeLower,
          upper: [upperEpisodeId],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterWhereClause> podcastIdEqualTo(
    int podcastId,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'podcastId', value: [podcastId]),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterWhereClause> podcastIdNotEqualTo(
    int podcastId,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'podcastId',
                lower: [],
                upper: [podcastId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'podcastId',
                lower: [podcastId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'podcastId',
                lower: [podcastId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'podcastId',
                lower: [],
                upper: [podcastId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterWhereClause>
  podcastIdGreaterThan(int podcastId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'podcastId',
          lower: [podcastId],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterWhereClause> podcastIdLessThan(
    int podcastId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'podcastId',
          lower: [],
          upper: [podcastId],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterWhereClause> podcastIdBetween(
    int lowerPodcastId,
    int upperPodcastId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'podcastId',
          lower: [lowerPodcastId],
          includeLower: includeLower,
          upper: [upperPodcastId],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterWhereClause>
  lastUpdateTimeEqualTo(DateTime lastUpdateTime) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'lastUpdateTime',
          value: [lastUpdateTime],
        ),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterWhereClause>
  lastUpdateTimeNotEqualTo(DateTime lastUpdateTime) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'lastUpdateTime',
                lower: [],
                upper: [lastUpdateTime],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'lastUpdateTime',
                lower: [lastUpdateTime],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'lastUpdateTime',
                lower: [lastUpdateTime],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'lastUpdateTime',
                lower: [],
                upper: [lastUpdateTime],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterWhereClause>
  lastUpdateTimeGreaterThan(DateTime lastUpdateTime, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'lastUpdateTime',
          lower: [lastUpdateTime],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterWhereClause>
  lastUpdateTimeLessThan(DateTime lastUpdateTime, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'lastUpdateTime',
          lower: [],
          upper: [lastUpdateTime],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterWhereClause>
  lastUpdateTimeBetween(
    DateTime lowerLastUpdateTime,
    DateTime upperLastUpdateTime, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'lastUpdateTime',
          lower: [lowerLastUpdateTime],
          includeLower: includeLower,
          upper: [upperLastUpdateTime],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension PlayHistoryQueryFilter
    on QueryBuilder<PlayHistory, PlayHistory, QFilterCondition> {
  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  artworkUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'artworkUrl'),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  artworkUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'artworkUrl'),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  artworkUrlEqualTo(String? value, {bool caseSensitive = true}) {
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

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  artworkUrlGreaterThan(
    String? value, {
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

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  artworkUrlLessThan(
    String? value, {
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

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  artworkUrlBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  artworkUrlStartsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  artworkUrlEndsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  artworkUrlContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  artworkUrlMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  artworkUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'artworkUrl', value: ''),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  artworkUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'artworkUrl', value: ''),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  createdAtGreaterThan(DateTime value, {bool include = false}) {
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

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  createdAtLessThan(DateTime value, {bool include = false}) {
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

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  createdAtBetween(
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

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  descriptionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'description'),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  descriptionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'description'),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  descriptionEqualTo(String? value, {bool caseSensitive = true}) {
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

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  descriptionGreaterThan(
    String? value, {
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

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  descriptionLessThan(
    String? value, {
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

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  descriptionBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  descriptionStartsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  descriptionEndsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  descriptionContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  descriptionMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'description', value: ''),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'description', value: ''),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  episodeGuidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'episodeGuid'),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  episodeGuidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'episodeGuid'),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  episodeGuidEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'episodeGuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  episodeGuidGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'episodeGuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  episodeGuidLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'episodeGuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  episodeGuidBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'episodeGuid',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  episodeGuidStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'episodeGuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  episodeGuidEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'episodeGuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  episodeGuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'episodeGuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  episodeGuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'episodeGuid',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  episodeGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'episodeGuid', value: ''),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  episodeGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'episodeGuid', value: ''),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  episodeITunesIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'episodeITunesId'),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  episodeITunesIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'episodeITunesId'),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  episodeITunesIdEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'episodeITunesId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  episodeITunesIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'episodeITunesId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  episodeITunesIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'episodeITunesId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  episodeITunesIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'episodeITunesId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  episodeITunesIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'episodeITunesId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  episodeITunesIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'episodeITunesId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  episodeITunesIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'episodeITunesId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  episodeITunesIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'episodeITunesId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  episodeITunesIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'episodeITunesId', value: ''),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  episodeITunesIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'episodeITunesId', value: ''),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  episodeIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'episodeId', value: value),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  episodeIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'episodeId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  episodeIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'episodeId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  episodeIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'episodeId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition> idBetween(
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

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  isDeletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isDeleted', value: value),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition> isPlayedEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isPlayed', value: value),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  lastPlayedPositionMsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'lastPlayedPositionMs',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  lastPlayedPositionMsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastPlayedPositionMs',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  lastPlayedPositionMsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastPlayedPositionMs',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  lastPlayedPositionMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastPlayedPositionMs',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  lastUpdateTimeEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastUpdateTime', value: value),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  lastUpdateTimeGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastUpdateTime',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  lastUpdateTimeLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastUpdateTime',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  lastUpdateTimeBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastUpdateTime',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  playedDurationEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'playedDuration', value: value),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  playedDurationGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'playedDuration',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  playedDurationLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'playedDuration',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  playedDurationBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'playedDuration',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  podcastGuidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'podcastGuid'),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  podcastGuidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'podcastGuid'),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  podcastGuidEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'podcastGuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  podcastGuidGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'podcastGuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  podcastGuidLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'podcastGuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  podcastGuidBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'podcastGuid',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  podcastGuidStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'podcastGuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  podcastGuidEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'podcastGuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  podcastGuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'podcastGuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  podcastGuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'podcastGuid',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  podcastGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'podcastGuid', value: ''),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  podcastGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'podcastGuid', value: ''),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  podcastITunesIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'podcastITunesId'),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  podcastITunesIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'podcastITunesId'),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  podcastITunesIdEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'podcastITunesId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  podcastITunesIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'podcastITunesId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  podcastITunesIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'podcastITunesId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  podcastITunesIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'podcastITunesId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  podcastITunesIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'podcastITunesId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  podcastITunesIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'podcastITunesId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  podcastITunesIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'podcastITunesId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  podcastITunesIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'podcastITunesId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  podcastITunesIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'podcastITunesId', value: ''),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  podcastITunesIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'podcastITunesId', value: ''),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  podcastIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'podcastId', value: value),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  podcastIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'podcastId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  podcastIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'podcastId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  podcastIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'podcastId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition> statusEqualTo(
    PlayHistoryStatus value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'status', value: value),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  statusGreaterThan(PlayHistoryStatus value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'status',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition> statusLessThan(
    PlayHistoryStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'status',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition> statusBetween(
    PlayHistoryStatus lower,
    PlayHistoryStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'status',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition> titleEqualTo(
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

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  titleGreaterThan(
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

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition> titleLessThan(
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

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition> titleBetween(
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

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition> titleStartsWith(
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

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition> titleEndsWith(
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

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition> titleContains(
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

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition> titleMatches(
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

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterFilterCondition>
  titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'title', value: ''),
      );
    });
  }
}

extension PlayHistoryQueryObject
    on QueryBuilder<PlayHistory, PlayHistory, QFilterCondition> {}

extension PlayHistoryQueryLinks
    on QueryBuilder<PlayHistory, PlayHistory, QFilterCondition> {}

extension PlayHistoryQuerySortBy
    on QueryBuilder<PlayHistory, PlayHistory, QSortBy> {
  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy> sortByArtworkUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artworkUrl', Sort.asc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy> sortByArtworkUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artworkUrl', Sort.desc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy> sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy> sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy> sortByEpisodeGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeGuid', Sort.asc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy> sortByEpisodeGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeGuid', Sort.desc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy> sortByEpisodeITunesId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeITunesId', Sort.asc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy>
  sortByEpisodeITunesIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeITunesId', Sort.desc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy> sortByEpisodeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeId', Sort.asc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy> sortByEpisodeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeId', Sort.desc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy> sortByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy> sortByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy> sortByIsPlayed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPlayed', Sort.asc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy> sortByIsPlayedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPlayed', Sort.desc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy>
  sortByLastPlayedPositionMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayedPositionMs', Sort.asc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy>
  sortByLastPlayedPositionMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayedPositionMs', Sort.desc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy> sortByLastUpdateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdateTime', Sort.asc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy>
  sortByLastUpdateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdateTime', Sort.desc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy> sortByPlayedDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playedDuration', Sort.asc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy>
  sortByPlayedDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playedDuration', Sort.desc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy> sortByPodcastGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'podcastGuid', Sort.asc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy> sortByPodcastGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'podcastGuid', Sort.desc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy> sortByPodcastITunesId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'podcastITunesId', Sort.asc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy>
  sortByPodcastITunesIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'podcastITunesId', Sort.desc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy> sortByPodcastId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'podcastId', Sort.asc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy> sortByPodcastIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'podcastId', Sort.desc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension PlayHistoryQuerySortThenBy
    on QueryBuilder<PlayHistory, PlayHistory, QSortThenBy> {
  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy> thenByArtworkUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artworkUrl', Sort.asc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy> thenByArtworkUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artworkUrl', Sort.desc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy> thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy> thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy> thenByEpisodeGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeGuid', Sort.asc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy> thenByEpisodeGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeGuid', Sort.desc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy> thenByEpisodeITunesId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeITunesId', Sort.asc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy>
  thenByEpisodeITunesIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeITunesId', Sort.desc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy> thenByEpisodeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeId', Sort.asc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy> thenByEpisodeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeId', Sort.desc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy> thenByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy> thenByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy> thenByIsPlayed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPlayed', Sort.asc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy> thenByIsPlayedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPlayed', Sort.desc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy>
  thenByLastPlayedPositionMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayedPositionMs', Sort.asc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy>
  thenByLastPlayedPositionMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayedPositionMs', Sort.desc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy> thenByLastUpdateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdateTime', Sort.asc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy>
  thenByLastUpdateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdateTime', Sort.desc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy> thenByPlayedDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playedDuration', Sort.asc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy>
  thenByPlayedDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playedDuration', Sort.desc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy> thenByPodcastGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'podcastGuid', Sort.asc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy> thenByPodcastGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'podcastGuid', Sort.desc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy> thenByPodcastITunesId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'podcastITunesId', Sort.asc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy>
  thenByPodcastITunesIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'podcastITunesId', Sort.desc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy> thenByPodcastId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'podcastId', Sort.asc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy> thenByPodcastIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'podcastId', Sort.desc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension PlayHistoryQueryWhereDistinct
    on QueryBuilder<PlayHistory, PlayHistory, QDistinct> {
  QueryBuilder<PlayHistory, PlayHistory, QDistinct> distinctByArtworkUrl({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'artworkUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QDistinct> distinctByDescription({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QDistinct> distinctByEpisodeGuid({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'episodeGuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QDistinct> distinctByEpisodeITunesId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'episodeITunesId',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QDistinct> distinctByEpisodeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'episodeId');
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QDistinct> distinctByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDeleted');
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QDistinct> distinctByIsPlayed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isPlayed');
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QDistinct>
  distinctByLastPlayedPositionMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastPlayedPositionMs');
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QDistinct> distinctByLastUpdateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdateTime');
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QDistinct> distinctByPlayedDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'playedDuration');
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QDistinct> distinctByPodcastGuid({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'podcastGuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QDistinct> distinctByPodcastITunesId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'podcastITunesId',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QDistinct> distinctByPodcastId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'podcastId');
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QDistinct> distinctByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status');
    });
  }

  QueryBuilder<PlayHistory, PlayHistory, QDistinct> distinctByTitle({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }
}

extension PlayHistoryQueryProperty
    on QueryBuilder<PlayHistory, PlayHistory, QQueryProperty> {
  QueryBuilder<PlayHistory, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PlayHistory, String?, QQueryOperations> artworkUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'artworkUrl');
    });
  }

  QueryBuilder<PlayHistory, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<PlayHistory, String?, QQueryOperations> descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<PlayHistory, String?, QQueryOperations> episodeGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'episodeGuid');
    });
  }

  QueryBuilder<PlayHistory, String?, QQueryOperations>
  episodeITunesIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'episodeITunesId');
    });
  }

  QueryBuilder<PlayHistory, int, QQueryOperations> episodeIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'episodeId');
    });
  }

  QueryBuilder<PlayHistory, bool, QQueryOperations> isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDeleted');
    });
  }

  QueryBuilder<PlayHistory, bool, QQueryOperations> isPlayedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isPlayed');
    });
  }

  QueryBuilder<PlayHistory, int, QQueryOperations>
  lastPlayedPositionMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastPlayedPositionMs');
    });
  }

  QueryBuilder<PlayHistory, DateTime, QQueryOperations>
  lastUpdateTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdateTime');
    });
  }

  QueryBuilder<PlayHistory, int, QQueryOperations> playedDurationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'playedDuration');
    });
  }

  QueryBuilder<PlayHistory, String?, QQueryOperations> podcastGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'podcastGuid');
    });
  }

  QueryBuilder<PlayHistory, String?, QQueryOperations>
  podcastITunesIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'podcastITunesId');
    });
  }

  QueryBuilder<PlayHistory, int, QQueryOperations> podcastIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'podcastId');
    });
  }

  QueryBuilder<PlayHistory, PlayHistoryStatus, QQueryOperations>
  statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<PlayHistory, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }
}
