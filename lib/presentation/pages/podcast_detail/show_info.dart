import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tinycast/presentation/widgets/atoms/buttons/horizontal_more_button.dart';

class ShowInfo extends StatelessWidget {
  const ShowInfo({super.key});

  void _handleMorePressed() {
    // TODO: 实现更多按钮点击逻辑
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(
          'assets/images/image_placeholder.svg',
          width: 24,
          height: 24,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '播客标题文字',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  HorizontalMoreButton(
                    icon: const Icon(LucideIcons.ellipsisVertical, size: 16),
                    onPressed: _handleMorePressed,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                '播客描述文字',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
