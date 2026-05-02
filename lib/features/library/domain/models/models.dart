import 'package:isar/isar.dart';

part 'models.g.dart';

@collection
class Song {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String path;

  late String title;
  
  @Index()
  String? artist;
  
  @Index()
  String? album;
  
  String? genre;
  int? duration; // In milliseconds
  int? trackNumber;
  int? year;
  String? artPath;
  
  @Index()
  late DateTime dateAdded;
  
  int playCount = 0;
  DateTime? lastPlayed;
  bool isFavorite = false;

  // Metadata for search
  @Index(type: IndexType.value, caseSensitive: false)
  List<String> get searchTerms => [
    title,
    if (artist != null) artist!,
    if (album != null) album!,
  ];
}

@collection
class Album {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String name;
  
  String? artist;
  String? artPath;
  int? year;
  
  @Index()
  late DateTime dateAdded;
}

@collection
class Artist {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String name;
  
  String? artPath;
  String? artistImageUrl;
}

@collection
class Playlist {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String name;
  
  late List<String> songPaths;
  late DateTime dateCreated;
  late DateTime dateModified;
}

@collection
class AppSettings {
  Id id = 0; // Always use ID 0 for single settings object

  List<String> libraryFolders = [];
  int? lastPlayedSongId;
  double volume = 1.0;
  bool shuffle = false;
  int repeatMode = 0; // 0: off, 1: one, 2: all
  String language = 'en';
}
