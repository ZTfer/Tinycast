import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tinycast/data/database/isar_service.dart';
import 'package:tinycast/data/models/episode_model.dart';
import 'package:tinycast/data/services/audio_download_service.dart';
import 'package:tinycast/data/services/file_storage_service.dart';

import '../../helpers/isar_test_env.dart';

typedef _FetchHandler =
    Future<ResponseBody> Function(
      RequestOptions options,
      Future<void>? cancelFuture,
    );

class _FakeHttpClientAdapter implements HttpClientAdapter {
  _FakeHttpClientAdapter(this._handler);

  final _FetchHandler _handler;
  final List<RequestOptions> requests = [];

  int get callCount => requests.length;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    requests.add(options);
    return _handler(options, cancelFuture);
  }

  @override
  void close({bool force = false}) {}
}

Future<void> _waitFor(
  bool Function() condition, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) {
      fail('Timed out waiting for condition');
    }
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
}

String? _header(RequestOptions options, String name) {
  final value = options.headers[name] ?? options.headers[name.toLowerCase()];
  return value?.toString();
}

void main() {
  late IsarTestEnv env;
  late Directory rootDir;
  late Directory supportDir;
  late Directory tempDir;
  late FileStorageService fileStorage;

  setUpAll(() async {
    await initializeIsarCoreForTests();
  });

  setUp(() async {
    env = await IsarTestEnv.open();
    rootDir = await Directory.systemTemp.createTemp('tinycast_download_test');
    supportDir = Directory('${rootDir.path}/support')
      ..createSync(recursive: true);
    tempDir = Directory('${rootDir.path}/tmp')..createSync(recursive: true);
    fileStorage = FileStorageService.forTesting(
      supportDirectoryResolver: () async => supportDir,
      temporaryDirectoryResolver: () async => tempDir,
    );
  });

  tearDown(() async {
    await env.close();
    if (await rootDir.exists()) {
      await rootDir.delete(recursive: true);
    }
  });

  Future<Episode> seedEpisode({int podcastId = 1}) async {
    final now = DateTime.now();
    final episode = Episode()
      ..podcastId = podcastId
      ..title = 'Episode'
      ..description = ''
      ..pubDate = now
      ..audioUrl = 'https://example.test/audio.mp3'
      ..audioType = 'audio/mpeg'
      ..isExplicit = false
      ..isPlayed = false
      ..isDownloaded = false
      ..downloadProgress = 0.0
      ..playProgress = 0.0
      ..createdAt = now
      ..updatedAt = now;
    episode.id = await env.isar.writeTxn(
      () => env.isar.episodes.put(episode),
    );
    return episode;
  }

  AudioDownloadService buildService(HttpClientAdapter adapter) {
    final dio = Dio();
    dio.httpClientAdapter = adapter;
    return AudioDownloadService.forTesting(
      isarService: IsarService.forTesting(env.isar),
      fileStorageService: fileStorage,
      dio: dio,
    );
  }

  group('文件名与已下载检查', () {
    test('音频文件名对同一 episode 稳定，重试不会产生孤儿分片', () {
      final first = fileStorage.generateAudioFileName('42');

      expect(fileStorage.generateAudioFileName('42'), first);
      expect(fileStorage.generateAudioFileName('43'), isNot(first));
      expect(
        first,
        matches(
          RegExp(
            r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\.mp3$',
          ),
        ),
      );
    });

    test('已存在下载文件时直接标记完成且不发起网络请求', () async {
      final episode = await seedEpisode();
      final episodeId = '${episode.id}';
      final fileName = fileStorage.generateAudioFileName(episodeId);
      final audioDir = await fileStorage.getAudioDirectory();
      await File('${audioDir.path}/$fileName').writeAsBytes([1, 2, 3]);

      await env.isar.writeTxn(() async {
        final stored = (await env.isar.episodes.get(episode.id))!;
        stored.isDownloaded = true;
        stored.downloadedPath = 'audio/$fileName';
        stored.downloadProgress = 1.0;
        await env.isar.episodes.put(stored);
      });

      final adapter = _FakeHttpClientAdapter(
        (_, _) async => throw StateError('network must not be used'),
      );
      final service = buildService(adapter);
      final statuses = <DownloadStatus>[];
      final subscription = service.globalEventStream.listen(
        (event) => statuses.add(event.status),
      );

      await service.downloadEpisodeById(episode.id);

      expect(adapter.callCount, 0);
      expect(statuses, contains(DownloadStatus.completed));
      final stored = await env.isar.episodes.get(episode.id);
      expect(stored!.isDownloaded, isTrue);
      expect(stored.downloadedPath, 'audio/$fileName');
      expect(stored.downloadProgress, 1.0);

      await subscription.cancel();
    });
  });

  group('并发控制', () {
    test('直接下载走队列，并发数不超过上限', () async {
      final episodes = <Episode>[];
      for (var i = 0; i < 4; i++) {
        episodes.add(await seedEpisode());
      }
      final controllers = <StreamController<Uint8List>>[];
      final adapter = _FakeHttpClientAdapter((options, cancelFuture) async {
        final controller = StreamController<Uint8List>();
        controllers.add(controller);
        return ResponseBody(
          controller.stream,
          200,
          headers: {
            'content-length': ['1'],
          },
        );
      });
      final service = buildService(adapter);

      final downloads = [
        for (final episode in episodes) service.downloadEpisode(episode),
      ];

      await _waitFor(() => controllers.length == 3);
      expect(adapter.callCount, equals(3));

      controllers[0].add(Uint8List.fromList([1]));
      await controllers[0].close();
      await _waitFor(() => controllers.length == 4);
      expect(adapter.callCount, equals(4));

      for (var i = 1; i < controllers.length; i++) {
        controllers[i].add(Uint8List.fromList([1]));
        await controllers[i].close();
      }
      await Future.wait(downloads);

      expect(service.getActiveDownloadsCount(), equals(0));
      expect(service.getQueueLength(), equals(0));
    });
  });

  group('暂停、恢复与取消', () {
    test('暂停后状态保持 paused，恢复时用 Range 续传同一临时文件', () async {
      final episode = await seedEpisode();
      final episodeId = '${episode.id}';
      final fileName = fileStorage.generateAudioFileName(episodeId);
      final contents = List<int>.generate(8, (index) => index);
      final firstChunks = StreamController<Uint8List>();
      late _FakeHttpClientAdapter adapter;

      adapter = _FakeHttpClientAdapter((options, cancelFuture) async {
        if (adapter.callCount == 1) {
          cancelFuture?.whenComplete(() {
            if (!firstChunks.isClosed) {
              firstChunks.close();
            }
          });
          return ResponseBody(
            firstChunks.stream,
            200,
            headers: {
              'content-length': ['8'],
            },
          );
        }
        return ResponseBody(
          Stream.value(Uint8List.fromList(contents.sublist(4))),
          206,
          headers: {
            'content-length': ['4'],
            'content-range': ['bytes 4-7/8'],
          },
        );
      });

      final service = buildService(adapter);
      final progress = <double>[];
      final progressSubscription = service
          .getDownloadProgressStream(episodeId)
          .listen(progress.add);
      final statuses = <DownloadStatus>[];
      final statusSubscription = service.globalEventStream.listen(
        (event) => statuses.add(event.status),
      );

      final download = service.downloadEpisode(episode);
      firstChunks.add(Uint8List.fromList(contents.sublist(0, 4)));
      await _waitFor(() => progress.isNotEmpty);

      await service.pauseDownload(episodeId);
      await download;

      expect(service.getDownloadStatus(episodeId), DownloadStatus.paused);
      final tempFile = File('${tempDir.path}/$fileName');
      expect(await tempFile.exists(), isTrue);
      expect(await tempFile.readAsBytes(), contents.sublist(0, 4));

      await service.resumeDownload(episodeId);

      expect(_header(adapter.requests[1], 'Range'), 'bytes=4-');
      final audioDir = await fileStorage.getAudioDirectory();
      final finalFile = File('${audioDir.path}/$fileName');
      expect(await finalFile.exists(), isTrue);
      expect(await finalFile.readAsBytes(), contents);
      expect(await tempFile.exists(), isFalse);
      expect(service.getDownloadStatus(episodeId), isNull);

      final stored = await env.isar.episodes.get(episode.id);
      expect(stored!.isDownloaded, isTrue);
      expect(stored.downloadedPath, 'audio/$fileName');
      expect(
        statuses,
        containsAll([
          DownloadStatus.downloading,
          DownloadStatus.paused,
          DownloadStatus.completed,
        ]),
      );

      await progressSubscription.cancel();
      await statusSubscription.cancel();
    });

    test('取消下载会删除临时分片并清理内存任务', () async {
      final episode = await seedEpisode();
      final episodeId = '${episode.id}';
      final fileName = fileStorage.generateAudioFileName(episodeId);
      final chunks = StreamController<Uint8List>();
      late _FakeHttpClientAdapter adapter;

      adapter = _FakeHttpClientAdapter((options, cancelFuture) async {
        cancelFuture?.whenComplete(() {
          if (!chunks.isClosed) {
            chunks.close();
          }
        });
        return ResponseBody(
          chunks.stream,
          200,
          headers: {
            'content-length': ['8'],
          },
        );
      });

      final service = buildService(adapter);
      final progress = <double>[];
      final progressSubscription = service
          .getDownloadProgressStream(episodeId)
          .listen(progress.add);
      final statuses = <DownloadStatus>[];
      final statusSubscription = service.globalEventStream.listen(
        (event) => statuses.add(event.status),
      );

      final download = service.downloadEpisode(episode);
      chunks.add(Uint8List.fromList([1, 2, 3, 4]));
      await _waitFor(() => progress.isNotEmpty);

      await service.cancelDownload(episodeId);
      await download;

      expect(service.getDownloadStatus(episodeId), isNull);
      expect(await File('${tempDir.path}/$fileName').exists(), isFalse);
      expect(statuses, contains(DownloadStatus.cancelled));
      final stored = await env.isar.episodes.get(episode.id);
      expect(stored!.isDownloaded, isFalse);

      await progressSubscription.cancel();
      await statusSubscription.cancel();
    });
  });

  group('失败重试', () {
    test('失败保留分片，重试从同一文件断点续传并最终完成', () async {
      final episode = await seedEpisode();
      final episodeId = '${episode.id}';
      final fileName = fileStorage.generateAudioFileName(episodeId);
      final contents = List<int>.generate(8, (index) => index);
      final firstChunks = StreamController<Uint8List>();
      late _FakeHttpClientAdapter adapter;

      adapter = _FakeHttpClientAdapter((options, cancelFuture) async {
        if (adapter.callCount == 1) {
          scheduleMicrotask(() {
            firstChunks.add(Uint8List.fromList(contents.sublist(0, 4)));
            scheduleMicrotask(() {
              firstChunks.addError(
                DioException(
                  requestOptions: options,
                  type: DioExceptionType.connectionError,
                  message: 'connection lost',
                ),
              );
              firstChunks.close();
            });
          });
          return ResponseBody(
            firstChunks.stream,
            200,
            headers: {
              'content-length': ['8'],
            },
          );
        }
        return ResponseBody(
          Stream.value(Uint8List.fromList(contents.sublist(4))),
          206,
          headers: {
            'content-length': ['4'],
            'content-range': ['bytes 4-7/8'],
          },
        );
      });

      final service = buildService(adapter);
      final statuses = <DownloadStatus>[];
      final statusSubscription = service.globalEventStream.listen(
        (event) => statuses.add(event.status),
      );

      await service.downloadEpisode(episode);

      await _waitFor(() => statuses.contains(DownloadStatus.failed));
      expect(service.getDownloadStatus(episodeId), isNull);
      final tempFile = File('${tempDir.path}/$fileName');
      expect(await tempFile.exists(), isTrue);
      expect(await tempFile.readAsBytes(), contents.sublist(0, 4));

      await service.downloadEpisode(episode);

      expect(_header(adapter.requests[1], 'Range'), 'bytes=4-');
      final audioDir = await fileStorage.getAudioDirectory();
      final finalFile = File('${audioDir.path}/$fileName');
      expect(await finalFile.readAsBytes(), contents);
      expect(await tempFile.exists(), isFalse);
      final stored = await env.isar.episodes.get(episode.id);
      expect(stored!.isDownloaded, isTrue);

      await statusSubscription.cancel();
    });
  });

  group('退订清理', () {
    test('退订播客会取消进行中的下载并删除临时文件', () async {
      final downloadingEpisode = await seedEpisode(podcastId: 7);
      final downloadingId = '${downloadingEpisode.id}';
      final fileName = fileStorage.generateAudioFileName(downloadingId);
      final chunks = StreamController<Uint8List>();
      late _FakeHttpClientAdapter adapter;

      adapter = _FakeHttpClientAdapter((options, cancelFuture) async {
        cancelFuture?.whenComplete(() {
          if (!chunks.isClosed) {
            chunks.close();
          }
        });
        return ResponseBody(
          chunks.stream,
          200,
          headers: {
            'content-length': ['8'],
          },
        );
      });

      final service = buildService(adapter);
      final progress = <double>[];
      final progressSubscription = service
          .getDownloadProgressStream(downloadingId)
          .listen(progress.add);
      final statuses = <DownloadStatus>[];
      final statusSubscription = service.globalEventStream.listen(
        (event) => statuses.add(event.status),
      );

      final download = service.downloadEpisode(downloadingEpisode);
      chunks.add(Uint8List.fromList([1, 2, 3, 4]));
      await _waitFor(() => progress.isNotEmpty);

      final downloadedEpisode = await seedEpisode(podcastId: 7);
      final audioDir = await fileStorage.getAudioDirectory();
      final audioFile = File('${audioDir.path}/old.mp3')..writeAsBytesSync([9]);
      final imagesDir = await fileStorage.getImagesDirectory();
      final artworkFile = File('${imagesDir.path}/old.jpg')
        ..writeAsBytesSync([8]);
      await env.isar.writeTxn(() async {
        final stored = (await env.isar.episodes.get(downloadedEpisode.id))!;
        stored.isDownloaded = true;
        stored.downloadedPath = 'audio/old.mp3';
        stored.artworkPath = 'images/old.jpg';
        await env.isar.episodes.put(stored);
      });

      await service.unfollowPodcast(7);
      await download;

      expect(statuses, contains(DownloadStatus.cancelled));
      expect(service.getDownloadStatus(downloadingId), isNull);
      expect(await File('${tempDir.path}/$fileName').exists(), isFalse);
      expect(await audioFile.exists(), isFalse);
      expect(await artworkFile.exists(), isFalse);

      await progressSubscription.cancel();
      await statusSubscription.cancel();
    });
  });
}
