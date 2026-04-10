import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/presentation/features/history/history_empty_page/history_empty_page.dart';
import 'package:tinycast/presentation/providers/play_history_provider.dart';
import 'package:tinycast/data/models/play_history_model.dart';

class History extends ConsumerWidget {
  const History({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('🔍 [History] ====== BUILD METHOD CALLED ======');
    final historiesAsync = ref.watch(completedHistoriesProvider);
    debugPrint('🔍 [History] Provider type: ${historiesAsync.runtimeType}');

    return historiesAsync.when(
      data: (histories) {
        debugPrint('🔍 [History] ✅ DATA RECEIVED');
        debugPrint('🔍 [History] 📊 Total records from provider: ${histories.length}');

        for (int i = 0; i < histories.length; i++) {
          final h = histories[i];
          debugPrint('🔍 [History]   [$i] ID: ${h.id}, Title: "${h.title}", Status: ${h.status}, isPlayed: ${h.isPlayed}, isDeleted: ${h.isDeleted}');
        }

        if (histories.isEmpty) {
          debugPrint('🔍 [History] 📭 Showing empty page (no completed records)');
          return const HistoryEmptyPage();
        }

        debugPrint('🔍 [History] 📝 Building list with ${histories.length} items');
        return ListView.builder(
          itemCount: histories.length,
          itemBuilder: (context, index) {
            final history = histories[index];
            final isLast = index == histories.length - 1;

            return _buildHistoryItem(
              context,
              ref,
              history,
              showDivider: !isLast,
            );
          },
        );
      },
      loading: () {
        debugPrint('🔍 [History] ⏳ LOADING STATE');
        return const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      error: (error, stack) {
        debugPrint('🔍 [History] ❌ ERROR STATE: $error');
        debugPrint('🔍 [History] Stack: $stack');
        return Center(
          child: Text('Error: $error'),
        );
      },
    );
  }

  Widget _buildHistoryItem(
    BuildContext context,
    WidgetRef ref,
    PlayHistory history, {
    required bool showDivider,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: history.artworkUrl != null
                ? Image.network(
                    history.artworkUrl!,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 56,
                      height: 56,
                      color: Colors.grey.shade300,
                      child: Icon(Icons.podcasts, color: Colors.grey.shade600),
                    ),
                  )
                : Container(
                    width: 56,
                    height: 56,
                    color: Colors.grey.shade300,
                    child: Icon(Icons.podcasts, color: Colors.grey.shade600),
                  ),
          ),
          title: Text(
            history.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _formatDateTime(history.lastUpdateTime),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.play_circle_outline, size: 32),
            onPressed: () => _onPlayPressed(ref, history),
          ),
          onTap: () => _onPlayPressed(ref, history),
        ),
        if (showDivider)
          const Divider(height: 1, indent: 88, endIndent: 16),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return 'Today at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _onPlayPressed(WidgetRef ref, PlayHistory history) async {
    try {
      debugPrint('Play episode: ${history.episodeId}');
    } catch (e) {
      debugPrint('Error playing episode: $e');
    }
  }
}
