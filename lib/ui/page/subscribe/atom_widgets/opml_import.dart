import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// OPML导入组件
///
/// 用于导入OPML文件的拖放区域。
/// 支持点击选择文件和拖放文件功能。
class OpmlImport extends StatefulWidget {
  /// 文件选择完成后的回调函数
  final ValueChanged<File>? onFileSelected;

  /// 组件是否可用
  final bool enabled;

  const OpmlImport({super.key, this.onFileSelected, this.enabled = true});

  @override
  State<OpmlImport> createState() => _OpmlImportState();
}

class _OpmlImportState extends State<OpmlImport> {
  /// 记录是否正在拖动文件
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return DragTarget<Object>(
      /// 判断是否接受拖放的数据
      onWillAcceptWithDetails: (details) => widget.enabled,

      /// 接受拖放的数据时的回调
      onAcceptWithDetails: (details) {
        /// 如果拖放的是文件，触发回调
        if (details.data is File) {
          widget.onFileSelected?.call(details.data as File);
        }

        /// 重置拖动状态
        setState(() {
          _isDragging = false;
        });
      },

      /// 拖放离开区域时的回调
      onLeave: (_) {
        setState(() {
          _isDragging = false;
        });
      },

      /// 拖放移动到区域上时的回调
      onMove: (_) {
        /// 如果不在拖动状态，设置为拖动状态
        if (!_isDragging) {
          setState(() {
            _isDragging = true;
          });
        }
      },
      builder: (context, candidateData, rejectedData) {
        return GestureDetector(
          /// 点击区域时触发文件选择
          onTap: widget.enabled ? _handleTap : null,
          child: Container(
            /// 容器装饰样式
            decoration: BoxDecoration(
              /// 背景色：浅灰色
              color: const Color(0xFFF0F0F0),

              /// 圆角：8px
              borderRadius: BorderRadius.circular(8.0),

              /// 边框样式
              border: Border.all(
                /// 拖动时显示黑色边框，否则显示灰色边框
                color: _isDragging
                    ? const Color(0xFF000000)
                    : const Color(0xFF999999),

                /// 边框宽度：0.5px
                width: 0.5,

                /// 边框样式：实线
                style: BorderStyle.solid,
              ),
            ),

            /// 内边距：水平160px，垂直52px
            padding: const EdgeInsets.symmetric(
              horizontal: 160.0,
              vertical: 52.0,
            ),
            child: Column(
              /// 主轴尺寸：最小
              mainAxisSize: MainAxisSize.min,
              children: [
                /// 上传图标
                Icon(
                  /// 使用 Lucide 的 upload 图标
                  LucideIcons.upload,

                  /// 图标大小：16px
                  size: 16.0,

                  /// 图标颜色：黑色80%透明度
                  color: const Color(0xCC000000),
                ),

                /// 间距：10px
                const SizedBox(height: 10.0),

                /// 提示文字
                Text(
                  '点击或者拖动文件到这里',
                  style: TextStyle(
                    /// 字体大小：10px
                    fontSize: 10.0,

                    /// 可用时显示黑色50%透明度，禁用时显示黑色25%透明度
                    color: widget.enabled
                        ? const Color(0x80000000)
                        : const Color(0x40000000),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 处理点击事件，打开文件选择器
  Future<void> _handleTap() async {
    try {
      /// 使用文件选择器选择文件
      final result = await FilePicker.platform.pickFiles(
        /// 文件类型：自定义
        type: FileType.custom,

        /// 允许的文件扩展名：opml 和 xml
        allowedExtensions: ['opml', 'xml'],
      );

      /// 如果选择了文件且文件路径不为空
      if (result != null && result.files.single.path != null) {
        /// 创建文件对象
        final file = File(result.files.single.path!);

        /// 触发文件选择回调
        widget.onFileSelected?.call(file);
      }
    } catch (e) {
      /// 打印错误信息
      debugPrint('文件选择失败: $e');
    }
  }
}
