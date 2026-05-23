import 'package:flutter/material.dart';
import 'package:tinycast/core/router/app_router.dart';
import 'package:tinycast/core/router/app_routes.dart';
import 'package:tinycast/presentation/features/settings/general_settings/download_settings/download_settings.dart';
import 'package:tinycast/presentation/features/settings/general_settings/auto_download_settings/auto_download_settings.dart';
import 'package:tinycast/presentation/features/settings/general_settings/feed_refresh_settings/feed_refresh_settings.dart';

class GeneralSettings extends StatelessWidget {
  const GeneralSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: const {
        0: IntrinsicColumnWidth(),
        1: FlexColumnWidth(),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.top,
      children: [
        const TableRow(
          children: [
            Padding(
              padding: EdgeInsets.only(right: 8.0, top: 8.0),
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
            const Padding(
              padding: EdgeInsets.only(right: 8.0, top: 8.0),
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
        const TableRow(
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 8.0, top: 8.0),
              child: Text(
                "刷新:",
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: Color(0xD9000000),
                  fontSize: 14,
                  height: 16 / 14,
                ),
              ),
            ),
            FeedRefreshSettings(),
          ],
        ),
        TableRow(
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 8.0, top: 8.0),
              child: Text(
                "开发者:",
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: Color(0xD9000000),
                  fontSize: 14,
                  height: 16 / 14,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: GestureDetector(
                onTap: () {
                  AppRouter.navigateTo(context, AppRoutes.databaseCleanup);
                },
                child: const Text(
                  "数据库清理工具",
                  style: TextStyle(
                    color: Color(0xFF0000EE),
                    fontSize: 14,
                    height: 16 / 14,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
