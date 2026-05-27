import 'package:flutter/widgets.dart';
import 'package:tinycast/presentation/widgets/organisms/segmented_control/segmented_control_button.dart';

class SegmentedControlSegment {
  final String? label;
  final Widget? icon;

  const SegmentedControlSegment({this.label, this.icon});
}

class SegmentedControl extends StatelessWidget {
  final List<SegmentedControlSegment> segments;
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final double height;

  const SegmentedControl({
    super.key,
    required this.segments,
    required this.onTap,
    this.selectedIndex = 0,
    this.height = 32.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(2.0),
      decoration: BoxDecoration(
        color: const Color(0x1F767680),
        borderRadius: BorderRadius.circular(100.0),
      ),
      child: Row(
        children: List.generate(segments.length, (index) {
          final segment = segments[index];
          final isSelected = index == selectedIndex;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? 0.0 : 2.0,
                right: index == segments.length - 1 ? 0.0 : 2.0,
              ),
              child: SegmentedControlButton(
                label: segment.label,
                icon: segment.icon,
                isSelected: isSelected,
                onTap: isSelected ? null : () => onTap(index),
              ),
            ),
          );
        }),
      ),
    );
  }
}
