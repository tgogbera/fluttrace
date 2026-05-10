import 'dart:ui';

/// Configuration for frame timing monitoring thresholds.
class PerfThresholds {
  final double? _uiBudgetMs;
  final double? _rasterBudgetMs;
  final double? _frameBudgetMs;

  /// The threshold for the fraction of janky frames in a window (e.g., 0.05 for 5%).
  final double jankRateLimit;

  /// The number of frames to keep in the rolling window for aggregation.
  final int windowSize;

  /// Creates a new [PerfThresholds] configuration.
  /// If budgets are omitted, they will be dynamically resolved based on the device's refresh rate.
  const PerfThresholds({
    double? uiBudgetMs,
    double? rasterBudgetMs,
    double? frameBudgetMs,
    this.jankRateLimit = 0.05,
    this.windowSize = 120,
  })  : _uiBudgetMs = uiBudgetMs,
        _rasterBudgetMs = rasterBudgetMs,
        _frameBudgetMs = frameBudgetMs;

  double get _deviceRefreshRate {
    try {
      final views = PlatformDispatcher.instance.views;
      if (views.isNotEmpty) {
        final rate = views.first.display.refreshRate;
        if (rate > 0) return rate;
      }
    } catch (_) {}
    return 60.0;
  }

  /// The maximum allowed time for a single frame (UI + raster) in milliseconds.
  double get frameBudgetMs => _frameBudgetMs ?? (1000.0 / _deviceRefreshRate);

  /// The maximum allowed time for the UI thread to process a frame in milliseconds.
  double get uiBudgetMs => _uiBudgetMs ?? (frameBudgetMs / 2.0);

  /// The maximum allowed time for the raster thread to process a frame in milliseconds.
  double get rasterBudgetMs => _rasterBudgetMs ?? (frameBudgetMs / 2.0);
}
