import 'package:flutter/material.dart';
import 'package:tinycast/data/services/cache_cleanup_service.dart';
import 'package:tinycast/presentation/widgets/atoms/buttons/primary_button.dart';
import 'package:tinycast/presentation/features/settings/widgets/settings_dropdown_button.dart';
import 'package:tinycast/presentation/features/settings/cache_settings/cache_cleanup_dropdown.dart';

class CacheSettings extends StatefulWidget {
  const CacheSettings({super.key});

  @override
  State<CacheSettings> createState() => _CacheSettingsState();
}

class _CacheSettingsState extends State<CacheSettings> {
  final CacheCleanupService _cacheCleanupService = CacheCleanupService.instance;
  final GlobalKey _buttonKey = GlobalKey();

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
    final confirmed = await _confirmCleanup();
    if (!confirmed || !mounted) return;

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

  String _getConfirmMessage() {
    switch (_selectedOption) {
      case CleanupOption.all:
        return '将删除所有已下载的音频和图片缓存，删除后需要重新下载。';
      case CleanupOption.played:
        return '将删除所有已播放节目的下载文件，删除后需要重新下载。';
      case CleanupOption.recent5:
        return '将保留最近 5 集，删除其余已下载的节目文件。';
      case CleanupOption.recent10:
        return '将保留最近 10 集，删除其余已下载的节目文件。';
    }
  }

  Future<bool> _confirmCleanup() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Center(
        child: Container(
          width: 360,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '清理缓存',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF000000),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _getConfirmMessage(),
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: 12,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(dialogContext).pop(false),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Text(
                        '取消',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(dialogContext).pop(true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF000000),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '确认清理',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return confirmed ?? false;
  }

  void _showDropdown() {
    if (!mounted) return;

    final renderBox = _buttonKey.currentContext?.findRenderObject();
    if (renderBox is! RenderBox) return;

    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final screenSize = MediaQuery.of(context).size;

    const double estimatedMenuWidth = 200.0;
    const double estimatedMenuHeight = 200.0;

    double left = offset.dx;
    double top = offset.dy + size.height + 4;

    if (left + estimatedMenuWidth > screenSize.width) {
      left = screenSize.width - estimatedMenuWidth - 8;
    }

    if (top + estimatedMenuHeight > screenSize.height) {
      top = offset.dy - estimatedMenuHeight + 140;
    }

    final overlay = Overlay.of(context);

    OverlayEntry? dropdownOverlay;
    dropdownOverlay = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                dropdownOverlay?.remove();
              },
              child: Container(color: Colors.transparent),
            ),
          ),
          Positioned(
            left: left,
            top: top,
            child: GestureDetector(
              onTap: () {},
              behavior: HitTestBehavior.opaque,
              child: CacheCleanupSettingsDropdown(
                selectedOption: _selectedOption,
                onOptionSelected: (option) {
                  if (mounted) {
                    setState(() {
                      _selectedOption = option;
                    });
                  }
                  dropdownOverlay?.remove();
                },
              ),
            ),
          ),
        ],
      ),
    );

    overlay.insert(dropdownOverlay);
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

        // 清理选项下拉菜单
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
        SettingsDropdownButton(
          key: _buttonKey,
          label: _getOptionLabel(),
          onPressed: _showDropdown,
        ),
        const SizedBox(height: 4.0),
        Text(
          _getOptionDescription(),
          style: const TextStyle(
            color: Color.fromARGB(217, 160, 160, 160),
            fontSize: 12,
            height: 16 / 12,
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
