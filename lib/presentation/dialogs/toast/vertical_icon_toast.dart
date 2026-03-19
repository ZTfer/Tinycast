import 'package:flutter/material.dart';

class VerticalIconToast extends StatelessWidget {
  final Widget icon;
  final double iconSize;
  final String text;
  final double textSize;

  const VerticalIconToast({
    super.key,
    required this.icon,
    this.iconSize = 16,
    required this.text,
    this.textSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 0.5,
          style: BorderStyle.solid,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8.0,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconTheme(
            data: IconThemeData(size: iconSize),
            child: icon,
          ),
          const SizedBox(height: 8.0),
          Text(
            text,
            style: TextStyle(
              fontSize: textSize,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF000000),
            ),
          ),
        ],
      ),
    );
  }
}
