// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

extension GetAppSettingsModelCollection on Isar {
  IsarCollection<AppSettingsModel> get appSettingsModels => this.collection();
}

const AppSettingsModelSchema = CollectionSchema(
  name: r'AppSettingsModel',
  id: -638838212012723081,
  properties: {
    r'autoDownloadPolicy': PropertySchema(
      id: 0,
      name: r'autoDownloadPolicy',
      type: IsarType.byte,
      enumMap: _AppSettingsModelautoDownloadPolicyEnumValueMap,
    ),
    r'backgroundRefreshEnabled': PropertySchema(
      id: 1,
      name: r'backgroundRefreshEnabled',
      type: IsarType.bool,
    ),
    r'continuousPlay': PropertySchema(
      id: 2,
      name: r'continuousPlay',
      type: IsarType.bool,
    ),
    r'downloadOnFavorite': PropertySchema(
      id: 3,
      name: r'downloadOnFavorite',
      type: IsarType.bool,
    ),
    r'feedRefreshInterval': PropertySchema(
      id: 4,
      name: r'feedRefreshInterval',
      type: IsarType.byte,
      enumMap: _AppSettingsModelfeedRefreshIntervalEnumValueMap,
    ),
    r'notifyOnNewEpisodes': PropertySchema(
      id: 5,
      name: r'notifyOnNewEpisodes',
      type: IsarType.bool,
    ),
    r'playbackSpeed': PropertySchema(
      id: 6,
      name: r'playbackSpeed',
      type: IsarType.double,
    ),
    r'refreshOnCellular': PropertySchema(
      id: 7,
      name: r'refreshOnCellular',
      type: IsarType.bool,
    ),
    r'removePlayedDownloads': PropertySchema(
      id: 8,
      name: r'removePlayedDownloads',
      type: IsarType.bool,
    ),
    r'skipBackwardTime': PropertySchema(
      id: 9,
      name: r'skipBackwardTime',
      type: IsarType.long,
    ),
    r'skipForwardTime': PropertySchema(
      id: 10,
      name: r'skipForwardTime',
      type: IsarType.long,
    ),
    r'sleepTimer': PropertySchema(
      id: 11,
      name: r'sleepTimer',
      type: IsarType.byte,
      enumMap: _AppSettingsModelsleepTimerEnumValueMap,
    ),
    r'sleepTimerEndTimeMillis': PropertySchema(
      id: 12,
      name: r'sleepTimerEndTimeMillis',
      type: IsarType.long,
    ),
    r'volume': PropertySchema(id: 13, name: r'volume', type: IsarType.double),
  },

  estimateSize: _appSettingsModelEstimateSize,
  serialize: _appSettingsModelSerialize,
  deserialize: _appSettingsModelDeserialize,
  deserializeProp: _appSettingsModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _appSettingsModelGetId,
  getLinks: _appSettingsModelGetLinks,
  attach: _appSettingsModelAttach,
  version: '3.4.1',
);

int _appSettingsModelEstimateSize(
  AppSettingsModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _appSettingsModelSerialize(
  AppSettingsModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeByte(offsets[0], object.autoDownloadPolicy.index);
  writer.writeBool(offsets[1], object.backgroundRefreshEnabled);
  writer.writeBool(offsets[2], object.continuousPlay);
  writer.writeBool(offsets[3], object.downloadOnFavorite);
  writer.writeByte(offsets[4], object.feedRefreshInterval.index);
  writer.writeBool(offsets[5], object.notifyOnNewEpisodes);
  writer.writeDouble(offsets[6], object.playbackSpeed);
  writer.writeBool(offsets[7], object.refreshOnCellular);
  writer.writeBool(offsets[8], object.removePlayedDownloads);
  writer.writeLong(offsets[9], object.skipBackwardTime);
  writer.writeLong(offsets[10], object.skipForwardTime);
  writer.writeByte(offsets[11], object.sleepTimer.index);
  writer.writeLong(offsets[12], object.sleepTimerEndTimeMillis);
  writer.writeDouble(offsets[13], object.volume);
}

AppSettingsModel _appSettingsModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AppSettingsModel();
  object.autoDownloadPolicy =
      _AppSettingsModelautoDownloadPolicyValueEnumMap[reader.readByteOrNull(
        offsets[0],
      )] ??
      AutoDownloadPolicyEnum.off;
  object.backgroundRefreshEnabled = reader.readBool(offsets[1]);
  object.continuousPlay = reader.readBool(offsets[2]);
  object.downloadOnFavorite = reader.readBool(offsets[3]);
  object.feedRefreshInterval =
      _AppSettingsModelfeedRefreshIntervalValueEnumMap[reader.readByteOrNull(
        offsets[4],
      )] ??
      FeedRefreshIntervalEnum.manual;
  object.id = id;
  object.notifyOnNewEpisodes = reader.readBool(offsets[5]);
  object.playbackSpeed = reader.readDouble(offsets[6]);
  object.refreshOnCellular = reader.readBool(offsets[7]);
  object.removePlayedDownloads = reader.readBool(offsets[8]);
  object.skipBackwardTime = reader.readLong(offsets[9]);
  object.skipForwardTime = reader.readLong(offsets[10]);
  object.sleepTimer =
      _AppSettingsModelsleepTimerValueEnumMap[reader.readByteOrNull(
        offsets[11],
      )] ??
      SleepTimerEnum.off;
  object.sleepTimerEndTimeMillis = reader.readLongOrNull(offsets[12]);
  object.volume = reader.readDouble(offsets[13]);
  return object;
}

P _appSettingsModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (_AppSettingsModelautoDownloadPolicyValueEnumMap[reader
                  .readByteOrNull(offset)] ??
              AutoDownloadPolicyEnum.off)
          as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (_AppSettingsModelfeedRefreshIntervalValueEnumMap[reader
                  .readByteOrNull(offset)] ??
              FeedRefreshIntervalEnum.manual)
          as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readDouble(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    case 11:
      return (_AppSettingsModelsleepTimerValueEnumMap[reader.readByteOrNull(
                offset,
              )] ??
              SleepTimerEnum.off)
          as P;
    case 12:
      return (reader.readLongOrNull(offset)) as P;
    case 13:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _AppSettingsModelautoDownloadPolicyEnumValueMap = {
  'off': 0,
  'latest1': 1,
  'latest2': 2,
  'latest3': 3,
  'latest5': 4,
  'latest10': 5,
  'past24h': 6,
  'past7d': 7,
  'past14d': 8,
  'past30d': 9,
  'all': 10,
};
const _AppSettingsModelautoDownloadPolicyValueEnumMap = {
  0: AutoDownloadPolicyEnum.off,
  1: AutoDownloadPolicyEnum.latest1,
  2: AutoDownloadPolicyEnum.latest2,
  3: AutoDownloadPolicyEnum.latest3,
  4: AutoDownloadPolicyEnum.latest5,
  5: AutoDownloadPolicyEnum.latest10,
  6: AutoDownloadPolicyEnum.past24h,
  7: AutoDownloadPolicyEnum.past7d,
  8: AutoDownloadPolicyEnum.past14d,
  9: AutoDownloadPolicyEnum.past30d,
  10: AutoDownloadPolicyEnum.all,
};
const _AppSettingsModelfeedRefreshIntervalEnumValueMap = {
  'manual': 0,
  'hourly': 1,
  'every3h': 2,
  'every6h': 3,
  'every12h': 4,
  'daily': 5,
};
const _AppSettingsModelfeedRefreshIntervalValueEnumMap = {
  0: FeedRefreshIntervalEnum.manual,
  1: FeedRefreshIntervalEnum.hourly,
  2: FeedRefreshIntervalEnum.every3h,
  3: FeedRefreshIntervalEnum.every6h,
  4: FeedRefreshIntervalEnum.every12h,
  5: FeedRefreshIntervalEnum.daily,
};
const _AppSettingsModelsleepTimerEnumValueMap = {
  'off': 0,
  'min5': 1,
  'min10': 2,
  'min15': 3,
  'min30': 4,
  'min45': 5,
  'min60': 6,
  'episodeEnd': 7,
};
const _AppSettingsModelsleepTimerValueEnumMap = {
  0: SleepTimerEnum.off,
  1: SleepTimerEnum.min5,
  2: SleepTimerEnum.min10,
  3: SleepTimerEnum.min15,
  4: SleepTimerEnum.min30,
  5: SleepTimerEnum.min45,
  6: SleepTimerEnum.min60,
  7: SleepTimerEnum.episodeEnd,
};

Id _appSettingsModelGetId(AppSettingsModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _appSettingsModelGetLinks(AppSettingsModel object) {
  return [];
}

void _appSettingsModelAttach(
  IsarCollection<dynamic> col,
  Id id,
  AppSettingsModel object,
) {
  object.id = id;
}

extension AppSettingsModelQueryWhereSort
    on QueryBuilder<AppSettingsModel, AppSettingsModel, QWhere> {
  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AppSettingsModelQueryWhere
    on QueryBuilder<AppSettingsModel, AppSettingsModel, QWhereClause> {
  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterWhereClause>
  idNotEqualTo(Id id) {
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

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterWhereClause> idBetween(
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
}

extension AppSettingsModelQueryFilter
    on QueryBuilder<AppSettingsModel, AppSettingsModel, QFilterCondition> {
  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterFilterCondition>
  autoDownloadPolicyEqualTo(AutoDownloadPolicyEnum value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'autoDownloadPolicy', value: value),
      );
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterFilterCondition>
  autoDownloadPolicyGreaterThan(
    AutoDownloadPolicyEnum value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'autoDownloadPolicy',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterFilterCondition>
  autoDownloadPolicyLessThan(
    AutoDownloadPolicyEnum value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'autoDownloadPolicy',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterFilterCondition>
  autoDownloadPolicyBetween(
    AutoDownloadPolicyEnum lower,
    AutoDownloadPolicyEnum upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'autoDownloadPolicy',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterFilterCondition>
  backgroundRefreshEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'backgroundRefreshEnabled',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterFilterCondition>
  continuousPlayEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'continuousPlay', value: value),
      );
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterFilterCondition>
  downloadOnFavoriteEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'downloadOnFavorite', value: value),
      );
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterFilterCondition>
  feedRefreshIntervalEqualTo(FeedRefreshIntervalEnum value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'feedRefreshInterval', value: value),
      );
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterFilterCondition>
  feedRefreshIntervalGreaterThan(
    FeedRefreshIntervalEnum value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'feedRefreshInterval',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterFilterCondition>
  feedRefreshIntervalLessThan(
    FeedRefreshIntervalEnum value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'feedRefreshInterval',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterFilterCondition>
  feedRefreshIntervalBetween(
    FeedRefreshIntervalEnum lower,
    FeedRefreshIntervalEnum upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'feedRefreshInterval',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
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

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterFilterCondition>
  idLessThan(Id value, {bool include = false}) {
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

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterFilterCondition>
  idBetween(
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

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterFilterCondition>
  notifyOnNewEpisodesEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'notifyOnNewEpisodes', value: value),
      );
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterFilterCondition>
  playbackSpeedEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'playbackSpeed',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterFilterCondition>
  playbackSpeedGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'playbackSpeed',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterFilterCondition>
  playbackSpeedLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'playbackSpeed',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterFilterCondition>
  playbackSpeedBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'playbackSpeed',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterFilterCondition>
  refreshOnCellularEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'refreshOnCellular', value: value),
      );
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterFilterCondition>
  removePlayedDownloadsEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'removePlayedDownloads',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterFilterCondition>
  skipBackwardTimeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'skipBackwardTime', value: value),
      );
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterFilterCondition>
  skipBackwardTimeGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'skipBackwardTime',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterFilterCondition>
  skipBackwardTimeLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'skipBackwardTime',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterFilterCondition>
  skipBackwardTimeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'skipBackwardTime',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterFilterCondition>
  skipForwardTimeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'skipForwardTime', value: value),
      );
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterFilterCondition>
  skipForwardTimeGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'skipForwardTime',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterFilterCondition>
  skipForwardTimeLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'skipForwardTime',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterFilterCondition>
  skipForwardTimeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'skipForwardTime',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterFilterCondition>
  sleepTimerEqualTo(SleepTimerEnum value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sleepTimer', value: value),
      );
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterFilterCondition>
  sleepTimerGreaterThan(SleepTimerEnum value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sleepTimer',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterFilterCondition>
  sleepTimerLessThan(SleepTimerEnum value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sleepTimer',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterFilterCondition>
  sleepTimerBetween(
    SleepTimerEnum lower,
    SleepTimerEnum upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sleepTimer',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterFilterCondition>
  sleepTimerEndTimeMillisIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'sleepTimerEndTimeMillis'),
      );
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterFilterCondition>
  sleepTimerEndTimeMillisIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'sleepTimerEndTimeMillis'),
      );
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterFilterCondition>
  sleepTimerEndTimeMillisEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'sleepTimerEndTimeMillis',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterFilterCondition>
  sleepTimerEndTimeMillisGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sleepTimerEndTimeMillis',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterFilterCondition>
  sleepTimerEndTimeMillisLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sleepTimerEndTimeMillis',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterFilterCondition>
  sleepTimerEndTimeMillisBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sleepTimerEndTimeMillis',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterFilterCondition>
  volumeEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'volume',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterFilterCondition>
  volumeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'volume',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterFilterCondition>
  volumeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'volume',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterFilterCondition>
  volumeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'volume',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }
}

extension AppSettingsModelQueryObject
    on QueryBuilder<AppSettingsModel, AppSettingsModel, QFilterCondition> {}

extension AppSettingsModelQueryLinks
    on QueryBuilder<AppSettingsModel, AppSettingsModel, QFilterCondition> {}

extension AppSettingsModelQuerySortBy
    on QueryBuilder<AppSettingsModel, AppSettingsModel, QSortBy> {
  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterSortBy>
  sortByAutoDownloadPolicy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoDownloadPolicy', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterSortBy>
  sortByAutoDownloadPolicyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoDownloadPolicy', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterSortBy>
  sortByBackgroundRefreshEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backgroundRefreshEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterSortBy>
  sortByBackgroundRefreshEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backgroundRefreshEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterSortBy>
  sortByContinuousPlay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'continuousPlay', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterSortBy>
  sortByContinuousPlayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'continuousPlay', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterSortBy>
  sortByDownloadOnFavorite() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadOnFavorite', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterSortBy>
  sortByDownloadOnFavoriteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadOnFavorite', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterSortBy>
  sortByFeedRefreshInterval() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feedRefreshInterval', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterSortBy>
  sortByFeedRefreshIntervalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feedRefreshInterval', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterSortBy>
  sortByNotifyOnNewEpisodes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notifyOnNewEpisodes', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterSortBy>
  sortByNotifyOnNewEpisodesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notifyOnNewEpisodes', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterSortBy>
  sortByPlaybackSpeed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playbackSpeed', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterSortBy>
  sortByPlaybackSpeedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playbackSpeed', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterSortBy>
  sortByRefreshOnCellular() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'refreshOnCellular', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterSortBy>
  sortByRefreshOnCellularDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'refreshOnCellular', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterSortBy>
  sortByRemovePlayedDownloads() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'removePlayedDownloads', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterSortBy>
  sortByRemovePlayedDownloadsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'removePlayedDownloads', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterSortBy>
  sortBySkipBackwardTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skipBackwardTime', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterSortBy>
  sortBySkipBackwardTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skipBackwardTime', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterSortBy>
  sortBySkipForwardTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skipForwardTime', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterSortBy>
  sortBySkipForwardTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skipForwardTime', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterSortBy>
  sortBySleepTimer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepTimer', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterSortBy>
  sortBySleepTimerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepTimer', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterSortBy>
  sortBySleepTimerEndTimeMillis() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepTimerEndTimeMillis', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterSortBy>
  sortBySleepTimerEndTimeMillisDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepTimerEndTimeMillis', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterSortBy>
  sortByVolume() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'volume', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterSortBy>
  sortByVolumeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'volume', Sort.desc);
    });
  }
}

extension AppSettingsModelQuerySortThenBy
    on QueryBuilder<AppSettingsModel, AppSettingsModel, QSortThenBy> {
  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterSortBy>
  thenByAutoDownloadPolicy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoDownloadPolicy', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterSortBy>
  thenByAutoDownloadPolicyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoDownloadPolicy', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterSortBy>
  thenByBackgroundRefreshEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backgroundRefreshEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterSortBy>
  thenByBackgroundRefreshEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backgroundRefreshEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterSortBy>
  thenByContinuousPlay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'continuousPlay', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterSortBy>
  thenByContinuousPlayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'continuousPlay', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterSortBy>
  thenByDownloadOnFavorite() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadOnFavorite', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterSortBy>
  thenByDownloadOnFavoriteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadOnFavorite', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterSortBy>
  thenByFeedRefreshInterval() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feedRefreshInterval', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterSortBy>
  thenByFeedRefreshIntervalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feedRefreshInterval', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterSortBy>
  thenByNotifyOnNewEpisodes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notifyOnNewEpisodes', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterSortBy>
  thenByNotifyOnNewEpisodesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notifyOnNewEpisodes', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterSortBy>
  thenByPlaybackSpeed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playbackSpeed', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterSortBy>
  thenByPlaybackSpeedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playbackSpeed', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterSortBy>
  thenByRefreshOnCellular() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'refreshOnCellular', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterSortBy>
  thenByRefreshOnCellularDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'refreshOnCellular', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterSortBy>
  thenByRemovePlayedDownloads() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'removePlayedDownloads', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterSortBy>
  thenByRemovePlayedDownloadsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'removePlayedDownloads', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterSortBy>
  thenBySkipBackwardTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skipBackwardTime', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterSortBy>
  thenBySkipBackwardTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skipBackwardTime', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterSortBy>
  thenBySkipForwardTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skipForwardTime', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterSortBy>
  thenBySkipForwardTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skipForwardTime', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterSortBy>
  thenBySleepTimer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepTimer', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterSortBy>
  thenBySleepTimerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepTimer', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterSortBy>
  thenBySleepTimerEndTimeMillis() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepTimerEndTimeMillis', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterSortBy>
  thenBySleepTimerEndTimeMillisDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepTimerEndTimeMillis', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterSortBy>
  thenByVolume() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'volume', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QAfterSortBy>
  thenByVolumeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'volume', Sort.desc);
    });
  }
}

extension AppSettingsModelQueryWhereDistinct
    on QueryBuilder<AppSettingsModel, AppSettingsModel, QDistinct> {
  QueryBuilder<AppSettingsModel, AppSettingsModel, QDistinct>
  distinctByAutoDownloadPolicy() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'autoDownloadPolicy');
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QDistinct>
  distinctByBackgroundRefreshEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'backgroundRefreshEnabled');
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QDistinct>
  distinctByContinuousPlay() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'continuousPlay');
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QDistinct>
  distinctByDownloadOnFavorite() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'downloadOnFavorite');
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QDistinct>
  distinctByFeedRefreshInterval() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'feedRefreshInterval');
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QDistinct>
  distinctByNotifyOnNewEpisodes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notifyOnNewEpisodes');
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QDistinct>
  distinctByPlaybackSpeed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'playbackSpeed');
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QDistinct>
  distinctByRefreshOnCellular() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'refreshOnCellular');
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QDistinct>
  distinctByRemovePlayedDownloads() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'removePlayedDownloads');
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QDistinct>
  distinctBySkipBackwardTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'skipBackwardTime');
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QDistinct>
  distinctBySkipForwardTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'skipForwardTime');
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QDistinct>
  distinctBySleepTimer() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sleepTimer');
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QDistinct>
  distinctBySleepTimerEndTimeMillis() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sleepTimerEndTimeMillis');
    });
  }

  QueryBuilder<AppSettingsModel, AppSettingsModel, QDistinct>
  distinctByVolume() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'volume');
    });
  }
}

extension AppSettingsModelQueryProperty
    on QueryBuilder<AppSettingsModel, AppSettingsModel, QQueryProperty> {
  QueryBuilder<AppSettingsModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AppSettingsModel, AutoDownloadPolicyEnum, QQueryOperations>
  autoDownloadPolicyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'autoDownloadPolicy');
    });
  }

  QueryBuilder<AppSettingsModel, bool, QQueryOperations>
  backgroundRefreshEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'backgroundRefreshEnabled');
    });
  }

  QueryBuilder<AppSettingsModel, bool, QQueryOperations>
  continuousPlayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'continuousPlay');
    });
  }

  QueryBuilder<AppSettingsModel, bool, QQueryOperations>
  downloadOnFavoriteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'downloadOnFavorite');
    });
  }

  QueryBuilder<AppSettingsModel, FeedRefreshIntervalEnum, QQueryOperations>
  feedRefreshIntervalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'feedRefreshInterval');
    });
  }

  QueryBuilder<AppSettingsModel, bool, QQueryOperations>
  notifyOnNewEpisodesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notifyOnNewEpisodes');
    });
  }

  QueryBuilder<AppSettingsModel, double, QQueryOperations>
  playbackSpeedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'playbackSpeed');
    });
  }

  QueryBuilder<AppSettingsModel, bool, QQueryOperations>
  refreshOnCellularProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'refreshOnCellular');
    });
  }

  QueryBuilder<AppSettingsModel, bool, QQueryOperations>
  removePlayedDownloadsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'removePlayedDownloads');
    });
  }

  QueryBuilder<AppSettingsModel, int, QQueryOperations>
  skipBackwardTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'skipBackwardTime');
    });
  }

  QueryBuilder<AppSettingsModel, int, QQueryOperations>
  skipForwardTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'skipForwardTime');
    });
  }

  QueryBuilder<AppSettingsModel, SleepTimerEnum, QQueryOperations>
  sleepTimerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sleepTimer');
    });
  }

  QueryBuilder<AppSettingsModel, int?, QQueryOperations>
  sleepTimerEndTimeMillisProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sleepTimerEndTimeMillis');
    });
  }

  QueryBuilder<AppSettingsModel, double, QQueryOperations> volumeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'volume');
    });
  }
}
