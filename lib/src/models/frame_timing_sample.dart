import 'dart:ui';

/// A wrapper around Flutter's [FrameTiming] that exposes wall-clock times in milliseconds.
class FrameTimingSample {
  /// The time spent on the UI thread in milliseconds.
  final double uiMs;

  /// The time spent on the raster thread in milliseconds.
  final double rasterMs;

  /// The total time spent processing the frame in milliseconds.
  final double totalMs;

  /// Whether the frame exceeded the budgeted time.
  final bool isJanky;

  /// The time the frame was recorded.
  final DateTime timestamp;

  /// Creates a [FrameTimingSample] from a given [FrameTiming].
  FrameTimingSample({
    required FrameTiming timing,
    required double frameBudgetMs,
  })  : uiMs = timing.buildDuration.inMicroseconds / 1000.0,
        rasterMs = timing.rasterDuration.inMicroseconds / 1000.0,
        totalMs = timing.totalSpan.inMicroseconds / 1000.0,
        isJanky = (timing.totalSpan.inMicroseconds / 1000.0) > frameBudgetMs,
        timestamp = DateTime.now();
}
