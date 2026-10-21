import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tinycast/presentation/providers/sync_provider.dart';
import 'package:tinycast/core/services/sync_service.dart';

class LoginSuccessPage extends ConsumerStatefulWidget {
  final User user;
  final VoidCallback onSignOut;

  const LoginSuccessPage({
    super.key,
    required this.user,
    required this.onSignOut,
  });

  @override
  ConsumerState<LoginSuccessPage> createState() => _LoginSuccessPageState();
}

class _LoginSuccessPageState extends ConsumerState<LoginSuccessPage> {
  @override
  Widget build(BuildContext context) {
    final email = widget.user.email ?? '未绑定邮箱';
    final displayName = widget.user.userMetadata?['name'] as String? ?? email;
    final syncState = ref.watch(syncProvider);
    final isSyncing = syncState.status == SyncStatus.syncing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        const Text(
          '您的账户：',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        Text(
          displayName,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          email,
          style: const TextStyle(fontSize: 12, color: Color(0x4D000000)),
        ),
        const SizedBox(height: 12),
        const Divider(height: 1),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text(
              '同步状态：',
              style: TextStyle(fontSize: 12, color: Color(0x99000000)),
            ),
            _buildSyncStatusIndicator(syncState),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Text(
              '上次同步：',
              style: TextStyle(fontSize: 12, color: Color(0x99000000)),
            ),
            Text(
              syncState.lastSyncTime != null
                  ? DateFormat(
                      'yyyy-MM-dd HH:mm',
                    ).format(syncState.lastSyncTime!)
                  : '从未同步',
              style: const TextStyle(fontSize: 12, color: Color(0x99000000)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: isSyncing
                ? null
                : () => ref.read(syncProvider.notifier).syncNow(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSyncing
                    ? const Color(0xFFE5E7EB)
                    : const Color(0xFFDBEAFE),
                borderRadius: BorderRadius.circular(16),
              ),
              child: isSyncing
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF3B82F6),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          '同步中...',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF3B82F6),
                          ),
                        ),
                      ],
                    )
                  : const Text(
                      '手动同步',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF3B82F6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: widget.onSignOut,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                '退出登录',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFFEF4444),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSyncStatusIndicator(SyncState syncState) {
    switch (syncState.status) {
      case SyncStatus.idle:
        return const Text(
          '已同步',
          style: TextStyle(fontSize: 12, color: Color(0xFF22C55E)),
        );
      case SyncStatus.syncing:
        return const Text(
          '同步中...',
          style: TextStyle(fontSize: 12, color: Color(0xFF3B82F6)),
        );
      case SyncStatus.error:
        return const Text(
          '同步失败',
          style: TextStyle(fontSize: 12, color: Color(0xFFEF4444)),
        );
    }
  }
}
