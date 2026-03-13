import 'package:flutter/widgets.dart';
import 'package:tinycast/ui/page/settings/cloud_sync_settings/login/login_button/social_login_button_group.dart';
import 'package:tinycast/ui/page/up_next_queue/queue_empty_page/queue_empty_page.dart';
import 'package:tinycast/ui/common_widgets/toast/vertical_icon_toast.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tinycast/ui/page/subscribe/subscribe_search_result/subscribe_search_result_error.dart';
import 'package:tinycast/ui/page/settings/cloud_sync_settings/login/login_button/google_login_button.dart';
import 'package:tinycast/ui/page/settings/cloud_sync_settings/login/login_button/apple_login_button.dart';
import 'package:tinycast/ui/page/search/search_page.dart';
import 'package:tinycast/ui/page/search/search_results/search_result_success/search_results_success_item.dart';

// 用于测试的页面，不用于实际生产，测试写出来的widget样式是否正确的页面，不用于实际生产环境
class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          spacing: 12.0,
          children: [
            QueueEmptyPage(),
            VerticalIconToast(
              icon: Icon(LucideIcons.check, size: 36.0),
              text: '复制成功',
              textSize: 12,
            ),
            SubscribeSearchResultError(),
            GoogleLoginButton(),
            AppleLoginButton(),
            SocialLoginButtonGroup(),
            SearchPage(),
            SearchResultsSuccessItem(
              episodeTitle: '剧集标题',
              episodeDescription: '剧集简介',
            ),
          ],
        ),
      ),
    );
  }
}
