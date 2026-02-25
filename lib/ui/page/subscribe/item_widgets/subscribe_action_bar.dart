import 'package:flutter/widgets.dart';
import 'package:tinycast/ui/common_widgets/buttons/secondary_button.dart';
import 'package:tinycast/ui/common_widgets/buttons/primary_button.dart';

/// 订阅操作栏组件
///
/// 包含取消和订阅两个按钮的操作栏。
/// 使用 Row 横向排列，居中对齐。
class SubscribeActionBar extends StatelessWidget {
  const SubscribeActionBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      /// 主轴尺寸：最小，根据内容自适应
      mainAxisSize: MainAxisSize.min,

      /// 主轴对齐：居中
      // mainAxisAlignment: MainAxisAlignment.center,

      /// 子组件列表
      children: [
        /// 取消按钮
        SecondaryButton(
          /// 按钮文字
          label: '取消',

          /// 按钮点击的回调函数
          onPressed: () {
            debugPrint('Follow pressed');
          },
        ),

        /// 按钮间距：12px
        const SizedBox(width: 12),

        /// 订阅按钮
        PrimaryButton(
          /// 按钮文字
          label: '订阅',

          /// 按钮点击的回调函数
          onPressed: () {
            debugPrint('Subscribe pressed');
          },
        ),
      ],
    );
  }
}
