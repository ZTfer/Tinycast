import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tinycast/core/utils/html_tag_remove_utils.dart';
import 'package:tinycast/presentation/widgets/atoms/artwork_image/artwork_image.dart';
import 'package:tinycast/presentation/widgets/atoms/buttons/horizontal_more_button.dart';
import 'package:tinycast/presentation/widgets/organisms/dropdown/library_dropdown.dart';

class ShowInfo extends StatelessWidget {
  final String? title;
  final String? artworkUrl;
  final String? description;
  final String? rssUrl;
  final bool hasDownloadedEpisodes;
  final VoidCallback? onViewDetails;
  final VoidCallback? onCopyLinkSuccess;
  final VoidCallback? onRemoveDownloads;
  final VoidCallback? onUnfollow;

  const ShowInfo({
    super.key,
    this.title,
    this.artworkUrl,
    this.description,
    this.rssUrl,
    this.hasDownloadedEpisodes = false,
    this.onViewDetails,
    this.onCopyLinkSuccess,
    this.onRemoveDownloads,
    this.onUnfollow,
  });

  void _handleMorePressed(BuildContext context, RenderBox buttonRenderBox) {
    final overlay = Overlay.of(context);
    final buttonSize = buttonRenderBox.size;
    final buttonPosition = buttonRenderBox.localToGlobal(Offset.zero);

    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // 透明背景，点击关闭下拉菜单
          Positioned.fill(
            child: GestureDetector(
              onTap: () => overlayEntry.remove(),
              behavior: HitTestBehavior.opaque,
              child: Container(color: Colors.transparent),
            ),
          ),
          Positioned(
            top: buttonPosition.dy + buttonSize.height,
            right: 0,
            child: Material(
              color: Colors.transparent,
              child: LibraryDropdown(
                onViewDetails: onViewDetails,
                rssUrl: rssUrl,
                onCopyLinkSuccess: onCopyLinkSuccess,
                hasDownloadedEpisodes: hasDownloadedEpisodes,
                onRemoveDownloads: onRemoveDownloads,
                onUnfollow: onUnfollow,
                onItemSelected: () => overlayEntry.remove(),
              ),
            ),
          ),
        ],
      ),
    );

    overlay.insert(overlayEntry);
  }

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
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Builder(
                        builder: (context) {
                          return HorizontalMoreButton(
                            icon: const Icon(
                              LucideIcons.ellipsisVertical,
                              size: 14,
                            ),
                            onPressed: () {
                              final renderBox =
                                  context.findRenderObject() as RenderBox?;
                              if (renderBox != null) {
                                _handleMorePressed(context, renderBox);
                              }
                            },
                          );
                        },
                      );
                    },
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
