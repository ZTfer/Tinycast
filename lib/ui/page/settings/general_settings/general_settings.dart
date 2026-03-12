import 'package:flutter/widgets.dart';
import 'package:tinycast/ui/page/settings/general_settings/download_settings/download_settings.dart';
import 'package:tinycast/ui/page/settings/general_settings/auto_download_settings/auto_download_settings.dart';

class GeneralSettings extends StatelessWidget {
  const GeneralSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: const {
        0: IntrinsicColumnWidth(), // 关键：第一列宽度由内容决定（取最大值）
        1: FlexColumnWidth(), // 第二列占满剩余空间
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        const TableRow(
          children: [
            Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Text(
                "下载:",
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: Color(0xD9000000),
                  fontSize: 14,
                  height: 16 / 14,
                ),
              ),
            ),
            DownloadSettings(),
          ],
        ),
        const TableRow(
          children: [
            Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Text(
                "自动下载:",
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: Color(0xD9000000),
                  fontSize: 14,
                  height: 16 / 14,
                ),
              ),
            ),
            AutoDownloadSettings(),
          ],
        ),
      ],
    );
  }
}
