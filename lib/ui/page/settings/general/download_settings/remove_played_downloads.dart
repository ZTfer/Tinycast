import 'package:flutter/widgets.dart';
import 'package:tinycast/ui/common_widgets/checkbox/label_checkbox.dart';

class RemovePlayedDownloads extends StatefulWidget {
  const RemovePlayedDownloads({super.key});

  @override
  State<RemovePlayedDownloads> createState() => _RemovePlayedDownloadsState();
}

class _RemovePlayedDownloadsState extends State<RemovePlayedDownloads> {
  /// 自动删除已播放的下载
  bool _autoRemove = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        LabelCheckbox(
          value: _autoRemove,
          label: '自动删除已播放的下载',
          onChanged: (bool newValue) {
            setState(() {
              _autoRemove = newValue;
            });
          },
        ),
        const SizedBox(height: 4.0),
        Row(
          children: const [
            SizedBox(width: 20.0),
            Text(
              '播放完24小时后移除下载',
              style: TextStyle(
                color: Color(0x99000000),
                fontSize: 12,
                height: 16 / 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
