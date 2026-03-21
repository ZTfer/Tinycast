import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/database/isar_service.dart';
import '../../../data/models/podcast_model.dart' as model;
import '../../../data/models/episode_model.dart' as model;

class DatabaseDebugPage extends ConsumerWidget {
  const DatabaseDebugPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('数据库调试'),
      ),
      body: FutureBuilder(
        future: _loadAllData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('错误: ${snapshot.error}'));
          }

          final data = snapshot.data as Map<String, dynamic>;
          final allPodcasts = data['allPodcasts'] as List<model.Podcast>;
          final subscribedPodcasts = data['subscribedPodcasts'] as List<model.Podcast>;
          final allEpisodes = data['allEpisodes'] as List<model.Episode>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '所有播客 (${allPodcasts.length})',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...allPodcasts.map((p) => Card(
                  child: ListTile(
                    title: Text(p.title),
                    subtitle: Text('ID: ${p.id}\nisSubscribed: ${p.isSubscribed}\nRSS: ${p.rssUrl}'),
                    trailing: p.isSubscribed
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.cancel, color: Colors.red),
                  ),
                )),
                const SizedBox(height: 24),
                Text(
                  '已订阅播客 (${subscribedPodcasts.length})',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...subscribedPodcasts.map((p) => Card(
                  child: ListTile(
                    title: Text(p.title),
                    subtitle: Text('ID: ${p.id}\n订阅时间: ${p.subscribedAt}'),
                  ),
                )),
                const SizedBox(height: 24),
                Text(
                  '所有剧集 (${allEpisodes.length})',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...allEpisodes.map((e) => Card(
                  child: ListTile(
                    title: Text(e.title),
                    subtitle: Text('PodcastID: ${e.podcastId}'),
                  ),
                )),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _loadAllData() async {
    final isar = IsarService.instance.isar;

    final allPodcasts = await isar.podcasts.where().findAll();
    final subscribedPodcasts = await isar.podcasts
        .filter()
        .isSubscribedEqualTo(true)
        .findAll();
    final allEpisodes = await isar.episodes.where().findAll();

    return {
      'allPodcasts': allPodcasts,
      'subscribedPodcasts': subscribedPodcasts,
      'allEpisodes': allEpisodes,
    };
  }
}
