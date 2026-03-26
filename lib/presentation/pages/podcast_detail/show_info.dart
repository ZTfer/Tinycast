import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tinycast/core/utils/html_tag_remove_utils.dart';
import 'package:tinycast/presentation/widgets/atoms/buttons/horizontal_more_button.dart';

class ShowInfo extends StatelessWidget {
  final String? title;
  final String? artworkUrl;
  final String? description;

  const ShowInfo({super.key, this.title, this.artworkUrl, this.description});

  void _handleMorePressed() {
    // TODO: 实现更多按钮点击逻辑
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: artworkUrl != null
              ? Image.network(
                  artworkUrl!,
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                )
              : SvgPicture.asset(
                  'assets/images/image_placeholder.svg',
                  width: 32,
                  height: 32,
                ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title ?? '未知播客',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 20 / 14,
                    ),
                  ),
                  HorizontalMoreButton(
                    icon: const Icon(LucideIcons.ellipsisVertical, size: 14),
                    onPressed: _handleMorePressed,
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                description != null
                    ? HtmlTagRemoveUtils.stripHtml(description!)
                    : '未知描述',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }
}
