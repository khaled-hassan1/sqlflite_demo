/// Animation and debounce timings.
abstract final class AppDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);

  static const Duration searchDebounce = Duration(milliseconds: 250);
  static const Duration autosaveDebounce = Duration(milliseconds: 600);
  static const Duration amplitudeInterval = Duration(milliseconds: 90);
  static const Duration snackBar = Duration(seconds: 3);
  static const Duration seekStep = Duration(seconds: 5);
}
