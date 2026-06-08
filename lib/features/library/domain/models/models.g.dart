// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSongCollection on Isar {
  IsarCollection<Song> get songs => this.collection();
}

const SongSchema = CollectionSchema(
  name: r'Song',
  id: -5548886644249537934,
  properties: {
    r'album': PropertySchema(
      id: 0,
      name: r'album',
      type: IsarType.string,
    ),
    r'artPath': PropertySchema(
      id: 1,
      name: r'artPath',
      type: IsarType.string,
    ),
    r'artist': PropertySchema(
      id: 2,
      name: r'artist',
      type: IsarType.string,
    ),
    r'dateAdded': PropertySchema(
      id: 3,
      name: r'dateAdded',
      type: IsarType.dateTime,
    ),
    r'duration': PropertySchema(
      id: 4,
      name: r'duration',
      type: IsarType.long,
    ),
    r'genre': PropertySchema(
      id: 5,
      name: r'genre',
      type: IsarType.string,
    ),
    r'isFavorite': PropertySchema(
      id: 6,
      name: r'isFavorite',
      type: IsarType.bool,
    ),
    r'lastPlayed': PropertySchema(
      id: 7,
      name: r'lastPlayed',
      type: IsarType.dateTime,
    ),
    r'lyrics': PropertySchema(
      id: 8,
      name: r'lyrics',
      type: IsarType.string,
    ),
    r'path': PropertySchema(
      id: 9,
      name: r'path',
      type: IsarType.string,
    ),
    r'playCount': PropertySchema(
      id: 10,
      name: r'playCount',
      type: IsarType.long,
    ),
    r'searchTerms': PropertySchema(
      id: 11,
      name: r'searchTerms',
      type: IsarType.stringList,
    ),
    r'title': PropertySchema(
      id: 12,
      name: r'title',
      type: IsarType.string,
    ),
    r'trackNumber': PropertySchema(
      id: 13,
      name: r'trackNumber',
      type: IsarType.long,
    ),
    r'year': PropertySchema(
      id: 14,
      name: r'year',
      type: IsarType.long,
    )
  },
  estimateSize: _songEstimateSize,
  serialize: _songSerialize,
  deserialize: _songDeserialize,
  deserializeProp: _songDeserializeProp,
  idName: r'id',
  indexes: {
    r'path': IndexSchema(
      id: 8756705481922369689,
      name: r'path',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'path',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'artist': IndexSchema(
      id: 5842945185359817302,
      name: r'artist',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'artist',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'album': IndexSchema(
      id: 6222745341035631462,
      name: r'album',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'album',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'dateAdded': IndexSchema(
      id: 7425792204428031576,
      name: r'dateAdded',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'dateAdded',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'lastPlayed': IndexSchema(
      id: -8420677377986255979,
      name: r'lastPlayed',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'lastPlayed',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'searchTerms': IndexSchema(
      id: 255720506161592250,
      name: r'searchTerms',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'searchTerms',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _songGetId,
  getLinks: _songGetLinks,
  attach: _songAttach,
  version: '3.1.0+1',
);

int _songEstimateSize(
  Song object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.album;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.artPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.artist;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.genre;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.lyrics;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.path.length * 3;
  bytesCount += 3 + object.searchTerms.length * 3;
  {
    for (var i = 0; i < object.searchTerms.length; i++) {
      final value = object.searchTerms[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _songSerialize(
  Song object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.album);
  writer.writeString(offsets[1], object.artPath);
  writer.writeString(offsets[2], object.artist);
  writer.writeDateTime(offsets[3], object.dateAdded);
  writer.writeLong(offsets[4], object.duration);
  writer.writeString(offsets[5], object.genre);
  writer.writeBool(offsets[6], object.isFavorite);
  writer.writeDateTime(offsets[7], object.lastPlayed);
  writer.writeString(offsets[8], object.lyrics);
  writer.writeString(offsets[9], object.path);
  writer.writeLong(offsets[10], object.playCount);
  writer.writeStringList(offsets[11], object.searchTerms);
  writer.writeString(offsets[12], object.title);
  writer.writeLong(offsets[13], object.trackNumber);
  writer.writeLong(offsets[14], object.year);
}

Song _songDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Song();
  object.album = reader.readStringOrNull(offsets[0]);
  object.artPath = reader.readStringOrNull(offsets[1]);
  object.artist = reader.readStringOrNull(offsets[2]);
  object.dateAdded = reader.readDateTime(offsets[3]);
  object.duration = reader.readLongOrNull(offsets[4]);
  object.genre = reader.readStringOrNull(offsets[5]);
  object.id = id;
  object.isFavorite = reader.readBool(offsets[6]);
  object.lastPlayed = reader.readDateTimeOrNull(offsets[7]);
  object.lyrics = reader.readStringOrNull(offsets[8]);
  object.path = reader.readString(offsets[9]);
  object.playCount = reader.readLong(offsets[10]);
  object.title = reader.readString(offsets[12]);
  object.trackNumber = reader.readLongOrNull(offsets[13]);
  object.year = reader.readLongOrNull(offsets[14]);
  return object;
}

P _songDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    case 11:
      return (reader.readStringList(offset) ?? []) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readLongOrNull(offset)) as P;
    case 14:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _songGetId(Song object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _songGetLinks(Song object) {
  return [];
}

void _songAttach(IsarCollection<dynamic> col, Id id, Song object) {
  object.id = id;
}

extension SongByIndex on IsarCollection<Song> {
  Future<Song?> getByPath(String path) {
    return getByIndex(r'path', [path]);
  }

  Song? getByPathSync(String path) {
    return getByIndexSync(r'path', [path]);
  }

  Future<bool> deleteByPath(String path) {
    return deleteByIndex(r'path', [path]);
  }

  bool deleteByPathSync(String path) {
    return deleteByIndexSync(r'path', [path]);
  }

  Future<List<Song?>> getAllByPath(List<String> pathValues) {
    final values = pathValues.map((e) => [e]).toList();
    return getAllByIndex(r'path', values);
  }

  List<Song?> getAllByPathSync(List<String> pathValues) {
    final values = pathValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'path', values);
  }

  Future<int> deleteAllByPath(List<String> pathValues) {
    final values = pathValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'path', values);
  }

  int deleteAllByPathSync(List<String> pathValues) {
    final values = pathValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'path', values);
  }

  Future<Id> putByPath(Song object) {
    return putByIndex(r'path', object);
  }

  Id putByPathSync(Song object, {bool saveLinks = true}) {
    return putByIndexSync(r'path', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByPath(List<Song> objects) {
    return putAllByIndex(r'path', objects);
  }

  List<Id> putAllByPathSync(List<Song> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'path', objects, saveLinks: saveLinks);
  }
}

extension SongQueryWhereSort on QueryBuilder<Song, Song, QWhere> {
  QueryBuilder<Song, Song, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<Song, Song, QAfterWhere> anyDateAdded() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'dateAdded'),
      );
    });
  }

  QueryBuilder<Song, Song, QAfterWhere> anyLastPlayed() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'lastPlayed'),
      );
    });
  }

  QueryBuilder<Song, Song, QAfterWhere> anySearchTermsElement() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'searchTerms'),
      );
    });
  }
}

extension SongQueryWhere on QueryBuilder<Song, Song, QWhereClause> {
  QueryBuilder<Song, Song, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Song, Song, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> pathEqualTo(String path) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'path',
        value: [path],
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> pathNotEqualTo(String path) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'path',
              lower: [],
              upper: [path],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'path',
              lower: [path],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'path',
              lower: [path],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'path',
              lower: [],
              upper: [path],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> artistIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'artist',
        value: [null],
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> artistIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'artist',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> artistEqualTo(String? artist) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'artist',
        value: [artist],
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> artistNotEqualTo(String? artist) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'artist',
              lower: [],
              upper: [artist],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'artist',
              lower: [artist],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'artist',
              lower: [artist],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'artist',
              lower: [],
              upper: [artist],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> albumIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'album',
        value: [null],
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> albumIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'album',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> albumEqualTo(String? album) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'album',
        value: [album],
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> albumNotEqualTo(String? album) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'album',
              lower: [],
              upper: [album],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'album',
              lower: [album],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'album',
              lower: [album],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'album',
              lower: [],
              upper: [album],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> dateAddedEqualTo(
      DateTime dateAdded) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'dateAdded',
        value: [dateAdded],
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> dateAddedNotEqualTo(
      DateTime dateAdded) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dateAdded',
              lower: [],
              upper: [dateAdded],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dateAdded',
              lower: [dateAdded],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dateAdded',
              lower: [dateAdded],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dateAdded',
              lower: [],
              upper: [dateAdded],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> dateAddedGreaterThan(
    DateTime dateAdded, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'dateAdded',
        lower: [dateAdded],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> dateAddedLessThan(
    DateTime dateAdded, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'dateAdded',
        lower: [],
        upper: [dateAdded],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> dateAddedBetween(
    DateTime lowerDateAdded,
    DateTime upperDateAdded, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'dateAdded',
        lower: [lowerDateAdded],
        includeLower: includeLower,
        upper: [upperDateAdded],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> lastPlayedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'lastPlayed',
        value: [null],
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> lastPlayedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'lastPlayed',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> lastPlayedEqualTo(
      DateTime? lastPlayed) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'lastPlayed',
        value: [lastPlayed],
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> lastPlayedNotEqualTo(
      DateTime? lastPlayed) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastPlayed',
              lower: [],
              upper: [lastPlayed],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastPlayed',
              lower: [lastPlayed],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastPlayed',
              lower: [lastPlayed],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastPlayed',
              lower: [],
              upper: [lastPlayed],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> lastPlayedGreaterThan(
    DateTime? lastPlayed, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'lastPlayed',
        lower: [lastPlayed],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> lastPlayedLessThan(
    DateTime? lastPlayed, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'lastPlayed',
        lower: [],
        upper: [lastPlayed],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> lastPlayedBetween(
    DateTime? lowerLastPlayed,
    DateTime? upperLastPlayed, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'lastPlayed',
        lower: [lowerLastPlayed],
        includeLower: includeLower,
        upper: [upperLastPlayed],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> searchTermsElementEqualTo(
      String searchTermsElement) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'searchTerms',
        value: [searchTermsElement],
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> searchTermsElementNotEqualTo(
      String searchTermsElement) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'searchTerms',
              lower: [],
              upper: [searchTermsElement],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'searchTerms',
              lower: [searchTermsElement],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'searchTerms',
              lower: [searchTermsElement],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'searchTerms',
              lower: [],
              upper: [searchTermsElement],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> searchTermsElementGreaterThan(
    String searchTermsElement, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'searchTerms',
        lower: [searchTermsElement],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> searchTermsElementLessThan(
    String searchTermsElement, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'searchTerms',
        lower: [],
        upper: [searchTermsElement],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> searchTermsElementBetween(
    String lowerSearchTermsElement,
    String upperSearchTermsElement, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'searchTerms',
        lower: [lowerSearchTermsElement],
        includeLower: includeLower,
        upper: [upperSearchTermsElement],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> searchTermsElementStartsWith(
      String SearchTermsElementPrefix) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'searchTerms',
        lower: [SearchTermsElementPrefix],
        upper: ['$SearchTermsElementPrefix\u{FFFFF}'],
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> searchTermsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'searchTerms',
        value: [''],
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> searchTermsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'searchTerms',
              upper: [''],
            ))
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'searchTerms',
              lower: [''],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'searchTerms',
              lower: [''],
            ))
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'searchTerms',
              upper: [''],
            ));
      }
    });
  }
}

extension SongQueryFilter on QueryBuilder<Song, Song, QFilterCondition> {
  QueryBuilder<Song, Song, QAfterFilterCondition> albumIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'album',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> albumIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'album',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> albumEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'album',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> albumGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'album',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> albumLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'album',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> albumBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'album',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> albumStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'album',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> albumEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'album',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> albumContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'album',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> albumMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'album',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> albumIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'album',
        value: '',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> albumIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'album',
        value: '',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'artPath',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'artPath',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'artPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'artPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'artPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'artPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'artPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artPathContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'artPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artPathMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'artPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artPath',
        value: '',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'artPath',
        value: '',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artistIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'artist',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artistIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'artist',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artistEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artistGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artistLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artistBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'artist',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artistStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artistEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artistContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artistMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'artist',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artistIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artist',
        value: '',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artistIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'artist',
        value: '',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> dateAddedEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dateAdded',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> dateAddedGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dateAdded',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> dateAddedLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dateAdded',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> dateAddedBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dateAdded',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> durationIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'duration',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> durationIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'duration',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> durationEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'duration',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> durationGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'duration',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> durationLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'duration',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> durationBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'duration',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> genreIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'genre',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> genreIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'genre',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> genreEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'genre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> genreGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'genre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> genreLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'genre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> genreBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'genre',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> genreStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'genre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> genreEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'genre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> genreContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'genre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> genreMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'genre',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> genreIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'genre',
        value: '',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> genreIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'genre',
        value: '',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> isFavoriteEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isFavorite',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lastPlayedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastPlayed',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lastPlayedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastPlayed',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lastPlayedEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastPlayed',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lastPlayedGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastPlayed',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lastPlayedLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastPlayed',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lastPlayedBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastPlayed',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lyricsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lyrics',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lyricsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lyrics',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lyricsEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lyrics',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lyricsGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lyrics',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lyricsLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lyrics',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lyricsBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lyrics',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lyricsStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lyrics',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lyricsEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lyrics',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lyricsContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lyrics',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lyricsMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lyrics',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lyricsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lyrics',
        value: '',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lyricsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lyrics',
        value: '',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> pathEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'path',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> pathGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'path',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> pathLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'path',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> pathBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'path',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> pathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'path',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> pathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'path',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> pathContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'path',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> pathMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'path',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> pathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'path',
        value: '',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> pathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'path',
        value: '',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> playCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'playCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> playCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'playCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> playCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'playCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> playCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'playCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> searchTermsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'searchTerms',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> searchTermsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'searchTerms',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> searchTermsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'searchTerms',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> searchTermsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'searchTerms',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> searchTermsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'searchTerms',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> searchTermsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'searchTerms',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> searchTermsElementContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'searchTerms',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> searchTermsElementMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'searchTerms',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> searchTermsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'searchTerms',
        value: '',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition>
      searchTermsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'searchTerms',
        value: '',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> searchTermsLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'searchTerms',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> searchTermsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'searchTerms',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> searchTermsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'searchTerms',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> searchTermsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'searchTerms',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> searchTermsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'searchTerms',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> searchTermsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'searchTerms',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> titleContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> titleMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> trackNumberIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'trackNumber',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> trackNumberIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'trackNumber',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> trackNumberEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'trackNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> trackNumberGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'trackNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> trackNumberLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'trackNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> trackNumberBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'trackNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> yearIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'year',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> yearIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'year',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> yearEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'year',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> yearGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'year',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> yearLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'year',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> yearBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'year',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SongQueryObject on QueryBuilder<Song, Song, QFilterCondition> {}

extension SongQueryLinks on QueryBuilder<Song, Song, QFilterCondition> {}

extension SongQuerySortBy on QueryBuilder<Song, Song, QSortBy> {
  QueryBuilder<Song, Song, QAfterSortBy> sortByAlbum() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'album', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByAlbumDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'album', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByArtPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artPath', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByArtPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artPath', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByArtist() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artist', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByArtistDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artist', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByDateAdded() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateAdded', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByDateAddedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateAdded', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByGenre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'genre', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByGenreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'genre', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByIsFavorite() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavorite', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByIsFavoriteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavorite', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByLastPlayed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayed', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByLastPlayedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayed', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByLyrics() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lyrics', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByLyricsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lyrics', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'path', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'path', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByPlayCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playCount', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByPlayCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playCount', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByTrackNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackNumber', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByTrackNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackNumber', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'year', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'year', Sort.desc);
    });
  }
}

extension SongQuerySortThenBy on QueryBuilder<Song, Song, QSortThenBy> {
  QueryBuilder<Song, Song, QAfterSortBy> thenByAlbum() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'album', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByAlbumDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'album', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByArtPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artPath', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByArtPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artPath', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByArtist() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artist', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByArtistDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artist', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByDateAdded() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateAdded', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByDateAddedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateAdded', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByGenre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'genre', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByGenreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'genre', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByIsFavorite() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavorite', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByIsFavoriteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavorite', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByLastPlayed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayed', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByLastPlayedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayed', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByLyrics() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lyrics', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByLyricsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lyrics', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'path', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'path', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByPlayCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playCount', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByPlayCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playCount', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByTrackNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackNumber', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByTrackNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackNumber', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'year', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'year', Sort.desc);
    });
  }
}

extension SongQueryWhereDistinct on QueryBuilder<Song, Song, QDistinct> {
  QueryBuilder<Song, Song, QDistinct> distinctByAlbum(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'album', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctByArtPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'artPath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctByArtist(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'artist', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctByDateAdded() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dateAdded');
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctByDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'duration');
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctByGenre(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'genre', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctByIsFavorite() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isFavorite');
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctByLastPlayed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastPlayed');
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctByLyrics(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lyrics', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctByPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'path', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctByPlayCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'playCount');
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctBySearchTerms() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'searchTerms');
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctByTrackNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'trackNumber');
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctByYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'year');
    });
  }
}

extension SongQueryProperty on QueryBuilder<Song, Song, QQueryProperty> {
  QueryBuilder<Song, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Song, String?, QQueryOperations> albumProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'album');
    });
  }

  QueryBuilder<Song, String?, QQueryOperations> artPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'artPath');
    });
  }

  QueryBuilder<Song, String?, QQueryOperations> artistProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'artist');
    });
  }

  QueryBuilder<Song, DateTime, QQueryOperations> dateAddedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dateAdded');
    });
  }

  QueryBuilder<Song, int?, QQueryOperations> durationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'duration');
    });
  }

  QueryBuilder<Song, String?, QQueryOperations> genreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'genre');
    });
  }

  QueryBuilder<Song, bool, QQueryOperations> isFavoriteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isFavorite');
    });
  }

  QueryBuilder<Song, DateTime?, QQueryOperations> lastPlayedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastPlayed');
    });
  }

  QueryBuilder<Song, String?, QQueryOperations> lyricsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lyrics');
    });
  }

  QueryBuilder<Song, String, QQueryOperations> pathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'path');
    });
  }

  QueryBuilder<Song, int, QQueryOperations> playCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'playCount');
    });
  }

  QueryBuilder<Song, List<String>, QQueryOperations> searchTermsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'searchTerms');
    });
  }

  QueryBuilder<Song, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<Song, int?, QQueryOperations> trackNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'trackNumber');
    });
  }

  QueryBuilder<Song, int?, QQueryOperations> yearProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'year');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAlbumCollection on Isar {
  IsarCollection<Album> get albums => this.collection();
}

const AlbumSchema = CollectionSchema(
  name: r'Album',
  id: -1355968412107120937,
  properties: {
    r'artPath': PropertySchema(
      id: 0,
      name: r'artPath',
      type: IsarType.string,
    ),
    r'artist': PropertySchema(
      id: 1,
      name: r'artist',
      type: IsarType.string,
    ),
    r'dateAdded': PropertySchema(
      id: 2,
      name: r'dateAdded',
      type: IsarType.dateTime,
    ),
    r'name': PropertySchema(
      id: 3,
      name: r'name',
      type: IsarType.string,
    ),
    r'year': PropertySchema(
      id: 4,
      name: r'year',
      type: IsarType.long,
    )
  },
  estimateSize: _albumEstimateSize,
  serialize: _albumSerialize,
  deserialize: _albumDeserialize,
  deserializeProp: _albumDeserializeProp,
  idName: r'id',
  indexes: {
    r'name': IndexSchema(
      id: 879695947855722453,
      name: r'name',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'name',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'dateAdded': IndexSchema(
      id: 7425792204428031576,
      name: r'dateAdded',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'dateAdded',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _albumGetId,
  getLinks: _albumGetLinks,
  attach: _albumAttach,
  version: '3.1.0+1',
);

int _albumEstimateSize(
  Album object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.artPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.artist;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.name.length * 3;
  return bytesCount;
}

void _albumSerialize(
  Album object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.artPath);
  writer.writeString(offsets[1], object.artist);
  writer.writeDateTime(offsets[2], object.dateAdded);
  writer.writeString(offsets[3], object.name);
  writer.writeLong(offsets[4], object.year);
}

Album _albumDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Album();
  object.artPath = reader.readStringOrNull(offsets[0]);
  object.artist = reader.readStringOrNull(offsets[1]);
  object.dateAdded = reader.readDateTime(offsets[2]);
  object.id = id;
  object.name = reader.readString(offsets[3]);
  object.year = reader.readLongOrNull(offsets[4]);
  return object;
}

P _albumDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _albumGetId(Album object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _albumGetLinks(Album object) {
  return [];
}

void _albumAttach(IsarCollection<dynamic> col, Id id, Album object) {
  object.id = id;
}

extension AlbumByIndex on IsarCollection<Album> {
  Future<Album?> getByName(String name) {
    return getByIndex(r'name', [name]);
  }

  Album? getByNameSync(String name) {
    return getByIndexSync(r'name', [name]);
  }

  Future<bool> deleteByName(String name) {
    return deleteByIndex(r'name', [name]);
  }

  bool deleteByNameSync(String name) {
    return deleteByIndexSync(r'name', [name]);
  }

  Future<List<Album?>> getAllByName(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return getAllByIndex(r'name', values);
  }

  List<Album?> getAllByNameSync(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'name', values);
  }

  Future<int> deleteAllByName(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'name', values);
  }

  int deleteAllByNameSync(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'name', values);
  }

  Future<Id> putByName(Album object) {
    return putByIndex(r'name', object);
  }

  Id putByNameSync(Album object, {bool saveLinks = true}) {
    return putByIndexSync(r'name', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByName(List<Album> objects) {
    return putAllByIndex(r'name', objects);
  }

  List<Id> putAllByNameSync(List<Album> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'name', objects, saveLinks: saveLinks);
  }
}

extension AlbumQueryWhereSort on QueryBuilder<Album, Album, QWhere> {
  QueryBuilder<Album, Album, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<Album, Album, QAfterWhere> anyDateAdded() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'dateAdded'),
      );
    });
  }
}

extension AlbumQueryWhere on QueryBuilder<Album, Album, QWhereClause> {
  QueryBuilder<Album, Album, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Album, Album, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Album, Album, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Album, Album, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterWhereClause> nameEqualTo(String name) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'name',
        value: [name],
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterWhereClause> nameNotEqualTo(String name) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [],
              upper: [name],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [name],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [name],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [],
              upper: [name],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Album, Album, QAfterWhereClause> dateAddedEqualTo(
      DateTime dateAdded) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'dateAdded',
        value: [dateAdded],
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterWhereClause> dateAddedNotEqualTo(
      DateTime dateAdded) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dateAdded',
              lower: [],
              upper: [dateAdded],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dateAdded',
              lower: [dateAdded],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dateAdded',
              lower: [dateAdded],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dateAdded',
              lower: [],
              upper: [dateAdded],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Album, Album, QAfterWhereClause> dateAddedGreaterThan(
    DateTime dateAdded, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'dateAdded',
        lower: [dateAdded],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterWhereClause> dateAddedLessThan(
    DateTime dateAdded, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'dateAdded',
        lower: [],
        upper: [dateAdded],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterWhereClause> dateAddedBetween(
    DateTime lowerDateAdded,
    DateTime upperDateAdded, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'dateAdded',
        lower: [lowerDateAdded],
        includeLower: includeLower,
        upper: [upperDateAdded],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AlbumQueryFilter on QueryBuilder<Album, Album, QFilterCondition> {
  QueryBuilder<Album, Album, QAfterFilterCondition> artPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'artPath',
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> artPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'artPath',
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> artPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> artPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'artPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> artPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'artPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> artPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'artPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> artPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'artPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> artPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'artPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> artPathContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'artPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> artPathMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'artPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> artPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artPath',
        value: '',
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> artPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'artPath',
        value: '',
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> artistIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'artist',
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> artistIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'artist',
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> artistEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> artistGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> artistLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> artistBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'artist',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> artistStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> artistEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> artistContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> artistMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'artist',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> artistIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artist',
        value: '',
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> artistIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'artist',
        value: '',
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> dateAddedEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dateAdded',
        value: value,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> dateAddedGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dateAdded',
        value: value,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> dateAddedLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dateAdded',
        value: value,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> dateAddedBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dateAdded',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> nameContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> nameMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> yearIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'year',
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> yearIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'year',
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> yearEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'year',
        value: value,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> yearGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'year',
        value: value,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> yearLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'year',
        value: value,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> yearBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'year',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AlbumQueryObject on QueryBuilder<Album, Album, QFilterCondition> {}

extension AlbumQueryLinks on QueryBuilder<Album, Album, QFilterCondition> {}

extension AlbumQuerySortBy on QueryBuilder<Album, Album, QSortBy> {
  QueryBuilder<Album, Album, QAfterSortBy> sortByArtPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artPath', Sort.asc);
    });
  }

  QueryBuilder<Album, Album, QAfterSortBy> sortByArtPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artPath', Sort.desc);
    });
  }

  QueryBuilder<Album, Album, QAfterSortBy> sortByArtist() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artist', Sort.asc);
    });
  }

  QueryBuilder<Album, Album, QAfterSortBy> sortByArtistDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artist', Sort.desc);
    });
  }

  QueryBuilder<Album, Album, QAfterSortBy> sortByDateAdded() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateAdded', Sort.asc);
    });
  }

  QueryBuilder<Album, Album, QAfterSortBy> sortByDateAddedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateAdded', Sort.desc);
    });
  }

  QueryBuilder<Album, Album, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Album, Album, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Album, Album, QAfterSortBy> sortByYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'year', Sort.asc);
    });
  }

  QueryBuilder<Album, Album, QAfterSortBy> sortByYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'year', Sort.desc);
    });
  }
}

extension AlbumQuerySortThenBy on QueryBuilder<Album, Album, QSortThenBy> {
  QueryBuilder<Album, Album, QAfterSortBy> thenByArtPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artPath', Sort.asc);
    });
  }

  QueryBuilder<Album, Album, QAfterSortBy> thenByArtPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artPath', Sort.desc);
    });
  }

  QueryBuilder<Album, Album, QAfterSortBy> thenByArtist() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artist', Sort.asc);
    });
  }

  QueryBuilder<Album, Album, QAfterSortBy> thenByArtistDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artist', Sort.desc);
    });
  }

  QueryBuilder<Album, Album, QAfterSortBy> thenByDateAdded() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateAdded', Sort.asc);
    });
  }

  QueryBuilder<Album, Album, QAfterSortBy> thenByDateAddedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateAdded', Sort.desc);
    });
  }

  QueryBuilder<Album, Album, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Album, Album, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Album, Album, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Album, Album, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Album, Album, QAfterSortBy> thenByYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'year', Sort.asc);
    });
  }

  QueryBuilder<Album, Album, QAfterSortBy> thenByYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'year', Sort.desc);
    });
  }
}

extension AlbumQueryWhereDistinct on QueryBuilder<Album, Album, QDistinct> {
  QueryBuilder<Album, Album, QDistinct> distinctByArtPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'artPath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Album, Album, QDistinct> distinctByArtist(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'artist', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Album, Album, QDistinct> distinctByDateAdded() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dateAdded');
    });
  }

  QueryBuilder<Album, Album, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Album, Album, QDistinct> distinctByYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'year');
    });
  }
}

extension AlbumQueryProperty on QueryBuilder<Album, Album, QQueryProperty> {
  QueryBuilder<Album, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Album, String?, QQueryOperations> artPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'artPath');
    });
  }

  QueryBuilder<Album, String?, QQueryOperations> artistProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'artist');
    });
  }

  QueryBuilder<Album, DateTime, QQueryOperations> dateAddedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dateAdded');
    });
  }

  QueryBuilder<Album, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<Album, int?, QQueryOperations> yearProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'year');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetArtistCollection on Isar {
  IsarCollection<Artist> get artists => this.collection();
}

const ArtistSchema = CollectionSchema(
  name: r'Artist',
  id: 3750894727498641923,
  properties: {
    r'artPath': PropertySchema(
      id: 0,
      name: r'artPath',
      type: IsarType.string,
    ),
    r'artistImageUrl': PropertySchema(
      id: 1,
      name: r'artistImageUrl',
      type: IsarType.string,
    ),
    r'name': PropertySchema(
      id: 2,
      name: r'name',
      type: IsarType.string,
    )
  },
  estimateSize: _artistEstimateSize,
  serialize: _artistSerialize,
  deserialize: _artistDeserialize,
  deserializeProp: _artistDeserializeProp,
  idName: r'id',
  indexes: {
    r'name': IndexSchema(
      id: 879695947855722453,
      name: r'name',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'name',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _artistGetId,
  getLinks: _artistGetLinks,
  attach: _artistAttach,
  version: '3.1.0+1',
);

int _artistEstimateSize(
  Artist object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.artPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.artistImageUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.name.length * 3;
  return bytesCount;
}

void _artistSerialize(
  Artist object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.artPath);
  writer.writeString(offsets[1], object.artistImageUrl);
  writer.writeString(offsets[2], object.name);
}

Artist _artistDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Artist();
  object.artPath = reader.readStringOrNull(offsets[0]);
  object.artistImageUrl = reader.readStringOrNull(offsets[1]);
  object.id = id;
  object.name = reader.readString(offsets[2]);
  return object;
}

P _artistDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _artistGetId(Artist object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _artistGetLinks(Artist object) {
  return [];
}

void _artistAttach(IsarCollection<dynamic> col, Id id, Artist object) {
  object.id = id;
}

extension ArtistByIndex on IsarCollection<Artist> {
  Future<Artist?> getByName(String name) {
    return getByIndex(r'name', [name]);
  }

  Artist? getByNameSync(String name) {
    return getByIndexSync(r'name', [name]);
  }

  Future<bool> deleteByName(String name) {
    return deleteByIndex(r'name', [name]);
  }

  bool deleteByNameSync(String name) {
    return deleteByIndexSync(r'name', [name]);
  }

  Future<List<Artist?>> getAllByName(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return getAllByIndex(r'name', values);
  }

  List<Artist?> getAllByNameSync(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'name', values);
  }

  Future<int> deleteAllByName(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'name', values);
  }

  int deleteAllByNameSync(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'name', values);
  }

  Future<Id> putByName(Artist object) {
    return putByIndex(r'name', object);
  }

  Id putByNameSync(Artist object, {bool saveLinks = true}) {
    return putByIndexSync(r'name', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByName(List<Artist> objects) {
    return putAllByIndex(r'name', objects);
  }

  List<Id> putAllByNameSync(List<Artist> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'name', objects, saveLinks: saveLinks);
  }
}

extension ArtistQueryWhereSort on QueryBuilder<Artist, Artist, QWhere> {
  QueryBuilder<Artist, Artist, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ArtistQueryWhere on QueryBuilder<Artist, Artist, QWhereClause> {
  QueryBuilder<Artist, Artist, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Artist, Artist, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Artist, Artist, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Artist, Artist, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterWhereClause> nameEqualTo(String name) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'name',
        value: [name],
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterWhereClause> nameNotEqualTo(String name) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [],
              upper: [name],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [name],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [name],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [],
              upper: [name],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ArtistQueryFilter on QueryBuilder<Artist, Artist, QFilterCondition> {
  QueryBuilder<Artist, Artist, QAfterFilterCondition> artPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'artPath',
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> artPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'artPath',
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> artPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> artPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'artPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> artPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'artPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> artPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'artPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> artPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'artPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> artPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'artPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> artPathContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'artPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> artPathMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'artPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> artPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artPath',
        value: '',
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> artPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'artPath',
        value: '',
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> artistImageUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'artistImageUrl',
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition>
      artistImageUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'artistImageUrl',
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> artistImageUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artistImageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> artistImageUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'artistImageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> artistImageUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'artistImageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> artistImageUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'artistImageUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> artistImageUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'artistImageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> artistImageUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'artistImageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> artistImageUrlContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'artistImageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> artistImageUrlMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'artistImageUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> artistImageUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artistImageUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition>
      artistImageUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'artistImageUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> nameContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }
}

extension ArtistQueryObject on QueryBuilder<Artist, Artist, QFilterCondition> {}

extension ArtistQueryLinks on QueryBuilder<Artist, Artist, QFilterCondition> {}

extension ArtistQuerySortBy on QueryBuilder<Artist, Artist, QSortBy> {
  QueryBuilder<Artist, Artist, QAfterSortBy> sortByArtPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artPath', Sort.asc);
    });
  }

  QueryBuilder<Artist, Artist, QAfterSortBy> sortByArtPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artPath', Sort.desc);
    });
  }

  QueryBuilder<Artist, Artist, QAfterSortBy> sortByArtistImageUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artistImageUrl', Sort.asc);
    });
  }

  QueryBuilder<Artist, Artist, QAfterSortBy> sortByArtistImageUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artistImageUrl', Sort.desc);
    });
  }

  QueryBuilder<Artist, Artist, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Artist, Artist, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }
}

extension ArtistQuerySortThenBy on QueryBuilder<Artist, Artist, QSortThenBy> {
  QueryBuilder<Artist, Artist, QAfterSortBy> thenByArtPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artPath', Sort.asc);
    });
  }

  QueryBuilder<Artist, Artist, QAfterSortBy> thenByArtPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artPath', Sort.desc);
    });
  }

  QueryBuilder<Artist, Artist, QAfterSortBy> thenByArtistImageUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artistImageUrl', Sort.asc);
    });
  }

  QueryBuilder<Artist, Artist, QAfterSortBy> thenByArtistImageUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artistImageUrl', Sort.desc);
    });
  }

  QueryBuilder<Artist, Artist, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Artist, Artist, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Artist, Artist, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Artist, Artist, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }
}

extension ArtistQueryWhereDistinct on QueryBuilder<Artist, Artist, QDistinct> {
  QueryBuilder<Artist, Artist, QDistinct> distinctByArtPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'artPath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Artist, Artist, QDistinct> distinctByArtistImageUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'artistImageUrl',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Artist, Artist, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }
}

extension ArtistQueryProperty on QueryBuilder<Artist, Artist, QQueryProperty> {
  QueryBuilder<Artist, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Artist, String?, QQueryOperations> artPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'artPath');
    });
  }

  QueryBuilder<Artist, String?, QQueryOperations> artistImageUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'artistImageUrl');
    });
  }

  QueryBuilder<Artist, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPlaylistCollection on Isar {
  IsarCollection<Playlist> get playlists => this.collection();
}

const PlaylistSchema = CollectionSchema(
  name: r'Playlist',
  id: 4190497698144499986,
  properties: {
    r'dateCreated': PropertySchema(
      id: 0,
      name: r'dateCreated',
      type: IsarType.dateTime,
    ),
    r'dateModified': PropertySchema(
      id: 1,
      name: r'dateModified',
      type: IsarType.dateTime,
    ),
    r'name': PropertySchema(
      id: 2,
      name: r'name',
      type: IsarType.string,
    ),
    r'songPaths': PropertySchema(
      id: 3,
      name: r'songPaths',
      type: IsarType.stringList,
    )
  },
  estimateSize: _playlistEstimateSize,
  serialize: _playlistSerialize,
  deserialize: _playlistDeserialize,
  deserializeProp: _playlistDeserializeProp,
  idName: r'id',
  indexes: {
    r'name': IndexSchema(
      id: 879695947855722453,
      name: r'name',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'name',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _playlistGetId,
  getLinks: _playlistGetLinks,
  attach: _playlistAttach,
  version: '3.1.0+1',
);

int _playlistEstimateSize(
  Playlist object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.songPaths.length * 3;
  {
    for (var i = 0; i < object.songPaths.length; i++) {
      final value = object.songPaths[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _playlistSerialize(
  Playlist object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.dateCreated);
  writer.writeDateTime(offsets[1], object.dateModified);
  writer.writeString(offsets[2], object.name);
  writer.writeStringList(offsets[3], object.songPaths);
}

Playlist _playlistDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Playlist();
  object.dateCreated = reader.readDateTime(offsets[0]);
  object.dateModified = reader.readDateTime(offsets[1]);
  object.id = id;
  object.name = reader.readString(offsets[2]);
  object.songPaths = reader.readStringList(offsets[3]) ?? [];
  return object;
}

P _playlistDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readStringList(offset) ?? []) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _playlistGetId(Playlist object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _playlistGetLinks(Playlist object) {
  return [];
}

void _playlistAttach(IsarCollection<dynamic> col, Id id, Playlist object) {
  object.id = id;
}

extension PlaylistByIndex on IsarCollection<Playlist> {
  Future<Playlist?> getByName(String name) {
    return getByIndex(r'name', [name]);
  }

  Playlist? getByNameSync(String name) {
    return getByIndexSync(r'name', [name]);
  }

  Future<bool> deleteByName(String name) {
    return deleteByIndex(r'name', [name]);
  }

  bool deleteByNameSync(String name) {
    return deleteByIndexSync(r'name', [name]);
  }

  Future<List<Playlist?>> getAllByName(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return getAllByIndex(r'name', values);
  }

  List<Playlist?> getAllByNameSync(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'name', values);
  }

  Future<int> deleteAllByName(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'name', values);
  }

  int deleteAllByNameSync(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'name', values);
  }

  Future<Id> putByName(Playlist object) {
    return putByIndex(r'name', object);
  }

  Id putByNameSync(Playlist object, {bool saveLinks = true}) {
    return putByIndexSync(r'name', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByName(List<Playlist> objects) {
    return putAllByIndex(r'name', objects);
  }

  List<Id> putAllByNameSync(List<Playlist> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'name', objects, saveLinks: saveLinks);
  }
}

extension PlaylistQueryWhereSort on QueryBuilder<Playlist, Playlist, QWhere> {
  QueryBuilder<Playlist, Playlist, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PlaylistQueryWhere on QueryBuilder<Playlist, Playlist, QWhereClause> {
  QueryBuilder<Playlist, Playlist, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Playlist, Playlist, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterWhereClause> nameEqualTo(String name) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'name',
        value: [name],
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterWhereClause> nameNotEqualTo(
      String name) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [],
              upper: [name],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [name],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [name],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [],
              upper: [name],
              includeUpper: false,
            ));
      }
    });
  }
}

extension PlaylistQueryFilter
    on QueryBuilder<Playlist, Playlist, QFilterCondition> {
  QueryBuilder<Playlist, Playlist, QAfterFilterCondition> dateCreatedEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dateCreated',
        value: value,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition>
      dateCreatedGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dateCreated',
        value: value,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition> dateCreatedLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dateCreated',
        value: value,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition> dateCreatedBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dateCreated',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition> dateModifiedEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dateModified',
        value: value,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition>
      dateModifiedGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dateModified',
        value: value,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition> dateModifiedLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dateModified',
        value: value,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition> dateModifiedBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dateModified',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition>
      songPathsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'songPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition>
      songPathsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'songPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition>
      songPathsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'songPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition>
      songPathsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'songPaths',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition>
      songPathsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'songPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition>
      songPathsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'songPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition>
      songPathsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'songPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition>
      songPathsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'songPaths',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition>
      songPathsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'songPaths',
        value: '',
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition>
      songPathsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'songPaths',
        value: '',
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition>
      songPathsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'songPaths',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition> songPathsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'songPaths',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition>
      songPathsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'songPaths',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition>
      songPathsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'songPaths',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition>
      songPathsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'songPaths',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition>
      songPathsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'songPaths',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension PlaylistQueryObject
    on QueryBuilder<Playlist, Playlist, QFilterCondition> {}

extension PlaylistQueryLinks
    on QueryBuilder<Playlist, Playlist, QFilterCondition> {}

extension PlaylistQuerySortBy on QueryBuilder<Playlist, Playlist, QSortBy> {
  QueryBuilder<Playlist, Playlist, QAfterSortBy> sortByDateCreated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateCreated', Sort.asc);
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterSortBy> sortByDateCreatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateCreated', Sort.desc);
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterSortBy> sortByDateModified() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateModified', Sort.asc);
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterSortBy> sortByDateModifiedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateModified', Sort.desc);
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }
}

extension PlaylistQuerySortThenBy
    on QueryBuilder<Playlist, Playlist, QSortThenBy> {
  QueryBuilder<Playlist, Playlist, QAfterSortBy> thenByDateCreated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateCreated', Sort.asc);
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterSortBy> thenByDateCreatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateCreated', Sort.desc);
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterSortBy> thenByDateModified() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateModified', Sort.asc);
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterSortBy> thenByDateModifiedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateModified', Sort.desc);
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }
}

extension PlaylistQueryWhereDistinct
    on QueryBuilder<Playlist, Playlist, QDistinct> {
  QueryBuilder<Playlist, Playlist, QDistinct> distinctByDateCreated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dateCreated');
    });
  }

  QueryBuilder<Playlist, Playlist, QDistinct> distinctByDateModified() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dateModified');
    });
  }

  QueryBuilder<Playlist, Playlist, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Playlist, Playlist, QDistinct> distinctBySongPaths() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'songPaths');
    });
  }
}

extension PlaylistQueryProperty
    on QueryBuilder<Playlist, Playlist, QQueryProperty> {
  QueryBuilder<Playlist, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Playlist, DateTime, QQueryOperations> dateCreatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dateCreated');
    });
  }

  QueryBuilder<Playlist, DateTime, QQueryOperations> dateModifiedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dateModified');
    });
  }

  QueryBuilder<Playlist, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<Playlist, List<String>, QQueryOperations> songPathsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'songPaths');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAppSettingsCollection on Isar {
  IsarCollection<AppSettings> get appSettings => this.collection();
}

const AppSettingsSchema = CollectionSchema(
  name: r'AppSettings',
  id: -5633561779022347008,
  properties: {
    r'accentColor': PropertySchema(
      id: 0,
      name: r'accentColor',
      type: IsarType.long,
    ),
    r'audioFocus': PropertySchema(
      id: 1,
      name: r'audioFocus',
      type: IsarType.bool,
    ),
    r'bgBrightness': PropertySchema(
      id: 2,
      name: r'bgBrightness',
      type: IsarType.double,
    ),
    r'bgOpacity': PropertySchema(
      id: 3,
      name: r'bgOpacity',
      type: IsarType.double,
    ),
    r'crossfadeLength': PropertySchema(
      id: 4,
      name: r'crossfadeLength',
      type: IsarType.long,
    ),
    r'customBackgroundImagePath': PropertySchema(
      id: 5,
      name: r'customBackgroundImagePath',
      type: IsarType.string,
    ),
    r'darkTheme': PropertySchema(
      id: 6,
      name: r'darkTheme',
      type: IsarType.bool,
    ),
    r'disableAnimatedDuration': PropertySchema(
      id: 7,
      name: r'disableAnimatedDuration',
      type: IsarType.bool,
    ),
    r'disableBlur': PropertySchema(
      id: 8,
      name: r'disableBlur',
      type: IsarType.bool,
    ),
    r'disableSquiggle': PropertySchema(
      id: 9,
      name: r'disableSquiggle',
      type: IsarType.bool,
    ),
    r'downloadArtwork': PropertySchema(
      id: 10,
      name: r'downloadArtwork',
      type: IsarType.bool,
    ),
    r'dynamicAccentColor': PropertySchema(
      id: 11,
      name: r'dynamicAccentColor',
      type: IsarType.bool,
    ),
    r'dynamicColorActiveLyrics': PropertySchema(
      id: 12,
      name: r'dynamicColorActiveLyrics',
      type: IsarType.bool,
    ),
    r'dynamicLyrics': PropertySchema(
      id: 13,
      name: r'dynamicLyrics',
      type: IsarType.bool,
    ),
    r'enableCrossfade': PropertySchema(
      id: 14,
      name: r'enableCrossfade',
      type: IsarType.bool,
    ),
    r'enableDynamicTheming': PropertySchema(
      id: 15,
      name: r'enableDynamicTheming',
      type: IsarType.bool,
    ),
    r'enableInternet': PropertySchema(
      id: 16,
      name: r'enableInternet',
      type: IsarType.bool,
    ),
    r'enablePlayerGradient': PropertySchema(
      id: 17,
      name: r'enablePlayerGradient',
      type: IsarType.bool,
    ),
    r'enableSlideGesture': PropertySchema(
      id: 18,
      name: r'enableSlideGesture',
      type: IsarType.bool,
    ),
    r'fadeOnSeek': PropertySchema(
      id: 19,
      name: r'fadeOnSeek',
      type: IsarType.bool,
    ),
    r'fadePlayPauseStop': PropertySchema(
      id: 20,
      name: r'fadePlayPauseStop',
      type: IsarType.bool,
    ),
    r'homeDarkness': PropertySchema(
      id: 21,
      name: r'homeDarkness',
      type: IsarType.double,
    ),
    r'homeSectionOrder': PropertySchema(
      id: 22,
      name: r'homeSectionOrder',
      type: IsarType.stringList,
    ),
    r'keepBackgroundGradient': PropertySchema(
      id: 23,
      name: r'keepBackgroundGradient',
      type: IsarType.bool,
    ),
    r'language': PropertySchema(
      id: 24,
      name: r'language',
      type: IsarType.string,
    ),
    r'lastPlayedSongId': PropertySchema(
      id: 25,
      name: r'lastPlayedSongId',
      type: IsarType.long,
    ),
    r'libraryDarkness': PropertySchema(
      id: 26,
      name: r'libraryDarkness',
      type: IsarType.double,
    ),
    r'libraryFolders': PropertySchema(
      id: 27,
      name: r'libraryFolders',
      type: IsarType.stringList,
    ),
    r'lyricsAlignment': PropertySchema(
      id: 28,
      name: r'lyricsAlignment',
      type: IsarType.string,
    ),
    r'lyricsDarkness': PropertySchema(
      id: 29,
      name: r'lyricsDarkness',
      type: IsarType.double,
    ),
    r'musicDarkness': PropertySchema(
      id: 30,
      name: r'musicDarkness',
      type: IsarType.double,
    ),
    r'permanentAudioFocusChange': PropertySchema(
      id: 31,
      name: r'permanentAudioFocusChange',
      type: IsarType.bool,
    ),
    r'playPauseStopFadeLength': PropertySchema(
      id: 32,
      name: r'playPauseStopFadeLength',
      type: IsarType.long,
    ),
    r'repeatMode': PropertySchema(
      id: 33,
      name: r'repeatMode',
      type: IsarType.long,
    ),
    r'resumeAfterCall': PropertySchema(
      id: 34,
      name: r'resumeAfterCall',
      type: IsarType.bool,
    ),
    r'resumeOnStart': PropertySchema(
      id: 35,
      name: r'resumeOnStart',
      type: IsarType.bool,
    ),
    r'saveDynamicColor': PropertySchema(
      id: 36,
      name: r'saveDynamicColor',
      type: IsarType.bool,
    ),
    r'seekFadeLength': PropertySchema(
      id: 37,
      name: r'seekFadeLength',
      type: IsarType.long,
    ),
    r'settingsV2': PropertySchema(
      id: 38,
      name: r'settingsV2',
      type: IsarType.bool,
    ),
    r'shortManualCrossfadeLength': PropertySchema(
      id: 39,
      name: r'shortManualCrossfadeLength',
      type: IsarType.long,
    ),
    r'showHomeAlbums': PropertySchema(
      id: 40,
      name: r'showHomeAlbums',
      type: IsarType.bool,
    ),
    r'showHomeArtists': PropertySchema(
      id: 41,
      name: r'showHomeArtists',
      type: IsarType.bool,
    ),
    r'showHomeGenres': PropertySchema(
      id: 42,
      name: r'showHomeGenres',
      type: IsarType.bool,
    ),
    r'showPerformanceOptimizer': PropertySchema(
      id: 43,
      name: r'showPerformanceOptimizer',
      type: IsarType.bool,
    ),
    r'showQualityBadge': PropertySchema(
      id: 44,
      name: r'showQualityBadge',
      type: IsarType.bool,
    ),
    r'shuffle': PropertySchema(
      id: 45,
      name: r'shuffle',
      type: IsarType.bool,
    ),
    r'silenceBetweenTracks': PropertySchema(
      id: 46,
      name: r'silenceBetweenTracks',
      type: IsarType.long,
    ),
    r'songsDarkness': PropertySchema(
      id: 47,
      name: r'songsDarkness',
      type: IsarType.double,
    ),
    r'sortAscending': PropertySchema(
      id: 48,
      name: r'sortAscending',
      type: IsarType.bool,
    ),
    r'sortStrategyIndex': PropertySchema(
      id: 49,
      name: r'sortStrategyIndex',
      type: IsarType.long,
    ),
    r'stopOnTaskRemoved': PropertySchema(
      id: 50,
      name: r'stopOnTaskRemoved',
      type: IsarType.bool,
    ),
    r'volume': PropertySchema(
      id: 51,
      name: r'volume',
      type: IsarType.double,
    )
  },
  estimateSize: _appSettingsEstimateSize,
  serialize: _appSettingsSerialize,
  deserialize: _appSettingsDeserialize,
  deserializeProp: _appSettingsDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _appSettingsGetId,
  getLinks: _appSettingsGetLinks,
  attach: _appSettingsAttach,
  version: '3.1.0+1',
);

int _appSettingsEstimateSize(
  AppSettings object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.customBackgroundImagePath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.homeSectionOrder.length * 3;
  {
    for (var i = 0; i < object.homeSectionOrder.length; i++) {
      final value = object.homeSectionOrder[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.language.length * 3;
  bytesCount += 3 + object.libraryFolders.length * 3;
  {
    for (var i = 0; i < object.libraryFolders.length; i++) {
      final value = object.libraryFolders[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.lyricsAlignment.length * 3;
  return bytesCount;
}

void _appSettingsSerialize(
  AppSettings object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.accentColor);
  writer.writeBool(offsets[1], object.audioFocus);
  writer.writeDouble(offsets[2], object.bgBrightness);
  writer.writeDouble(offsets[3], object.bgOpacity);
  writer.writeLong(offsets[4], object.crossfadeLength);
  writer.writeString(offsets[5], object.customBackgroundImagePath);
  writer.writeBool(offsets[6], object.darkTheme);
  writer.writeBool(offsets[7], object.disableAnimatedDuration);
  writer.writeBool(offsets[8], object.disableBlur);
  writer.writeBool(offsets[9], object.disableSquiggle);
  writer.writeBool(offsets[10], object.downloadArtwork);
  writer.writeBool(offsets[11], object.dynamicAccentColor);
  writer.writeBool(offsets[12], object.dynamicColorActiveLyrics);
  writer.writeBool(offsets[13], object.dynamicLyrics);
  writer.writeBool(offsets[14], object.enableCrossfade);
  writer.writeBool(offsets[15], object.enableDynamicTheming);
  writer.writeBool(offsets[16], object.enableInternet);
  writer.writeBool(offsets[17], object.enablePlayerGradient);
  writer.writeBool(offsets[18], object.enableSlideGesture);
  writer.writeBool(offsets[19], object.fadeOnSeek);
  writer.writeBool(offsets[20], object.fadePlayPauseStop);
  writer.writeDouble(offsets[21], object.homeDarkness);
  writer.writeStringList(offsets[22], object.homeSectionOrder);
  writer.writeBool(offsets[23], object.keepBackgroundGradient);
  writer.writeString(offsets[24], object.language);
  writer.writeLong(offsets[25], object.lastPlayedSongId);
  writer.writeDouble(offsets[26], object.libraryDarkness);
  writer.writeStringList(offsets[27], object.libraryFolders);
  writer.writeString(offsets[28], object.lyricsAlignment);
  writer.writeDouble(offsets[29], object.lyricsDarkness);
  writer.writeDouble(offsets[30], object.musicDarkness);
  writer.writeBool(offsets[31], object.permanentAudioFocusChange);
  writer.writeLong(offsets[32], object.playPauseStopFadeLength);
  writer.writeLong(offsets[33], object.repeatMode);
  writer.writeBool(offsets[34], object.resumeAfterCall);
  writer.writeBool(offsets[35], object.resumeOnStart);
  writer.writeBool(offsets[36], object.saveDynamicColor);
  writer.writeLong(offsets[37], object.seekFadeLength);
  writer.writeBool(offsets[38], object.settingsV2);
  writer.writeLong(offsets[39], object.shortManualCrossfadeLength);
  writer.writeBool(offsets[40], object.showHomeAlbums);
  writer.writeBool(offsets[41], object.showHomeArtists);
  writer.writeBool(offsets[42], object.showHomeGenres);
  writer.writeBool(offsets[43], object.showPerformanceOptimizer);
  writer.writeBool(offsets[44], object.showQualityBadge);
  writer.writeBool(offsets[45], object.shuffle);
  writer.writeLong(offsets[46], object.silenceBetweenTracks);
  writer.writeDouble(offsets[47], object.songsDarkness);
  writer.writeBool(offsets[48], object.sortAscending);
  writer.writeLong(offsets[49], object.sortStrategyIndex);
  writer.writeBool(offsets[50], object.stopOnTaskRemoved);
  writer.writeDouble(offsets[51], object.volume);
}

AppSettings _appSettingsDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AppSettings();
  object.accentColor = reader.readLong(offsets[0]);
  object.audioFocus = reader.readBool(offsets[1]);
  object.bgBrightness = reader.readDouble(offsets[2]);
  object.bgOpacity = reader.readDouble(offsets[3]);
  object.crossfadeLength = reader.readLong(offsets[4]);
  object.customBackgroundImagePath = reader.readStringOrNull(offsets[5]);
  object.darkTheme = reader.readBool(offsets[6]);
  object.disableAnimatedDuration = reader.readBool(offsets[7]);
  object.disableBlur = reader.readBool(offsets[8]);
  object.disableSquiggle = reader.readBool(offsets[9]);
  object.downloadArtwork = reader.readBool(offsets[10]);
  object.dynamicAccentColor = reader.readBool(offsets[11]);
  object.dynamicColorActiveLyrics = reader.readBool(offsets[12]);
  object.dynamicLyrics = reader.readBool(offsets[13]);
  object.enableCrossfade = reader.readBool(offsets[14]);
  object.enableDynamicTheming = reader.readBool(offsets[15]);
  object.enableInternet = reader.readBool(offsets[16]);
  object.enablePlayerGradient = reader.readBool(offsets[17]);
  object.enableSlideGesture = reader.readBool(offsets[18]);
  object.fadeOnSeek = reader.readBool(offsets[19]);
  object.fadePlayPauseStop = reader.readBool(offsets[20]);
  object.homeDarkness = reader.readDouble(offsets[21]);
  object.homeSectionOrder = reader.readStringList(offsets[22]) ?? [];
  object.id = id;
  object.keepBackgroundGradient = reader.readBool(offsets[23]);
  object.language = reader.readString(offsets[24]);
  object.lastPlayedSongId = reader.readLongOrNull(offsets[25]);
  object.libraryDarkness = reader.readDouble(offsets[26]);
  object.libraryFolders = reader.readStringList(offsets[27]) ?? [];
  object.lyricsAlignment = reader.readString(offsets[28]);
  object.lyricsDarkness = reader.readDouble(offsets[29]);
  object.musicDarkness = reader.readDouble(offsets[30]);
  object.permanentAudioFocusChange = reader.readBool(offsets[31]);
  object.playPauseStopFadeLength = reader.readLong(offsets[32]);
  object.repeatMode = reader.readLong(offsets[33]);
  object.resumeAfterCall = reader.readBool(offsets[34]);
  object.resumeOnStart = reader.readBool(offsets[35]);
  object.saveDynamicColor = reader.readBool(offsets[36]);
  object.seekFadeLength = reader.readLong(offsets[37]);
  object.settingsV2 = reader.readBool(offsets[38]);
  object.shortManualCrossfadeLength = reader.readLong(offsets[39]);
  object.showHomeAlbums = reader.readBool(offsets[40]);
  object.showHomeArtists = reader.readBool(offsets[41]);
  object.showHomeGenres = reader.readBool(offsets[42]);
  object.showPerformanceOptimizer = reader.readBool(offsets[43]);
  object.showQualityBadge = reader.readBool(offsets[44]);
  object.shuffle = reader.readBool(offsets[45]);
  object.silenceBetweenTracks = reader.readLong(offsets[46]);
  object.songsDarkness = reader.readDouble(offsets[47]);
  object.sortAscending = reader.readBool(offsets[48]);
  object.sortStrategyIndex = reader.readLong(offsets[49]);
  object.stopOnTaskRemoved = reader.readBool(offsets[50]);
  object.volume = reader.readDouble(offsets[51]);
  return object;
}

P _appSettingsDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readBool(offset)) as P;
    case 10:
      return (reader.readBool(offset)) as P;
    case 11:
      return (reader.readBool(offset)) as P;
    case 12:
      return (reader.readBool(offset)) as P;
    case 13:
      return (reader.readBool(offset)) as P;
    case 14:
      return (reader.readBool(offset)) as P;
    case 15:
      return (reader.readBool(offset)) as P;
    case 16:
      return (reader.readBool(offset)) as P;
    case 17:
      return (reader.readBool(offset)) as P;
    case 18:
      return (reader.readBool(offset)) as P;
    case 19:
      return (reader.readBool(offset)) as P;
    case 20:
      return (reader.readBool(offset)) as P;
    case 21:
      return (reader.readDouble(offset)) as P;
    case 22:
      return (reader.readStringList(offset) ?? []) as P;
    case 23:
      return (reader.readBool(offset)) as P;
    case 24:
      return (reader.readString(offset)) as P;
    case 25:
      return (reader.readLongOrNull(offset)) as P;
    case 26:
      return (reader.readDouble(offset)) as P;
    case 27:
      return (reader.readStringList(offset) ?? []) as P;
    case 28:
      return (reader.readString(offset)) as P;
    case 29:
      return (reader.readDouble(offset)) as P;
    case 30:
      return (reader.readDouble(offset)) as P;
    case 31:
      return (reader.readBool(offset)) as P;
    case 32:
      return (reader.readLong(offset)) as P;
    case 33:
      return (reader.readLong(offset)) as P;
    case 34:
      return (reader.readBool(offset)) as P;
    case 35:
      return (reader.readBool(offset)) as P;
    case 36:
      return (reader.readBool(offset)) as P;
    case 37:
      return (reader.readLong(offset)) as P;
    case 38:
      return (reader.readBool(offset)) as P;
    case 39:
      return (reader.readLong(offset)) as P;
    case 40:
      return (reader.readBool(offset)) as P;
    case 41:
      return (reader.readBool(offset)) as P;
    case 42:
      return (reader.readBool(offset)) as P;
    case 43:
      return (reader.readBool(offset)) as P;
    case 44:
      return (reader.readBool(offset)) as P;
    case 45:
      return (reader.readBool(offset)) as P;
    case 46:
      return (reader.readLong(offset)) as P;
    case 47:
      return (reader.readDouble(offset)) as P;
    case 48:
      return (reader.readBool(offset)) as P;
    case 49:
      return (reader.readLong(offset)) as P;
    case 50:
      return (reader.readBool(offset)) as P;
    case 51:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _appSettingsGetId(AppSettings object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _appSettingsGetLinks(AppSettings object) {
  return [];
}

void _appSettingsAttach(
    IsarCollection<dynamic> col, Id id, AppSettings object) {
  object.id = id;
}

extension AppSettingsQueryWhereSort
    on QueryBuilder<AppSettings, AppSettings, QWhere> {
  QueryBuilder<AppSettings, AppSettings, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AppSettingsQueryWhere
    on QueryBuilder<AppSettings, AppSettings, QWhereClause> {
  QueryBuilder<AppSettings, AppSettings, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<AppSettings, AppSettings, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AppSettingsQueryFilter
    on QueryBuilder<AppSettings, AppSettings, QFilterCondition> {
  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      accentColorEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'accentColor',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      accentColorGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'accentColor',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      accentColorLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'accentColor',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      accentColorBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'accentColor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      audioFocusEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'audioFocus',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      bgBrightnessEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bgBrightness',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      bgBrightnessGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bgBrightness',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      bgBrightnessLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bgBrightness',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      bgBrightnessBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bgBrightness',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      bgOpacityEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bgOpacity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      bgOpacityGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bgOpacity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      bgOpacityLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bgOpacity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      bgOpacityBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bgOpacity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      crossfadeLengthEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'crossfadeLength',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      crossfadeLengthGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'crossfadeLength',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      crossfadeLengthLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'crossfadeLength',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      crossfadeLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'crossfadeLength',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customBackgroundImagePathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'customBackgroundImagePath',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customBackgroundImagePathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'customBackgroundImagePath',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customBackgroundImagePathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'customBackgroundImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customBackgroundImagePathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'customBackgroundImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customBackgroundImagePathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'customBackgroundImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customBackgroundImagePathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'customBackgroundImagePath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customBackgroundImagePathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'customBackgroundImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customBackgroundImagePathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'customBackgroundImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customBackgroundImagePathContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'customBackgroundImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customBackgroundImagePathMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'customBackgroundImagePath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customBackgroundImagePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'customBackgroundImagePath',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customBackgroundImagePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'customBackgroundImagePath',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      darkThemeEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'darkTheme',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      disableAnimatedDurationEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'disableAnimatedDuration',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      disableBlurEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'disableBlur',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      disableSquiggleEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'disableSquiggle',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      downloadArtworkEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'downloadArtwork',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      dynamicAccentColorEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dynamicAccentColor',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      dynamicColorActiveLyricsEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dynamicColorActiveLyrics',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      dynamicLyricsEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dynamicLyrics',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      enableCrossfadeEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'enableCrossfade',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      enableDynamicThemingEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'enableDynamicTheming',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      enableInternetEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'enableInternet',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      enablePlayerGradientEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'enablePlayerGradient',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      enableSlideGestureEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'enableSlideGesture',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      fadeOnSeekEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fadeOnSeek',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      fadePlayPauseStopEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fadePlayPauseStop',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      homeDarknessEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'homeDarkness',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      homeDarknessGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'homeDarkness',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      homeDarknessLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'homeDarkness',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      homeDarknessBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'homeDarkness',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      homeSectionOrderElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'homeSectionOrder',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      homeSectionOrderElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'homeSectionOrder',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      homeSectionOrderElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'homeSectionOrder',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      homeSectionOrderElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'homeSectionOrder',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      homeSectionOrderElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'homeSectionOrder',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      homeSectionOrderElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'homeSectionOrder',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      homeSectionOrderElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'homeSectionOrder',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      homeSectionOrderElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'homeSectionOrder',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      homeSectionOrderElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'homeSectionOrder',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      homeSectionOrderElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'homeSectionOrder',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      homeSectionOrderLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'homeSectionOrder',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      homeSectionOrderIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'homeSectionOrder',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      homeSectionOrderIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'homeSectionOrder',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      homeSectionOrderLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'homeSectionOrder',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      homeSectionOrderLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'homeSectionOrder',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      homeSectionOrderLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'homeSectionOrder',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      keepBackgroundGradientEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'keepBackgroundGradient',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition> languageEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      languageGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      languageLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition> languageBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'language',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      languageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      languageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      languageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition> languageMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'language',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      languageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'language',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      languageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'language',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastPlayedSongIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastPlayedSongId',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastPlayedSongIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastPlayedSongId',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastPlayedSongIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastPlayedSongId',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastPlayedSongIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastPlayedSongId',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastPlayedSongIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastPlayedSongId',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastPlayedSongIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastPlayedSongId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      libraryDarknessEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'libraryDarkness',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      libraryDarknessGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'libraryDarkness',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      libraryDarknessLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'libraryDarkness',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      libraryDarknessBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'libraryDarkness',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      libraryFoldersElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'libraryFolders',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      libraryFoldersElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'libraryFolders',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      libraryFoldersElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'libraryFolders',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      libraryFoldersElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'libraryFolders',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      libraryFoldersElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'libraryFolders',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      libraryFoldersElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'libraryFolders',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      libraryFoldersElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'libraryFolders',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      libraryFoldersElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'libraryFolders',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      libraryFoldersElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'libraryFolders',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      libraryFoldersElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'libraryFolders',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      libraryFoldersLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'libraryFolders',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      libraryFoldersIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'libraryFolders',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      libraryFoldersIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'libraryFolders',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      libraryFoldersLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'libraryFolders',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      libraryFoldersLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'libraryFolders',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      libraryFoldersLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'libraryFolders',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lyricsAlignmentEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lyricsAlignment',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lyricsAlignmentGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lyricsAlignment',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lyricsAlignmentLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lyricsAlignment',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lyricsAlignmentBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lyricsAlignment',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lyricsAlignmentStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lyricsAlignment',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lyricsAlignmentEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lyricsAlignment',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lyricsAlignmentContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lyricsAlignment',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lyricsAlignmentMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lyricsAlignment',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lyricsAlignmentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lyricsAlignment',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lyricsAlignmentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lyricsAlignment',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lyricsDarknessEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lyricsDarkness',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lyricsDarknessGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lyricsDarkness',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lyricsDarknessLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lyricsDarkness',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lyricsDarknessBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lyricsDarkness',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      musicDarknessEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'musicDarkness',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      musicDarknessGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'musicDarkness',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      musicDarknessLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'musicDarkness',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      musicDarknessBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'musicDarkness',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      permanentAudioFocusChangeEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'permanentAudioFocusChange',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      playPauseStopFadeLengthEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'playPauseStopFadeLength',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      playPauseStopFadeLengthGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'playPauseStopFadeLength',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      playPauseStopFadeLengthLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'playPauseStopFadeLength',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      playPauseStopFadeLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'playPauseStopFadeLength',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      repeatModeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'repeatMode',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      repeatModeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'repeatMode',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      repeatModeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'repeatMode',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      repeatModeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'repeatMode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      resumeAfterCallEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'resumeAfterCall',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      resumeOnStartEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'resumeOnStart',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      saveDynamicColorEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'saveDynamicColor',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      seekFadeLengthEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'seekFadeLength',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      seekFadeLengthGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'seekFadeLength',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      seekFadeLengthLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'seekFadeLength',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      seekFadeLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'seekFadeLength',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      settingsV2EqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'settingsV2',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      shortManualCrossfadeLengthEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'shortManualCrossfadeLength',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      shortManualCrossfadeLengthGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'shortManualCrossfadeLength',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      shortManualCrossfadeLengthLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'shortManualCrossfadeLength',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      shortManualCrossfadeLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'shortManualCrossfadeLength',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      showHomeAlbumsEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'showHomeAlbums',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      showHomeArtistsEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'showHomeArtists',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      showHomeGenresEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'showHomeGenres',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      showPerformanceOptimizerEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'showPerformanceOptimizer',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      showQualityBadgeEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'showQualityBadge',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition> shuffleEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'shuffle',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      silenceBetweenTracksEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'silenceBetweenTracks',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      silenceBetweenTracksGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'silenceBetweenTracks',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      silenceBetweenTracksLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'silenceBetweenTracks',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      silenceBetweenTracksBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'silenceBetweenTracks',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      songsDarknessEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'songsDarkness',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      songsDarknessGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'songsDarkness',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      songsDarknessLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'songsDarkness',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      songsDarknessBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'songsDarkness',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      sortAscendingEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sortAscending',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      sortStrategyIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sortStrategyIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      sortStrategyIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sortStrategyIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      sortStrategyIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sortStrategyIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      sortStrategyIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sortStrategyIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      stopOnTaskRemovedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stopOnTaskRemoved',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition> volumeEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'volume',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      volumeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'volume',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition> volumeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'volume',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition> volumeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'volume',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension AppSettingsQueryObject
    on QueryBuilder<AppSettings, AppSettings, QFilterCondition> {}

extension AppSettingsQueryLinks
    on QueryBuilder<AppSettings, AppSettings, QFilterCondition> {}

extension AppSettingsQuerySortBy
    on QueryBuilder<AppSettings, AppSettings, QSortBy> {
  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByAccentColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accentColor', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByAccentColorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accentColor', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByAudioFocus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioFocus', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByAudioFocusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioFocus', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByBgBrightness() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bgBrightness', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByBgBrightnessDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bgBrightness', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByBgOpacity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bgOpacity', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByBgOpacityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bgOpacity', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByCrossfadeLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'crossfadeLength', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByCrossfadeLengthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'crossfadeLength', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByCustomBackgroundImagePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customBackgroundImagePath', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByCustomBackgroundImagePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customBackgroundImagePath', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByDarkTheme() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'darkTheme', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByDarkThemeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'darkTheme', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByDisableAnimatedDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disableAnimatedDuration', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByDisableAnimatedDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disableAnimatedDuration', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByDisableBlur() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disableBlur', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByDisableBlurDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disableBlur', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByDisableSquiggle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disableSquiggle', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByDisableSquiggleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disableSquiggle', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByDownloadArtwork() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadArtwork', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByDownloadArtworkDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadArtwork', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByDynamicAccentColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dynamicAccentColor', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByDynamicAccentColorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dynamicAccentColor', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByDynamicColorActiveLyrics() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dynamicColorActiveLyrics', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByDynamicColorActiveLyricsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dynamicColorActiveLyrics', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByDynamicLyrics() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dynamicLyrics', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByDynamicLyricsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dynamicLyrics', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByEnableCrossfade() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableCrossfade', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByEnableCrossfadeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableCrossfade', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByEnableDynamicTheming() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableDynamicTheming', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByEnableDynamicThemingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableDynamicTheming', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByEnableInternet() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableInternet', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByEnableInternetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableInternet', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByEnablePlayerGradient() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enablePlayerGradient', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByEnablePlayerGradientDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enablePlayerGradient', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByEnableSlideGesture() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableSlideGesture', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByEnableSlideGestureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableSlideGesture', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByFadeOnSeek() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fadeOnSeek', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByFadeOnSeekDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fadeOnSeek', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByFadePlayPauseStop() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fadePlayPauseStop', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByFadePlayPauseStopDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fadePlayPauseStop', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByHomeDarkness() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'homeDarkness', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByHomeDarknessDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'homeDarkness', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByKeepBackgroundGradient() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'keepBackgroundGradient', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByKeepBackgroundGradientDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'keepBackgroundGradient', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByLanguage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByLanguageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByLastPlayedSongId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayedSongId', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByLastPlayedSongIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayedSongId', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByLibraryDarkness() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'libraryDarkness', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByLibraryDarknessDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'libraryDarkness', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByLyricsAlignment() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lyricsAlignment', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByLyricsAlignmentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lyricsAlignment', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByLyricsDarkness() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lyricsDarkness', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByLyricsDarknessDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lyricsDarkness', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByMusicDarkness() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'musicDarkness', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByMusicDarknessDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'musicDarkness', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByPermanentAudioFocusChange() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'permanentAudioFocusChange', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByPermanentAudioFocusChangeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'permanentAudioFocusChange', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByPlayPauseStopFadeLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playPauseStopFadeLength', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByPlayPauseStopFadeLengthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playPauseStopFadeLength', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByRepeatMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repeatMode', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByRepeatModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repeatMode', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByResumeAfterCall() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resumeAfterCall', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByResumeAfterCallDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resumeAfterCall', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByResumeOnStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resumeOnStart', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByResumeOnStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resumeOnStart', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortBySaveDynamicColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saveDynamicColor', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortBySaveDynamicColorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saveDynamicColor', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortBySeekFadeLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seekFadeLength', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortBySeekFadeLengthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seekFadeLength', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortBySettingsV2() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settingsV2', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortBySettingsV2Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settingsV2', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByShortManualCrossfadeLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shortManualCrossfadeLength', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByShortManualCrossfadeLengthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shortManualCrossfadeLength', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByShowHomeAlbums() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showHomeAlbums', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByShowHomeAlbumsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showHomeAlbums', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByShowHomeArtists() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showHomeArtists', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByShowHomeArtistsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showHomeArtists', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByShowHomeGenres() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showHomeGenres', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByShowHomeGenresDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showHomeGenres', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByShowPerformanceOptimizer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showPerformanceOptimizer', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByShowPerformanceOptimizerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showPerformanceOptimizer', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByShowQualityBadge() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showQualityBadge', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByShowQualityBadgeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showQualityBadge', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByShuffle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shuffle', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByShuffleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shuffle', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortBySilenceBetweenTracks() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'silenceBetweenTracks', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortBySilenceBetweenTracksDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'silenceBetweenTracks', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortBySongsDarkness() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'songsDarkness', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortBySongsDarknessDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'songsDarkness', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortBySortAscending() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortAscending', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortBySortAscendingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortAscending', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortBySortStrategyIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortStrategyIndex', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortBySortStrategyIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortStrategyIndex', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByStopOnTaskRemoved() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stopOnTaskRemoved', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByStopOnTaskRemovedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stopOnTaskRemoved', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByVolume() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'volume', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByVolumeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'volume', Sort.desc);
    });
  }
}

extension AppSettingsQuerySortThenBy
    on QueryBuilder<AppSettings, AppSettings, QSortThenBy> {
  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByAccentColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accentColor', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByAccentColorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accentColor', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByAudioFocus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioFocus', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByAudioFocusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioFocus', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByBgBrightness() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bgBrightness', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByBgBrightnessDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bgBrightness', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByBgOpacity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bgOpacity', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByBgOpacityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bgOpacity', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByCrossfadeLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'crossfadeLength', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByCrossfadeLengthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'crossfadeLength', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByCustomBackgroundImagePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customBackgroundImagePath', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByCustomBackgroundImagePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customBackgroundImagePath', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByDarkTheme() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'darkTheme', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByDarkThemeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'darkTheme', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByDisableAnimatedDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disableAnimatedDuration', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByDisableAnimatedDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disableAnimatedDuration', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByDisableBlur() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disableBlur', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByDisableBlurDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disableBlur', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByDisableSquiggle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disableSquiggle', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByDisableSquiggleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disableSquiggle', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByDownloadArtwork() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadArtwork', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByDownloadArtworkDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadArtwork', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByDynamicAccentColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dynamicAccentColor', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByDynamicAccentColorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dynamicAccentColor', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByDynamicColorActiveLyrics() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dynamicColorActiveLyrics', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByDynamicColorActiveLyricsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dynamicColorActiveLyrics', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByDynamicLyrics() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dynamicLyrics', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByDynamicLyricsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dynamicLyrics', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByEnableCrossfade() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableCrossfade', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByEnableCrossfadeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableCrossfade', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByEnableDynamicTheming() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableDynamicTheming', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByEnableDynamicThemingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableDynamicTheming', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByEnableInternet() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableInternet', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByEnableInternetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableInternet', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByEnablePlayerGradient() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enablePlayerGradient', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByEnablePlayerGradientDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enablePlayerGradient', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByEnableSlideGesture() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableSlideGesture', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByEnableSlideGestureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableSlideGesture', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByFadeOnSeek() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fadeOnSeek', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByFadeOnSeekDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fadeOnSeek', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByFadePlayPauseStop() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fadePlayPauseStop', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByFadePlayPauseStopDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fadePlayPauseStop', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByHomeDarkness() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'homeDarkness', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByHomeDarknessDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'homeDarkness', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByKeepBackgroundGradient() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'keepBackgroundGradient', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByKeepBackgroundGradientDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'keepBackgroundGradient', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByLanguage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByLanguageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByLastPlayedSongId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayedSongId', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByLastPlayedSongIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayedSongId', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByLibraryDarkness() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'libraryDarkness', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByLibraryDarknessDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'libraryDarkness', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByLyricsAlignment() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lyricsAlignment', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByLyricsAlignmentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lyricsAlignment', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByLyricsDarkness() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lyricsDarkness', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByLyricsDarknessDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lyricsDarkness', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByMusicDarkness() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'musicDarkness', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByMusicDarknessDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'musicDarkness', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByPermanentAudioFocusChange() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'permanentAudioFocusChange', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByPermanentAudioFocusChangeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'permanentAudioFocusChange', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByPlayPauseStopFadeLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playPauseStopFadeLength', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByPlayPauseStopFadeLengthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playPauseStopFadeLength', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByRepeatMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repeatMode', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByRepeatModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repeatMode', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByResumeAfterCall() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resumeAfterCall', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByResumeAfterCallDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resumeAfterCall', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByResumeOnStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resumeOnStart', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByResumeOnStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resumeOnStart', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenBySaveDynamicColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saveDynamicColor', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenBySaveDynamicColorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saveDynamicColor', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenBySeekFadeLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seekFadeLength', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenBySeekFadeLengthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seekFadeLength', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenBySettingsV2() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settingsV2', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenBySettingsV2Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settingsV2', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByShortManualCrossfadeLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shortManualCrossfadeLength', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByShortManualCrossfadeLengthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shortManualCrossfadeLength', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByShowHomeAlbums() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showHomeAlbums', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByShowHomeAlbumsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showHomeAlbums', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByShowHomeArtists() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showHomeArtists', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByShowHomeArtistsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showHomeArtists', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByShowHomeGenres() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showHomeGenres', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByShowHomeGenresDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showHomeGenres', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByShowPerformanceOptimizer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showPerformanceOptimizer', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByShowPerformanceOptimizerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showPerformanceOptimizer', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByShowQualityBadge() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showQualityBadge', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByShowQualityBadgeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showQualityBadge', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByShuffle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shuffle', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByShuffleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shuffle', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenBySilenceBetweenTracks() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'silenceBetweenTracks', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenBySilenceBetweenTracksDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'silenceBetweenTracks', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenBySongsDarkness() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'songsDarkness', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenBySongsDarknessDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'songsDarkness', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenBySortAscending() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortAscending', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenBySortAscendingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortAscending', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenBySortStrategyIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortStrategyIndex', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenBySortStrategyIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortStrategyIndex', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByStopOnTaskRemoved() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stopOnTaskRemoved', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByStopOnTaskRemovedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stopOnTaskRemoved', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByVolume() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'volume', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByVolumeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'volume', Sort.desc);
    });
  }
}

extension AppSettingsQueryWhereDistinct
    on QueryBuilder<AppSettings, AppSettings, QDistinct> {
  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByAccentColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'accentColor');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByAudioFocus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'audioFocus');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByBgBrightness() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bgBrightness');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByBgOpacity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bgOpacity');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByCrossfadeLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'crossfadeLength');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByCustomBackgroundImagePath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'customBackgroundImagePath',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByDarkTheme() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'darkTheme');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByDisableAnimatedDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'disableAnimatedDuration');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByDisableBlur() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'disableBlur');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByDisableSquiggle() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'disableSquiggle');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByDownloadArtwork() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'downloadArtwork');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByDynamicAccentColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dynamicAccentColor');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByDynamicColorActiveLyrics() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dynamicColorActiveLyrics');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByDynamicLyrics() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dynamicLyrics');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByEnableCrossfade() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'enableCrossfade');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByEnableDynamicTheming() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'enableDynamicTheming');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByEnableInternet() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'enableInternet');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByEnablePlayerGradient() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'enablePlayerGradient');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByEnableSlideGesture() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'enableSlideGesture');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByFadeOnSeek() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fadeOnSeek');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByFadePlayPauseStop() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fadePlayPauseStop');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByHomeDarkness() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'homeDarkness');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByHomeSectionOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'homeSectionOrder');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByKeepBackgroundGradient() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'keepBackgroundGradient');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByLanguage(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'language', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByLastPlayedSongId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastPlayedSongId');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByLibraryDarkness() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'libraryDarkness');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByLibraryFolders() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'libraryFolders');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByLyricsAlignment(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lyricsAlignment',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByLyricsDarkness() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lyricsDarkness');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByMusicDarkness() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'musicDarkness');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByPermanentAudioFocusChange() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'permanentAudioFocusChange');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByPlayPauseStopFadeLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'playPauseStopFadeLength');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByRepeatMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'repeatMode');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByResumeAfterCall() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'resumeAfterCall');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByResumeOnStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'resumeOnStart');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctBySaveDynamicColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'saveDynamicColor');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctBySeekFadeLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'seekFadeLength');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctBySettingsV2() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'settingsV2');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByShortManualCrossfadeLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'shortManualCrossfadeLength');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByShowHomeAlbums() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'showHomeAlbums');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByShowHomeArtists() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'showHomeArtists');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByShowHomeGenres() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'showHomeGenres');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByShowPerformanceOptimizer() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'showPerformanceOptimizer');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByShowQualityBadge() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'showQualityBadge');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByShuffle() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'shuffle');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctBySilenceBetweenTracks() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'silenceBetweenTracks');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctBySongsDarkness() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'songsDarkness');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctBySortAscending() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sortAscending');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctBySortStrategyIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sortStrategyIndex');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByStopOnTaskRemoved() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stopOnTaskRemoved');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByVolume() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'volume');
    });
  }
}

extension AppSettingsQueryProperty
    on QueryBuilder<AppSettings, AppSettings, QQueryProperty> {
  QueryBuilder<AppSettings, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AppSettings, int, QQueryOperations> accentColorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'accentColor');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> audioFocusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'audioFocus');
    });
  }

  QueryBuilder<AppSettings, double, QQueryOperations> bgBrightnessProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bgBrightness');
    });
  }

  QueryBuilder<AppSettings, double, QQueryOperations> bgOpacityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bgOpacity');
    });
  }

  QueryBuilder<AppSettings, int, QQueryOperations> crossfadeLengthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'crossfadeLength');
    });
  }

  QueryBuilder<AppSettings, String?, QQueryOperations>
      customBackgroundImagePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'customBackgroundImagePath');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> darkThemeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'darkTheme');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations>
      disableAnimatedDurationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'disableAnimatedDuration');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> disableBlurProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'disableBlur');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> disableSquiggleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'disableSquiggle');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> downloadArtworkProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'downloadArtwork');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations>
      dynamicAccentColorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dynamicAccentColor');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations>
      dynamicColorActiveLyricsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dynamicColorActiveLyrics');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> dynamicLyricsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dynamicLyrics');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> enableCrossfadeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'enableCrossfade');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations>
      enableDynamicThemingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'enableDynamicTheming');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> enableInternetProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'enableInternet');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations>
      enablePlayerGradientProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'enablePlayerGradient');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations>
      enableSlideGestureProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'enableSlideGesture');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> fadeOnSeekProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fadeOnSeek');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations>
      fadePlayPauseStopProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fadePlayPauseStop');
    });
  }

  QueryBuilder<AppSettings, double, QQueryOperations> homeDarknessProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'homeDarkness');
    });
  }

  QueryBuilder<AppSettings, List<String>, QQueryOperations>
      homeSectionOrderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'homeSectionOrder');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations>
      keepBackgroundGradientProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'keepBackgroundGradient');
    });
  }

  QueryBuilder<AppSettings, String, QQueryOperations> languageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'language');
    });
  }

  QueryBuilder<AppSettings, int?, QQueryOperations> lastPlayedSongIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastPlayedSongId');
    });
  }

  QueryBuilder<AppSettings, double, QQueryOperations>
      libraryDarknessProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'libraryDarkness');
    });
  }

  QueryBuilder<AppSettings, List<String>, QQueryOperations>
      libraryFoldersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'libraryFolders');
    });
  }

  QueryBuilder<AppSettings, String, QQueryOperations>
      lyricsAlignmentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lyricsAlignment');
    });
  }

  QueryBuilder<AppSettings, double, QQueryOperations> lyricsDarknessProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lyricsDarkness');
    });
  }

  QueryBuilder<AppSettings, double, QQueryOperations> musicDarknessProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'musicDarkness');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations>
      permanentAudioFocusChangeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'permanentAudioFocusChange');
    });
  }

  QueryBuilder<AppSettings, int, QQueryOperations>
      playPauseStopFadeLengthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'playPauseStopFadeLength');
    });
  }

  QueryBuilder<AppSettings, int, QQueryOperations> repeatModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'repeatMode');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> resumeAfterCallProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'resumeAfterCall');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> resumeOnStartProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'resumeOnStart');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> saveDynamicColorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'saveDynamicColor');
    });
  }

  QueryBuilder<AppSettings, int, QQueryOperations> seekFadeLengthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'seekFadeLength');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> settingsV2Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'settingsV2');
    });
  }

  QueryBuilder<AppSettings, int, QQueryOperations>
      shortManualCrossfadeLengthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'shortManualCrossfadeLength');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> showHomeAlbumsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'showHomeAlbums');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> showHomeArtistsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'showHomeArtists');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> showHomeGenresProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'showHomeGenres');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations>
      showPerformanceOptimizerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'showPerformanceOptimizer');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> showQualityBadgeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'showQualityBadge');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> shuffleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'shuffle');
    });
  }

  QueryBuilder<AppSettings, int, QQueryOperations>
      silenceBetweenTracksProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'silenceBetweenTracks');
    });
  }

  QueryBuilder<AppSettings, double, QQueryOperations> songsDarknessProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'songsDarkness');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> sortAscendingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sortAscending');
    });
  }

  QueryBuilder<AppSettings, int, QQueryOperations> sortStrategyIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sortStrategyIndex');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations>
      stopOnTaskRemovedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stopOnTaskRemoved');
    });
  }

  QueryBuilder<AppSettings, double, QQueryOperations> volumeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'volume');
    });
  }
}
