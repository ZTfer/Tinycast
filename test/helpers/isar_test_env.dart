import 'dart:ffi';
import 'dart:io';

import 'package:isar_community/isar.dart';
import 'package:tinycast/data/models/app_settings_model.dart';
import 'package:tinycast/data/models/episode_model.dart';
import 'package:tinycast/data/models/favorite_model.dart';
import 'package:tinycast/data/models/play_history_model.dart';
import 'package:tinycast/data/models/podcast_model.dart';
import 'package:tinycast/data/models/queue_model.dart';
import 'package:tinycast/data/models/search_history_model.dart';

/// Initializes the Isar core binary for Dart VM tests.
///
/// Flutter tests run on the Dart VM without the platform embedding, so the
/// native library shipped by `isar_community_flutter_libs` is loaded manually
/// from the pub cache. Calling this more than once is a no-op.
Future<void> initializeIsarCoreForTests() async {
  final home = Platform.environment['HOME'] ?? '';
  final pubCache = Platform.environment['PUB_CACHE'] ?? '$home/.pub-cache';
  final hostedDir = Directory('$pubCache/hosted/pub.dev');
  if (!hostedDir.existsSync()) {
    throw StateError('Pub cache not found at ${hostedDir.path}');
  }

  // The native core must match the resolved Dart package exactly; picking the
  // highest cached version breaks whenever another version is also cached.
  final libDir = Directory(
    '${hostedDir.path}/isar_community_flutter_libs-${Isar.version}',
  );
  if (!libDir.existsSync()) {
    throw StateError(
      'isar_community_flutter_libs ${Isar.version} not found in pub cache; '
      'run flutter pub get first',
    );
  }

  final libraryFile = File(
    '${libDir.path}/${_libraryPathFor(Abi.current())}',
  );
  if (!libraryFile.existsSync()) {
    throw StateError('Isar core binary not found at ${libraryFile.path}');
  }

  await Isar.initializeIsarCore(
    libraries: {Abi.current(): libraryFile.path},
  );
}

String _libraryPathFor(Abi abi) {
  switch (abi) {
    case Abi.macosArm64:
    case Abi.macosX64:
      return 'macos/libisar.dylib';
    case Abi.linuxX64:
    case Abi.linuxArm64:
      return 'linux/libisar.so';
    case Abi.windowsX64:
    case Abi.windowsArm64:
      return 'windows/libisar.dll';
    default:
      throw UnsupportedError('Unsupported ABI for Isar tests: $abi');
  }
}

/// A throwaway Isar database backed by a unique temp directory.
///
/// Tests use a real database instance so merge/push code paths exercise the
/// actual Isar schema. Dispose with [close] to release the file handles.
class IsarTestEnv {
  IsarTestEnv._(this.isar, this._tempDir);

  final Isar isar;
  final Directory _tempDir;

  /// Opens a fresh database with all TinyCast schemas registered.
  static Future<IsarTestEnv> open() async {
    final tempDir = await Directory.systemTemp.createTemp('tinycast_isar_test');
    final isar = await Isar.open(
      [
        PodcastSchema,
        EpisodeSchema,
        SearchHistoryModelSchema,
        FavoriteSchema,
        PlayHistorySchema,
        QueueSchema,
        AppSettingsModelSchema,
      ],
      directory: tempDir.path,
      name: 'test-${DateTime.now().microsecondsSinceEpoch}',
      inspector: false,
    );
    return IsarTestEnv._(isar, tempDir);
  }

  Future<void> close() async {
    await isar.close();
    await _tempDir.delete(recursive: true);
  }
}
