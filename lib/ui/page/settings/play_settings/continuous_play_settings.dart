import 'package:flutter/widgets.dart';
import 'package:tinycast/ui/common_widgets/radio/label_radio.dart';

enum ContinuousPlayOption { continuePlaying, stopPlaying }

class ContinuousPlaySettings extends StatefulWidget {
  const ContinuousPlaySettings({super.key});

  @override
  State<ContinuousPlaySettings> createState() => _ContinuousPlaySettingsState();
}

class _ContinuousPlaySettingsState extends State<ContinuousPlaySettings> {
  ContinuousPlayOption _selectedOption = ContinuousPlayOption.continuePlaying;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 4.0),
        LabelRadio(
          value: _selectedOption == ContinuousPlayOption.continuePlaying,
          label: '单集结束后继续播放',
          onChanged: (bool newValue) {
            if (newValue) {
              setState(() {
                _selectedOption = ContinuousPlayOption.continuePlaying;
              });
            }
          },
        ),
        const SizedBox(height: 4.0),
        LabelRadio(
          value: _selectedOption == ContinuousPlayOption.stopPlaying,
          label: '单集结束后停止',
          onChanged: (bool newValue) {
            if (newValue) {
              setState(() {
                _selectedOption = ContinuousPlayOption.stopPlaying;
              });
            }
          },
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }
}
