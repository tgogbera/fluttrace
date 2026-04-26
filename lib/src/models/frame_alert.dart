import 'frame_report.dart';
import 'frame_timing_sample.dart';

/// The severity level of a frame timing alert.
enum AlertSeverity {
  /// A warning alert, typically when thresholds are close to being breached or lightly breached.
  warning,
  
  /// A critical alert, typically for severe jank or high dropped frames.
  critical,
}

/// Represents an alert triggered when performance thresholds are exceeded.
class FrameAlert {
  /// The severity of the alert.
  final AlertSeverity severity;

  /// A descriptive message detailing the reason for the alert.
  final String message;

  /// The sample that triggered this alert.
  final FrameTimingSample offendingSample;

  /// The performance report at the time the alert was triggered.
  final FrameReport reportAtAlert;

  /// Creates a new [FrameAlert].
  const FrameAlert({
    required this.severity,
    required this.message,
    required this.offendingSample,
    required this.reportAtAlert,
  });
}
