import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tinycast/data/datasources/remote_sync_datasource.dart';

/// RemoteSyncDataSource 与真实 Supabase 环境的集成验证。
///
/// `flutter test` 全量默认只扫描 test/ 目录，本文件不参与全量测试；
/// 需要验证云端通信时以显式路径运行（VM 测试，无需设备）：
///
/// ```sh
/// SUPABASE_URL=https://your-project-id.supabase.co \
/// SUPABASE_ANON_KEY=your-anon-key-here \
/// flutter test integration/remote_sync_datasource_integration_test.dart
/// ```
///
/// 凭据约定与 [docs/supabase_setup.md] 一致；未配置时用例被跳过并说明原因。
/// 注意：若项目的 RLS 策略限制匿名写入 podcasts 表，测试会以真实的
/// Supabase 错误失败——这本身就是集成验证的一部分。
void main() {
  final supabaseUrl = Platform.environment['SUPABASE_URL'];
  final supabaseAnonKey = Platform.environment['SUPABASE_ANON_KEY'];
  final hasCredentials =
      supabaseUrl != null && supabaseUrl.isNotEmpty && supabaseAnonKey != null && supabaseAnonKey.isNotEmpty;
  const skipReason =
      '需要 SUPABASE_URL 与 SUPABASE_ANON_KEY 环境变量（见 docs/supabase_setup.md）';

  group('RemoteSyncDataSource 与真实 Supabase 通信', () {
    // 无凭据时用例被 skip，但 group 级钩子仍会执行，因此钩子内部
    // 需要容忍未初始化状态。
    SupabaseClient? client;
    RemoteSyncDataSource? dataSource;
    late String itunesId;

    setUpAll(() {
      if (!hasCredentials) return;
      // hasCredentials 的定义保证了两个凭据非空（流分析可据此提升）。
      client = SupabaseClient(supabaseUrl, supabaseAnonKey);
      // 通过构造注入边界提供客户端，避免依赖 SupabaseService 全局单例。
      dataSource = RemoteSyncDataSource(clientResolver: () => client!);
    });

    setUp(() {
      itunesId =
          'tinycast-integration-test-${DateTime.now().microsecondsSinceEpoch}';
    });

    tearDownAll(() async {
      await client?.dispose();
    });

    // 无论断言结果如何，都尽量清理本用例写入的测试数据。
    tearDown(() async {
      try {
        await client?.from('podcasts').delete().eq('itunes_id', itunesId);
      } catch (_) {
        // 清理失败不影响测试结论（可能 RLS 拒绝了写入，无数据可删）。
      }
    });

    test('upsert 播客后能按 itunes_id 查询到同一记录', () async {
      // setUpAll 仅在凭据存在时初始化；用例也只在有凭据时运行到此处。
      final source = dataSource;
      if (source == null) {
        fail('凭据已配置时数据源应已初始化');
      }
      final podcastMap = <String, dynamic>{
        'itunes_id': itunesId,
        'title': 'TinyCast Integration Test',
        'author': 'tinycast-test',
        'description': 'RemoteSyncDataSource integration test fixture',
        'updated_at': DateTime.now().toIso8601String(),
      };

      final upserted = await source.upsertPodcasts([podcastMap]);
      expect(upserted, hasLength(1));
      expect(upserted.first['itunes_id'], equals(itunesId));
      // Supabase 分配的服务端主键应回填在返回行中。
      expect(upserted.first['id'], isNotNull);

      final fetched = await source.fetchPodcastByItunesId(itunesId);
      expect(fetched, isNotNull);
      expect(fetched!['title'], equals('TinyCast Integration Test'));
      expect(fetched['author'], equals('tinycast-test'));
    }, skip: hasCredentials ? false : skipReason);
  });
}
