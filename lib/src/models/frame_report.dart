import 'frame_timing_sample.dart';

/// A snapshot of performance metrics computed over a specific window of frames.
class FrameReport {
  /// The 50th percentile frame time in milliseconds.
  final double p50;

  /// The 95th percentile frame time in milliseconds.
  final double p95;

  /// The 99th percentile frame time in milliseconds.
  final double p99;

  /// The fraction of janky frames in the window (0.0 to 1.0).
  final double jankRate;

  /// The estimated number of dropped frames during this window.
  final int droppedFrames;

  /// The number of frames analyzed in this report.
  final int windowSize;

  /// The time this report was generated.
  final DateTime sampledAt;

  /// The most recent sample added to the window.
  final FrameTimingSample latestSample;

  /// Creates a new [FrameReport].
  const FrameReport({
    required this.p50,
    required this.p95,
    required this.p99,
    required this.jankRate,
    required this.droppedFrames,
    required this.windowSize,
    required this.sampledAt,
    required this.latestSample,
  });
}
