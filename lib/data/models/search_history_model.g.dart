// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_history_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

extension GetSearchHistoryModelCollection on Isar {
  IsarCollection<SearchHistoryModel> get searchHistoryModels =>
      this.collection();
}

const SearchHistoryModelSchema = CollectionSchema(
  name: r'SearchHistoryModel',
  id: 1846622114532998437,
  properties: {
    r'keyword': PropertySchema(id: 0, name: r'keyword', type: IsarType.string),
    r'searchedAt': PropertySchema(
      id: 1,
      name: r'searchedAt',
      type: IsarType.dateTime,
    ),
  },

  estimateSize: _searchHistoryModelEstimateSize,
  serialize: _searchHistoryModelSerialize,
  deserialize: _searchHistoryModelDeserialize,
  deserializeProp: _searchHistoryModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'searchedAt': IndexSchema(
      id: 4437879492455379665,
      name: r'searchedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'searchedAt',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _searchHistoryModelGetId,
  getLinks: _searchHistoryModelGetLinks,
  attach: _searchHistoryModelAttach,
  version: '3.4.1',
);

int _searchHistoryModelEstimateSize(
  SearchHistoryModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.keyword.length * 3;
  return bytesCount;
}

void _searchHistoryModelSerialize(
  SearchHistoryModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.keyword);
  writer.writeDateTime(offsets[1], object.searchedAt);
}

SearchHistoryModel _searchHistoryModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SearchHistoryModel();
  object.id = id;
  object.keyword = reader.readString(offsets[0]);
  object.searchedAt = reader.readDateTime(offsets[1]);
  return object;
}

P _searchHistoryModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _searchHistoryModelGetId(SearchHistoryModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _searchHistoryModelGetLinks(
  SearchHistoryModel object,
) {
  return [];
}

void _searchHistoryModelAttach(
  IsarCollection<dynamic> col,
  Id id,
  SearchHistoryModel object,
) {
  object.id = id;
}

extension SearchHistoryModelQueryWhereSort
    on QueryBuilder<SearchHistoryModel, SearchHistoryModel, QWhere> {
  QueryBuilder<SearchHistoryModel, SearchHistoryModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<SearchHistoryModel, SearchHistoryModel, QAfterWhere>
  anySearchedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'searchedAt'),
      );
    });
  }
}

extension SearchHistoryModelQueryWhere
    on QueryBuilder<SearchHistoryModel, SearchHistoryModel, QWhereClause> {
  QueryBuilder<SearchHistoryModel, SearchHistoryModel, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<SearchHistoryModel, SearchHistoryModel, QAfterWhereClause>
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

  QueryBuilder<SearchHistoryModel, SearchHistoryModel, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SearchHistoryModel, SearchHistoryModel, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SearchHistoryModel, SearchHistoryModel, QAfterWhereClause>
  idBetween(
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

  QueryBuilder<SearchHistoryModel, SearchHistoryModel, QAfterWhereClause>
  searchedAtEqualTo(DateTime searchedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'searchedAt', value: [searchedAt]),
      );
    });
  }

  QueryBuilder<SearchHistoryModel, SearchHistoryModel, QAfterWhereClause>
  searchedAtNotEqualTo(DateTime searchedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'searchedAt',
                lower: [],
                upper: [searchedAt],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'searchedAt',
                lower: [searchedAt],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'searchedAt',
                lower: [searchedAt],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'searchedAt',
                lower: [],
                upper: [searchedAt],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<SearchHistoryModel, SearchHistoryModel, QAfterWhereClause>
  searchedAtGreaterThan(DateTime searchedAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'searchedAt',
          lower: [searchedAt],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<SearchHistoryModel, SearchHistoryModel, QAfterWhereClause>
  searchedAtLessThan(DateTime searchedAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'searchedAt',
          lower: [],
          upper: [searchedAt],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<SearchHistoryModel, SearchHistoryModel, QAfterWhereClause>
  searchedAtBetween(
    DateTime lowerSearchedAt,
    DateTime upperSearchedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'searchedAt',
          lower: [lowerSearchedAt],
          includeLower: includeLower,
          upper: [upperSearchedAt],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension SearchHistoryModelQueryFilter
    on QueryBuilder<SearchHistoryModel, SearchHistoryModel, QFilterCondition> {
  QueryBuilder<SearchHistoryModel, SearchHistoryModel, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<SearchHistoryModel, SearchHistoryModel, QAfterFilterCondition>
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

  QueryBuilder<SearchHistoryModel, SearchHistoryModel, QAfterFilterCondition>
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

  QueryBuilder<SearchHistoryModel, SearchHistoryModel, QAfterFilterCondition>
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

  QueryBuilder<SearchHistoryModel, SearchHistoryModel, QAfterFilterCondition>
  keywordEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'keyword',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SearchHistoryModel, SearchHistoryModel, QAfterFilterCondition>
  keywordGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'keyword',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SearchHistoryModel, SearchHistoryModel, QAfterFilterCondition>
  keywordLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'keyword',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SearchHistoryModel, SearchHistoryModel, QAfterFilterCondition>
  keywordBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'keyword',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SearchHistoryModel, SearchHistoryModel, QAfterFilterCondition>
  keywordStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'keyword',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SearchHistoryModel, SearchHistoryModel, QAfterFilterCondition>
  keywordEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'keyword',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SearchHistoryModel, SearchHistoryModel, QAfterFilterCondition>
  keywordContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'keyword',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SearchHistoryModel, SearchHistoryModel, QAfterFilterCondition>
  keywordMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'keyword',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SearchHistoryModel, SearchHistoryModel, QAfterFilterCondition>
  keywordIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'keyword', value: ''),
      );
    });
  }

  QueryBuilder<SearchHistoryModel, SearchHistoryModel, QAfterFilterCondition>
  keywordIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'keyword', value: ''),
      );
    });
  }

  QueryBuilder<SearchHistoryModel, SearchHistoryModel, QAfterFilterCondition>
  searchedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'searchedAt', value: value),
      );
    });
  }

  QueryBuilder<SearchHistoryModel, SearchHistoryModel, QAfterFilterCondition>
  searchedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'searchedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SearchHistoryModel, SearchHistoryModel, QAfterFilterCondition>
  searchedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'searchedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SearchHistoryModel, SearchHistoryModel, QAfterFilterCondition>
  searchedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'searchedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension SearchHistoryModelQueryObject
    on QueryBuilder<SearchHistoryModel, SearchHistoryModel, QFilterCondition> {}

extension SearchHistoryModelQueryLinks
    on QueryBuilder<SearchHistoryModel, SearchHistoryModel, QFilterCondition> {}

extension SearchHistoryModelQuerySortBy
    on QueryBuilder<SearchHistoryModel, SearchHistoryModel, QSortBy> {
  QueryBuilder<SearchHistoryModel, SearchHistoryModel, QAfterSortBy>
  sortByKeyword() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'keyword', Sort.asc);
    });
  }

  QueryBuilder<SearchHistoryModel, SearchHistoryModel, QAfterSortBy>
  sortByKeywordDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'keyword', Sort.desc);
    });
  }

  QueryBuilder<SearchHistoryModel, SearchHistoryModel, QAfterSortBy>
  sortBySearchedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'searchedAt', Sort.asc);
    });
  }

  QueryBuilder<SearchHistoryModel, SearchHistoryModel, QAfterSortBy>
  sortBySearchedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'searchedAt', Sort.desc);
    });
  }
}

extension SearchHistoryModelQuerySortThenBy
    on QueryBuilder<SearchHistoryModel, SearchHistoryModel, QSortThenBy> {
  QueryBuilder<SearchHistoryModel, SearchHistoryModel, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SearchHistoryModel, SearchHistoryModel, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SearchHistoryModel, SearchHistoryModel, QAfterSortBy>
  thenByKeyword() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'keyword', Sort.asc);
    });
  }

  QueryBuilder<SearchHistoryModel, SearchHistoryModel, QAfterSortBy>
  thenByKeywordDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'keyword', Sort.desc);
    });
  }

  QueryBuilder<SearchHistoryModel, SearchHistoryModel, QAfterSortBy>
  thenBySearchedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'searchedAt', Sort.asc);
    });
  }

  QueryBuilder<SearchHistoryModel, SearchHistoryModel, QAfterSortBy>
  thenBySearchedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'searchedAt', Sort.desc);
    });
  }
}

extension SearchHistoryModelQueryWhereDistinct
    on QueryBuilder<SearchHistoryModel, SearchHistoryModel, QDistinct> {
  QueryBuilder<SearchHistoryModel, SearchHistoryModel, QDistinct>
  distinctByKeyword({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'keyword', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SearchHistoryModel, SearchHistoryModel, QDistinct>
  distinctBySearchedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'searchedAt');
    });
  }
}

extension SearchHistoryModelQueryProperty
    on QueryBuilder<SearchHistoryModel, SearchHistoryModel, QQueryProperty> {
  QueryBuilder<SearchHistoryModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SearchHistoryModel, String, QQueryOperations> keywordProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'keyword');
    });
  }

  QueryBuilder<SearchHistoryModel, DateTime, QQueryOperations>
  searchedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'searchedAt');
    });
  }
}
