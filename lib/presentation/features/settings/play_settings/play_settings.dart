import 'package:flutter/widgets.dart';
import 'package:tinycast/presentation/features/settings/play_settings/continuous_play_settings.dart';
import 'package:tinycast/presentation/features/settings/play_settings/skip_time_settings/skip_time_settings.dart';

class PlaySettings extends StatelessWidget {
  const PlaySettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: const {
        0: IntrinsicColumnWidth(), // 关键：第一列宽度由内容决定（取最大值）
        1: FlexColumnWidth(), // 第二列占满剩余空间
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.top,
      children: [
        const TableRow(
          children: [
            Padding(
              padding: EdgeInsets.only(right: 8.0, top: 8.0),
              child: Text(
                "连续播放:",
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: Color(0xD9000000),
                  fontSize: 14,
                  height: 16 / 14,
                ),
              ),
            ),
            ContinuousPlaySettings(),
          ],
        ),
        const TableRow(
          children: [
            Padding(
              padding: EdgeInsets.only(right: 8.0, top: 8.0),
              child: Text(
                "跳过按钮:",
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: Color(0xD9000000),
                  fontSize: 14,
                  height: 16 / 14,
                ),
              ),
            ),
            SkipTimeSettings(),
          ],
        ),
      ],
    );
  }
}
