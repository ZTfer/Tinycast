// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'queue_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetQueueCollection on Isar {
  IsarCollection<Queue> get queues => this.collection();
}

const QueueSchema = CollectionSchema(
  name: r'Queue',
  id: 747233922160618226,
  properties: {
    r'addedAt': PropertySchema(
      id: 0,
      name: r'addedAt',
      type: IsarType.dateTime,
    ),
    r'episodeId': PropertySchema(
      id: 1,
      name: r'episodeId',
      type: IsarType.long,
    ),
    r'position': PropertySchema(id: 2, name: r'position', type: IsarType.long),
  },

  estimateSize: _queueEstimateSize,
  serialize: _queueSerialize,
  deserialize: _queueDeserialize,
  deserializeProp: _queueDeserializeProp,
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
    r'position': IndexSchema(
      id: 5117117876086213592,
      name: r'position',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'position',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _queueGetId,
  getLinks: _queueGetLinks,
  attach: _queueAttach,
  version: '3.3.2',
);

int _queueEstimateSize(
  Queue object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _queueSerialize(
  Queue object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.addedAt);
  writer.writeLong(offsets[1], object.episodeId);
  writer.writeLong(offsets[2], object.position);
}

Queue _queueDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Queue();
  object.episodeId = reader.readLong(offsets[1]);
  object.id = id;
  object.position = reader.readLong(offsets[2]);
  return object;
}

P _queueDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _queueGetId(Queue object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _queueGetLinks(Queue object) {
  return [];
}

void _queueAttach(IsarCollection<dynamic> col, Id id, Queue object) {
  object.id = id;
}

extension QueueQueryWhereSort on QueryBuilder<Queue, Queue, QWhere> {
  QueryBuilder<Queue, Queue, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<Queue, Queue, QAfterWhere> anyEpisodeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'episodeId'),
      );
    });
  }

  QueryBuilder<Queue, Queue, QAfterWhere> anyPosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'position'),
      );
    });
  }
}

extension QueueQueryWhere on QueryBuilder<Queue, Queue, QWhereClause> {
  QueryBuilder<Queue, Queue, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<Queue, Queue, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Queue, Queue, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Queue, Queue, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Queue, Queue, QAfterWhereClause> idBetween(
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

  QueryBuilder<Queue, Queue, QAfterWhereClause> episodeIdEqualTo(
    int episodeId,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'episodeId', value: [episodeId]),
      );
    });
  }

  QueryBuilder<Queue, Queue, QAfterWhereClause> episodeIdNotEqualTo(
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

  QueryBuilder<Queue, Queue, QAfterWhereClause> episodeIdGreaterThan(
    int episodeId, {
    bool include = false,
  }) {
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

  QueryBuilder<Queue, Queue, QAfterWhereClause> episodeIdLessThan(
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

  QueryBuilder<Queue, Queue, QAfterWhereClause> episodeIdBetween(
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

  QueryBuilder<Queue, Queue, QAfterWhereClause> positionEqualTo(int position) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'position', value: [position]),
      );
    });
  }

  QueryBuilder<Queue, Queue, QAfterWhereClause> positionNotEqualTo(
    int position,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'position',
                lower: [],
                upper: [position],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'position',
                lower: [position],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'position',
                lower: [position],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'position',
                lower: [],
                upper: [position],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<Queue, Queue, QAfterWhereClause> positionGreaterThan(
    int position, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'position',
          lower: [position],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<Queue, Queue, QAfterWhereClause> positionLessThan(
    int position, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'position',
          lower: [],
          upper: [position],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<Queue, Queue, QAfterWhereClause> positionBetween(
    int lowerPosition,
    int upperPosition, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'position',
          lower: [lowerPosition],
          includeLower: includeLower,
          upper: [upperPosition],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension QueueQueryFilter on QueryBuilder<Queue, Queue, QFilterCondition> {
  QueryBuilder<Queue, Queue, QAfterFilterCondition> addedAtEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'addedAt', value: value),
      );
    });
  }

  QueryBuilder<Queue, Queue, QAfterFilterCondition> addedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'addedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Queue, Queue, QAfterFilterCondition> addedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'addedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Queue, Queue, QAfterFilterCondition> addedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'addedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Queue, Queue, QAfterFilterCondition> episodeIdEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'episodeId', value: value),
      );
    });
  }

  QueryBuilder<Queue, Queue, QAfterFilterCondition> episodeIdGreaterThan(
    int value, {
    bool include = false,
  }) {
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

  QueryBuilder<Queue, Queue, QAfterFilterCondition> episodeIdLessThan(
    int value, {
    bool include = false,
  }) {
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

  QueryBuilder<Queue, Queue, QAfterFilterCondition> episodeIdBetween(
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

  QueryBuilder<Queue, Queue, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<Queue, Queue, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Queue, Queue, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Queue, Queue, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Queue, Queue, QAfterFilterCondition> positionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'position', value: value),
      );
    });
  }

  QueryBuilder<Queue, Queue, QAfterFilterCondition> positionGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'position',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Queue, Queue, QAfterFilterCondition> positionLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'position',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Queue, Queue, QAfterFilterCondition> positionBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'position',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension QueueQueryObject on QueryBuilder<Queue, Queue, QFilterCondition> {}

extension QueueQueryLinks on QueryBuilder<Queue, Queue, QFilterCondition> {}

extension QueueQuerySortBy on QueryBuilder<Queue, Queue, QSortBy> {
  QueryBuilder<Queue, Queue, QAfterSortBy> sortByAddedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAt', Sort.asc);
    });
  }

  QueryBuilder<Queue, Queue, QAfterSortBy> sortByAddedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAt', Sort.desc);
    });
  }

  QueryBuilder<Queue, Queue, QAfterSortBy> sortByEpisodeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeId', Sort.asc);
    });
  }

  QueryBuilder<Queue, Queue, QAfterSortBy> sortByEpisodeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeId', Sort.desc);
    });
  }

  QueryBuilder<Queue, Queue, QAfterSortBy> sortByPosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'position', Sort.asc);
    });
  }

  QueryBuilder<Queue, Queue, QAfterSortBy> sortByPositionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'position', Sort.desc);
    });
  }
}

extension QueueQuerySortThenBy on QueryBuilder<Queue, Queue, QSortThenBy> {
  QueryBuilder<Queue, Queue, QAfterSortBy> thenByAddedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAt', Sort.asc);
    });
  }

  QueryBuilder<Queue, Queue, QAfterSortBy> thenByAddedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAt', Sort.desc);
    });
  }

  QueryBuilder<Queue, Queue, QAfterSortBy> thenByEpisodeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeId', Sort.asc);
    });
  }

  QueryBuilder<Queue, Queue, QAfterSortBy> thenByEpisodeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeId', Sort.desc);
    });
  }

  QueryBuilder<Queue, Queue, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Queue, Queue, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Queue, Queue, QAfterSortBy> thenByPosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'position', Sort.asc);
    });
  }

  QueryBuilder<Queue, Queue, QAfterSortBy> thenByPositionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'position', Sort.desc);
    });
  }
}

extension QueueQueryWhereDistinct on QueryBuilder<Queue, Queue, QDistinct> {
  QueryBuilder<Queue, Queue, QDistinct> distinctByAddedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'addedAt');
    });
  }

  QueryBuilder<Queue, Queue, QDistinct> distinctByEpisodeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'episodeId');
    });
  }

  QueryBuilder<Queue, Queue, QDistinct> distinctByPosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'position');
    });
  }
}

extension QueueQueryProperty on QueryBuilder<Queue, Queue, QQueryProperty> {
  QueryBuilder<Queue, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Queue, DateTime, QQueryOperations> addedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'addedAt');
    });
  }

  QueryBuilder<Queue, int, QQueryOperations> episodeIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'episodeId');
    });
  }

  QueryBuilder<Queue, int, QQueryOperations> positionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'position');
    });
  }
}
