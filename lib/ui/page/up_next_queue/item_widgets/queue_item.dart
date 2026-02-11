import 'package:flutter/widgets.dart';
import 'package:lucide_icons/lucide_icons.dart';

class QueueItem extends StatelessWidget {
  final String timeAgo;
  final String title;
  final String description;
  final String duration;
  final bool showDivider;

  const QueueItem({
    super.key,
    required this.timeAgo,
    required this.title,
    required this.description,
    required this.duration,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextSection(),
                    const SizedBox(height: 6),
                    _buildActionSection(),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider) _buildDivider(),
      ],
    );
  }

  Widget _buildTextSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          timeAgo,
          style: const TextStyle(
            fontSize: 9.75,
            color: Color(0xD9000000),
            fontWeight: FontWeight.normal,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF000000),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: const TextStyle(
            fontSize: 9.75,
            color: Color(0xD9000000),
            fontWeight: FontWeight.normal,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildActionSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFDADADA),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.play, size: 10, color: const Color(0xFF000000)),
              const SizedBox(width: 4),
              Text(
                duration,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF000000),
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        Icon(
          LucideIcons.moreHorizontal,
          size: 12,
          color: const Color(0xD9000000),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 1, color: const Color(0xFFE0E0E0));
  }
}
