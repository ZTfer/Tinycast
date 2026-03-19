import 'package:flutter/material.dart';
import 'package:tinycast/data/services/cache_cleanup_service.dart';
import 'package:tinycast/presentation/widgets/atoms/buttons/primary_button.dart';

class CacheSettings extends StatefulWidget {
  const CacheSettings({super.key});

  @override
  State<CacheSettings> createState() => _CacheSettingsState();
}

class _CacheSettingsState extends State<CacheSettings> {
  final CacheCleanupService _cacheCleanupService = CacheCleanupService.instance;

  String _cacheSize = '计算中...';
  bool _isLoading = false;
  bool _isCleaning = false;
  String? _errorMessage;
  String? _successMessage;
  CleanupOption _selectedOption = CleanupOption.all;

  @override
  void initState() {
    super.initState();
    _loadCacheSize();
  }

  Future<void> _loadCacheSize() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final size = await _cacheCleanupService.getCacheSizeFormatted();
      if (mounted) {
        setState(() {
          _cacheSize = size;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _cacheSize = '未知';
          _isLoading = false;
          _errorMessage = '获取缓存大小失败: $e';
        });
      }
    }
  }

  Future<void> _performCleanup() async {
    setState(() {
      _isCleaning = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      switch (_selectedOption) {
        case CleanupOption.all:
          await _cacheCleanupService.clearAllCache();
          break;
        case CleanupOption.played:
          await _cacheCleanupService.clearPlayedEpisodes();
          break;
        case CleanupOption.recent5:
          await _cacheCleanupService.keepRecentEpisodes(5);
          break;
        case CleanupOption.recent10:
          await _cacheCleanupService.keepRecentEpisodes(10);
          break;
      }

      if (mounted) {
        setState(() {
          _isCleaning = false;
          _successMessage = _getSuccessMessage();
        });

        // 重新加载缓存大小
        await _loadCacheSize();

        // 3秒后清除成功消息
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _successMessage = null;
            });
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCleaning = false;
          _errorMessage = '清理失败: $e';
        });

        // 5秒后清除错误消息
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) {
            setState(() {
              _errorMessage = null;
            });
          }
        });
      }
    }
  }

  String _getSuccessMessage() {
    switch (_selectedOption) {
      case CleanupOption.all:
        return '所有缓存已清理完成';
      case CleanupOption.played:
        return '已播放节目缓存已清理完成';
      case CleanupOption.recent5:
        return '已保留最近5集，其余已清理';
      case CleanupOption.recent10:
        return '已保留最近10集，其余已清理';
    }
  }

  String _getOptionLabel() {
    switch (_selectedOption) {
      case CleanupOption.all:
        return '清理所有';
      case CleanupOption.played:
        return '清理已播放';
      case CleanupOption.recent5:
        return '保留最近5集';
      case CleanupOption.recent10:
        return '保留最近10集';
    }
  }

  String _getOptionDescription() {
    switch (_selectedOption) {
      case CleanupOption.all:
        return '清理所有音频和图片缓存';
      case CleanupOption.played:
        return '仅清理已播放的节目';
      case CleanupOption.recent5:
        return '保留最近5集，删除其余';
      case CleanupOption.recent10:
        return '保留最近10集，删除其余';
    }
  }

  void _showCleanupOptions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('选择清理选项'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildOptionTile(CleanupOption.all),
              _buildOptionTile(CleanupOption.played),
              _buildOptionTile(CleanupOption.recent5),
              _buildOptionTile(CleanupOption.recent10),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOptionTile(CleanupOption option) {
    final isSelected = _selectedOption == option;
    return ListTile(
      title: Text(_getOptionLabelForOption(option)),
      subtitle: Text(_getOptionDescriptionForOption(option)),
      trailing: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: isSelected ? const Color(0xFF222222) : const Color(0x99000000),
      ),
      onTap: () {
        setState(() {
          _selectedOption = option;
        });
        Navigator.of(context).pop();
      },
    );
  }

  String _getOptionLabelForOption(CleanupOption option) {
    switch (option) {
      case CleanupOption.all:
        return '清理所有';
      case CleanupOption.played:
        return '清理已播放';
      case CleanupOption.recent5:
        return '保留最近5集';
      case CleanupOption.recent10:
        return '保留最近10集';
    }
  }

  String _getOptionDescriptionForOption(CleanupOption option) {
    switch (option) {
      case CleanupOption.all:
        return '清理所有音频和图片缓存';
      case CleanupOption.played:
        return '仅清理已播放的节目';
      case CleanupOption.recent5:
        return '保留最近5集，删除其余';
      case CleanupOption.recent10:
        return '保留最近10集，删除其余';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 缓存大小显示
        _buildCacheSizeSection(),
        const SizedBox(height: 16.0),

        // 清理选项
        _buildCleanupOptionSection(),
        const SizedBox(height: 16.0),

        // 清理按钮
        _buildCleanupButton(),
        const SizedBox(height: 8.0),

        // 消息反馈
        if (_errorMessage != null) _buildErrorMessage(),
        if (_successMessage != null) _buildSuccessMessage(),
      ],
    );
  }

  Widget _buildCacheSizeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '缓存大小:',
          style: TextStyle(
            color: Color(0xD9000000),
            fontSize: 14,
            height: 16 / 14,
          ),
        ),
        const SizedBox(height: 8.0),
        Row(
          children: [
            Text(
              _isLoading ? '计算中...' : _cacheSize,
              style: const TextStyle(
                color: Color(0xD9000000),
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 20 / 16,
              ),
            ),
            if (_isLoading) ...[
              const SizedBox(width: 8.0),
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildCleanupOptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '清理选项:',
          style: TextStyle(
            color: Color(0xD9000000),
            fontSize: 14,
            height: 16 / 14,
          ),
        ),
        const SizedBox(height: 8.0),
        GestureDetector(
          onTap: _showCleanupOptions,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getOptionLabel(),
                  style: const TextStyle(
                    color: Color(0xD9000000),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8.0),
                const Icon(Icons.arrow_drop_down, color: Color(0x99000000)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4.0),
        Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: Text(
            _getOptionDescription(),
            style: const TextStyle(
              color: Color(0x99000000),
              fontSize: 12,
              height: 16 / 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCleanupButton() {
    return PrimaryButton(
      label: _isCleaning ? '清理中...' : '清理缓存',
      onPressed: _isCleaning ? () {} : _performCleanup,
      width: 120,
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: const Color(0xFFEF9A9A)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFD32F2F), size: 20),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Color(0xFFD32F2F), fontSize: 12),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _errorMessage = null;
              });
            },
            child: const Icon(Icons.close, color: Color(0xFFD32F2F), size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: const Color(0xFFA5D6A7)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: Color(0xFF388E3C),
            size: 20,
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              _successMessage!,
              style: const TextStyle(color: Color(0xFF388E3C), fontSize: 12),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _successMessage = null;
              });
            },
            child: const Icon(Icons.close, color: Color(0xFF388E3C), size: 16),
          ),
        ],
      ),
    );
  }
}

enum CleanupOption { all, played, recent5, recent10 }
