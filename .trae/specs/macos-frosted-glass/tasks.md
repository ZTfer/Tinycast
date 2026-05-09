# Tasks
- [x] Task 1: Add macos_window_utils dependency
  - [x] SubTask 1.1: Run `flutter pub add macos_window_utils` to add the package
  - [x] SubTask 1.2: Verify pubspec.yaml contains the dependency
- [ ] Task 2: Create macos_window_utils.dart file
  - [ ] SubTask 2.1: Create `lib/macos_window_utils.dart` file
  - [ ] SubTask 2.2: Implement `applyFrostedGlassEffect()` method using `WindowManipulator.setWindowMaterial()`
  - [ ] SubTask 2.3: Implement `initMacosWindow()` helper method
- [ ] Task 3: Update multi_window.dart to use macos_window_utils
  - [ ] SubTask 3.1: Import macos_window_utils.dart in multi_window.dart
  - [ ] SubTask 3.2: Update window initialization methods to call frosted glass setup
- [ ] Task 4: Verify implementation
  - [ ] SubTask 4.1: Run `flutter analyze` to check for errors
  - [ ] SubTask 4.2: Verify the code compiles successfully

# Task Dependencies
- [Task 2] depends on [Task 1]
- [Task 3] depends on [Task 2]
- [Task 4] depends on [Task 3]
