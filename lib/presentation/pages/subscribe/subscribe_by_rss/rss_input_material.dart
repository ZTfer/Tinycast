import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/presentation/providers/podcast_provider.dart';
import 'package:tinycast/core/router/app_router.dart';
import 'package:tinycast/core/router/app_routes.dart';
import 'package:tinycast/core/utils/error_toast.dart';
import 'package:tinycast/core/utils/error_dialog.dart';
import 'package:tinycast/core/utils/app_exception.dart';

/// RSS输入框组件（Material Design）
///
/// 使用 Material Design 的 TextField 实现的RSS订阅链接输入框。
/// 包含占位文字提示，支持用户输入和焦点状态。
/// 包含订阅按钮、URL格式验证、加载状态显示、错误提示和成功提示。
class RssInputMaterial extends ConsumerStatefulWidget {
  /// 输入框的初始值
  final String initialValue;

  /// 输入内容变化的回调函数
  final ValueChanged<String>? onChanged;

  /// 输入框完成编辑的回调函数
  final ValueChanged<String>? onSubmitted;

  /// 输入框是否可用
  final bool enabled;

  const RssInputMaterial({
    super.key,
    this.initialValue = '',
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
  });

  @override
  ConsumerState<RssInputMaterial> createState() => _RssInputMaterialState();
}

class _RssInputMaterialState extends ConsumerState<RssInputMaterial> {
  /// 文本编辑控制器，用于管理输入框的文本内容
  late TextEditingController _controller;

  /// 输入框焦点节点
  final FocusNode _focusNode = FocusNode();

  /// 是否正在订阅
  bool _isSubscribing = false;

  /// 错误消息
  String? _errorMessage;

  /// 成功消息
  String? _successMessage;

  @override
  void initState() {
    super.initState();

    /// 初始化文本控制器，设置初始值
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    /// 释放文本控制器和焦点节点资源
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// 验证 RSS URL 格式
  bool _isValidUrl(String url) {
    if (url.isEmpty) return false;
    
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  /// 处理订阅操作
  Future<void> _handleSubscribe() async {
    final rssUrl = _controller.text.trim();

    // 清除之前的消息
    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });

    // 验证 URL
    if (!_isValidUrl(rssUrl)) {
      setState(() {
        _errorMessage = '请输入有效的 RSS URL（以 http:// 或 https:// 开头）';
      });
      // 显示验证错误提示
      ErrorToast.showValidationError(context);
      return;
    }

    // 开始订阅
    setState(() {
      _isSubscribing = true;
    });

    try {
      await ref.read(podcastProvider.notifier).subscribe(rssUrl);

      // 获取订阅后的播客信息
      final podcastState = ref.read(podcastProvider);
      final podcast = podcastState.podcast;

      // 订阅成功
      setState(() {
        _isSubscribing = false;
        _successMessage = '订阅成功！';
        _controller.clear();
      });

      // 显示成功提示
      ErrorToast.showSuccess(context, '订阅成功！');

      // 刷新播客列表
      ref.read(podcastProvider.notifier).loadSubscribedPodcasts();

      // 延迟清除成功消息
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _successMessage = null;
          });
        }
      });

      // 延迟跳转到播客详情页面或播客列表页面
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          // 如果订阅成功且有播客信息，跳转到播客详情页面
          if (podcast != null) {
            AppRouter.navigateTo(
              context,
              AppRoutes.podcastDetail,
              arguments: podcast.id,
            );
          } else {
            // 否则跳转到播客列表页面
            AppRouter.navigateTo(context, AppRoutes.library);
          }
        }
      });

      // 调用回调函数
      widget.onSubmitted?.call(rssUrl);
    } catch (e) {
      // 订阅失败
      setState(() {
        _isSubscribing = false;
      });

      // 处理错误
      AppException exception;
      if (e is AppException) {
        exception = e;
      } else {
        exception = AppException.unknown(
          '订阅失败：${e.toString()}',
          originalError: e,
        );
      }

      // 显示错误对话框，提供重试选项
      ErrorDialog.show(
        context,
        exception,
        onRetry: () {
          // 重试订阅
          _handleSubscribe();
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 监听 podcast 状态
    final podcastState = ref.watch(podcastProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                /// 绑定文本控制器
                controller: _controller,

                /// 绑定焦点节点
                focusNode: _focusNode,

                /// 是否可用
                enabled: widget.enabled && !_isSubscribing,

                /// 占位文字
                decoration: InputDecoration(
                  /// 占位文字内容
                  hintText: 'https://domain.com/podcast.rss',

                  /// 占位文字样式
                  hintStyle: const TextStyle(
                    /// 字体大小：12px
                    fontSize: 12.0,

                    /// 文字颜色：黑色30%透明度
                    color: Color(0x4D000000),

                    /// 行高：16px
                    height: 16.0 / 12.0,
                  ),

                  /// 填充背景色
                  filled: true,
                  fillColor: const Color(0xFFF0F0F0),

                  /// 圆角边框
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),

                  /// 禁用状态的边框
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),

                  /// 聚焦状态的边框
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),

                  /// 错误状态的边框
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: Colors.red, width: 1.0),
                  ),

                  /// 内边距
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 8.0,
                  ),

                  /// 最小高度约束
                  constraints: const BoxConstraints(minHeight: 34.0, maxHeight: 40.0),

                  /// 去除默认的标签
                  label: null,

                  /// 错误文本
                  errorText: _errorMessage,
                ),

                /// 文本样式
                style: const TextStyle(
                  /// 字体大小：12px
                  fontSize: 12.0,

                  /// 文字颜色：黑色
                  color: Color(0xFF000000),

                  /// 行高：16px
                  height: 16.0 / 12.0,
                ),

                /// 光标颜色：黑色
                cursorColor: const Color(0xFF000000),

                /// 文本内容变化时的回调
                onChanged: (value) {
                  // 清除错误消息
                  if (_errorMessage != null) {
                    setState(() {
                      _errorMessage = null;
                    });
                  }
                  widget.onChanged?.call(value);
                },

                /// 提交文本时的回调（如按回车键）
                onSubmitted: (value) {
                  _handleSubscribe();
                },

                /// 最大行数：1（单行输入）
                maxLines: 1,

                /// 最小行数：1（确保始终是单行）
                minLines: 1,
              ),
            ),
            const SizedBox(width: 8.0),
            SizedBox(
              width: 70.0,
              height: 34.0,
              child: ElevatedButton(
                onPressed: _isSubscribing ? null : _handleSubscribe,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF000000),
                  foregroundColor: const Color(0xFFFFFFFF),
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: _isSubscribing
                    ? const SizedBox(
                        width: 16.0,
                        height: 16.0,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFFFFF)),
                        ),
                      )
                    : const Text(
                        '订阅',
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
            ),
          ],
        ),
        // 成功消息
        if (_successMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              _successMessage!,
              style: const TextStyle(
                fontSize: 12.0,
                color: Colors.green,
              ),
            ),
          ),
      ],
    );
  }
}
