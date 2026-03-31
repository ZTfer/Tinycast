import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import '../../../data/database/isar_service.dart';
import '../../../data/models/podcast_model.dart' as model;
import '../../../core/utils/logger.dart';

class DatabaseFixPage extends ConsumerWidget {
  const DatabaseFixPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('数据库修复工具'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '数据库修复工具',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              '此工具将修复数据库中的播客数据：\n'
              '1. 为所有播客设置正确的 ID\n'
              '2. 将 isSubscribed 设置为 true\n'
              '3. 设置 subscribedAt 时间',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _fixDatabase(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF000000),
                foregroundColor: const Color(0xFFFFFFFF),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('修复数据库'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showDatabaseStatus(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('查看数据库状态'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _fixDatabase(BuildContext context) async {
    try {
      Logger.info('开始修复数据库');
      
      final isar = IsarService.instance.isar;
      
      await isar.writeTxn(() async {
        final allPodcasts = await isar.podcasts.where().findAll();
        
        Logger.info('找到 ${allPodcasts.length} 个播客');
        
        for (var podcast in allPodcasts) {
          final oldId = podcast.id;
          
          if (podcast.id == -9223372036854775808 || !podcast.isSubscribed) {
            Logger.info('修复播客: ${podcast.title}, 旧ID: $oldId');
            
            podcast.isSubscribed = true;
            podcast.subscribedAt ??= DateTime.now();
            
            if (podcast.id == -9223372036854775808) {
              podcast.id = Isar.autoIncrement;
              await isar.podcasts.delete(oldId);
            }
            
            final newId = await isar.podcasts.put(podcast);
            Logger.info('修复完成，新ID: $newId');
          }
        }
      });
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('数据库修复成功！')),
        );
      }
      
      Logger.info('数据库修复完成');
    } catch (e, stackTrace) {
      Logger.error('修复数据库失败', error: e, stackTrace: stackTrace);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('修复失败: $e')),
        );
      }
    }
  }

  Future<void> _showDatabaseStatus(BuildContext context) async {
    try {
      final isar = IsarService.instance.isar;
      final allPodcasts = await isar.podcasts.where().findAll();
      
      final buffer = StringBuffer();
      buffer.writeln('数据库状态:');
      buffer.writeln('总播客数: ${allPodcasts.length}');
      buffer.writeln('');
      
      for (final p in allPodcasts) {
        buffer.writeln('播客: ${p.title}');
        buffer.writeln('  ID: ${p.id}');
        buffer.writeln('  isSubscribed: ${p.isSubscribed}');
        buffer.writeln('  subscribedAt: ${p.subscribedAt}');
        buffer.writeln('');
      }
      
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('数据库状态'),
            content: SingleChildScrollView(
              child: Text(buffer.toString()),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('关闭'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('查询失败: $e')),
        );
      }
    }
  }
}
