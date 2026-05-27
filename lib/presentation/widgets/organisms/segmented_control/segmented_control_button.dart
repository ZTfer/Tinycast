import 'package:flutter/widgets.dart';

class SegmentedControlButton extends StatelessWidget {
  final String? label;
  final Widget? icon;
  final bool isSelected;
  final VoidCallback? onTap;

  const SegmentedControlButton({
    super.key,
    this.label,
    this.icon,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 3.0),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFFFFF) : const Color(0x00000000),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Center(child: _buildContent()),
      ),
    );
  }

  Widget _buildContent() {
    if (icon != null && label != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon!,
          const SizedBox(width: 4.0),
          Flexible(
            child: Text(
              label!,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w600,
                fontSize: 13.3,
                height: 18.0 / 13.3,
                letterSpacing: -0.08,
                color: Color(0xFF000000),
              ),
            ),
          ),
        ],
      );
    }

    if (icon != null) {
      return icon!;
    }

    if (label != null) {
      return Flexible(
        child: Text(
          label!,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w600,
            fontSize: 13.3,
            height: 18.0 / 13.3,
            letterSpacing: -0.08,
            color: Color(0xFF000000),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
