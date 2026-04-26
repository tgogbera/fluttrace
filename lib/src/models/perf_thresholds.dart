/// Configuration for frame timing monitoring thresholds.
class PerfThresholds {
  /// The maximum allowed time for the UI thread to process a frame in milliseconds.
  final double uiBudgetMs;

  /// The maximum allowed time for the raster thread to process a frame in milliseconds.
  final double rasterBudgetMs;

  /// The maximum allowed time for a single frame (UI + raster) in milliseconds.
  final double frameBudgetMs;

  /// The threshold for the fraction of janky frames in a window (e.g., 0.05 for 5%).
  final double jankRateLimit;

  /// The number of frames to keep in the rolling window for aggregation.
  final int windowSize;

  /// Creates a new [PerfThresholds] configuration.
  const PerfThresholds({
    this.uiBudgetMs = 8.0,
    this.rasterBudgetMs = 8.0,
    this.frameBudgetMs = 16.67,
    this.jankRateLimit = 0.05,
    this.windowSize = 120,
  });
}
