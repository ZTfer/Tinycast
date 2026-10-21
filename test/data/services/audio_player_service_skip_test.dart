import 'package:flutter_test/flutter_test.dart';
import 'package:tinycast/data/services/audio_player_service.dart';

void main() {
  group('resolveSkipTarget', () {
    test('快进按配置时长向后移动', () {
      final target = resolveSkipTarget(
        position: const Duration(seconds: 10),
        duration: const Duration(minutes: 10),
        offset: const Duration(seconds: 30),
      );

      expect(target, const Duration(seconds: 40));
    });

    test('回退不会越过开头', () {
      final target = resolveSkipTarget(
        position: const Duration(seconds: 10),
        duration: const Duration(minutes: 10),
        offset: const Duration(seconds: -15),
      );

      expect(target, Duration.zero);
    });

    test('快进不会越过结尾', () {
      final target = resolveSkipTarget(
        position: const Duration(seconds: 50),
        duration: const Duration(minutes: 1),
        offset: const Duration(seconds: 30),
      );

      expect(target, const Duration(minutes: 1));
    });

    test('时长未知时只限制下界', () {
      final target = resolveSkipTarget(
        position: const Duration(seconds: 5),
        duration: null,
        offset: const Duration(seconds: 30),
      );

      expect(target, const Duration(seconds: 35));
    });
  });
}
