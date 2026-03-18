import 'dart:io';

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

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
        schemas ?? [],
        directory: dir.path,
        name: _databaseName,
        inspector: true,
      );
      
      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to open Isar database: $e');
    }
  }

  Future<void> close() async {
    if (!_isInitialized || _isar == null) {
      return;
    }

    await _isar!.close();
    _isInitialized = false;
    _isar = null;
  }

  Future<void> clearAll() async {
    if (!_isInitialized || _isar == null) {
      throw StateError('Isar database is not initialized.');
    }

    await _isar!.writeTxn(() async {
      await _isar!.clear();
    });
  }

  Future<void> deleteDatabase() async {
    await close();
    
    final dir = await getApplicationDocumentsDirectory();
    final dbFile = File('${dir.path}/$_databaseName.isar');
    
    if (await dbFile.exists()) {
      await dbFile.delete();
    }
  }

  static int get currentVersion => _currentVersion;
}
