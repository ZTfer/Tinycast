/// Identifies whether the current isolate is the main app window.
///
/// Secondary desktop windows use separate [ProviderScope]s; playback restore
/// and background schedulers should only run in the main window.
class AppWindowContext {
  AppWindowContext._();

  static bool isMainWindow = true;
}
