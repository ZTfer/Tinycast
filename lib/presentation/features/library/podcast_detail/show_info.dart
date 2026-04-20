import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tinycast/core/utils/html_tag_remove_utils.dart';
import 'package:tinycast/presentation/widgets/atoms/artwork_image/artwork_image.dart';
import 'package:tinycast/presentation/widgets/atoms/buttons/horizontal_more_button.dart';

class ShowInfo extends StatelessWidget {
  final String? title;
  final String? artworkUrl;
  final String? description;

  const ShowInfo({super.key, this.title, this.artworkUrl, this.description});

  void _handleMorePressed() {}

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 2,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            width: 64,
            height: 64,
            child: ArtworkImage(
              artworkUrl: artworkUrl,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              placeholder: SvgPicture.asset(
                'assets/images/image_placeholder.svg',
                width: 64,
                height: 64,
              ),
              errorWidget: SvgPicture.asset(
                'assets/images/image_placeholder.svg',
                width: 64,
                height: 64,
              ),
            ),
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
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF333333),
                      height: 20 / 15,
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
                  color: Color(0xFF999999),
                  height: 16 / 12,
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
