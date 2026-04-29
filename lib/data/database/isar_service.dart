import 'dart:io';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tinycast/data/models/podcast_model.dart';
import 'package:tinycast/data/models/episode_model.dart';
import 'package:tinycast/data/models/search_history_model.dart';
import 'package:tinycast/data/models/favorite_model.dart';
import 'package:tinycast/data/models/play_history_model.dart';
import 'package:tinycast/data/models/queue_model.dart';
import 'package:tinycast/data/models/app_settings_model.dart';

class IsarService {
  static IsarService? _instance;
  static const String _databaseName = 'tinycast';
  static const int _currentVersion = 1;

  Isar? _isar;
  bool _isInitialized = false;

  IsarService._internal();

  static IsarService get instance {
    _instance ??= IsarService._internal();
    return _instance!;
  }

  bool get isInitialized => _isInitialized;

  Isar get isar {
    if (!_isInitialized || _isar == null) {
      throw StateError('Isar database is not initialized. Call open() first.');
    }
    return _isar!;
  }

  Future<void> open({List<CollectionSchema>? schemas}) async {
    if (_isInitialized) {
      return;
    }

    try {
      final dir = await getApplicationDocumentsDirectory();

      _isar = await Isar.open(
        [PodcastSchema, EpisodeSchema, SearchHistoryModelSchema, FavoriteSchema, PlayHistorySchema, QueueSchema, AppSettingsModelSchema],
        directory: dir.path,
        name: _databaseName,
        inspector: true,
      );

      _isInitialized = true;
    } on FileSystemException catch (e) {
      throw Exception('Failed to access database directory: $e');
    } catch (e) {
      throw Exception('Failed to open Isar database: $e');
    }
  }

  Future<void> close() async {
    if (!_isInitialized || _isar == null) {
      return;
    }

    try {
      await _isar!.close();
      _isInitialized = false;
      _isar = null;
    } catch (e) {
      throw Exception('Failed to close Isar database: $e');
    }
  }

  Future<void> clearAll() async {
    if (!_isInitialized || _isar == null) {
      throw StateError('Isar database is not initialized.');
    }

    try {
      await _isar!.writeTxn(() async {
        await _isar!.clear();
      });
    } catch (e) {
      throw Exception('Failed to clear database: $e');
    }
  }

  Future<void> deleteDatabase() async {
    try {
      await close();

      final dir = await getApplicationDocumentsDirectory();
      final dbFile = File('${dir.path}/$_databaseName.isar');

      if (await dbFile.exists()) {
        await dbFile.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete database: $e');
    }
  }

  static int get currentVersion => _currentVersion;
}
