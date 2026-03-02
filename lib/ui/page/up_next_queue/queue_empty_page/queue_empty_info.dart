import 'package:flutter/widgets.dart';

class QueueEmptyInfo extends StatelessWidget {
  const QueueEmptyInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        SizedBox(height: 24),
        SizedBox(
          width: 120,
          height: 120,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0xFFE0E0E0),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
        SizedBox(height: 24),
        Text('No upcoming episodes'),
        Text('Add episodes to your queue to start listening'),
      ],
    );
  }
}
