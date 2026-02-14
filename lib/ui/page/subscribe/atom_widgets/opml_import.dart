import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

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
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return DragTarget<Object>(
      onWillAcceptWithDetails: (details) => widget.enabled,
      onAcceptWithDetails: (details) {
        if (details.data is File) {
          widget.onFileSelected?.call(details.data as File);
        }
        setState(() {
          _isDragging = false;
        });
      },
      onLeave: (_) {
        setState(() {
          _isDragging = false;
        });
      },
      onMove: (_) {
        if (!_isDragging) {
          setState(() {
            _isDragging = true;
          });
        }
      },
      builder: (context, candidateData, rejectedData) {
        return GestureDetector(
          onTap: widget.enabled ? _handleTap : null,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: _isDragging
                    ? const Color(0xFF000000)
                    : const Color(0xFF999999),
                width: 0.5,
                style: BorderStyle.solid,
              ),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 160.0,
              vertical: 52.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 16.0,
                  color: const Color(0xCC000000),
                ),
                const SizedBox(height: 10.0),
                Text(
                  '点击或者拖动文件到这里',
                  style: TextStyle(
                    fontSize: 10.0,
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

  Future<void> _handleTap() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['opml', 'xml'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        widget.onFileSelected?.call(file);
      }
    } catch (e) {
      debugPrint('文件选择失败: $e');
    }
  }
}
