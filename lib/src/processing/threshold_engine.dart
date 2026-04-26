import 'dart:async';
import '../models/models.dart';
import 'frame_aggregator.dart';

/// Evaluates [FrameReport]s against [PerfThresholds] and emits [FrameAlert]s.
class ThresholdEngine {
  final FrameAggregator _aggregator;
  final PerfThresholds _thresholds;

  StreamSubscription<FrameReport>? _subscription;
  StreamController<FrameAlert>? _controller;
  DateTime? _lastAlertTime;

  /// Creates a [ThresholdEngine] that listens to the given [_aggregator]
  /// and uses the given [_thresholds].
  ThresholdEngine({
    required FrameAggregator aggregator,
    required PerfThresholds thresholds,
  })  : _aggregator = aggregator,
        _thresholds = thresholds;

  /// Starts the engine.
  void start() {
    if (_controller != null) {
      throw StateError('ThresholdEngine is already running.');
    }
    _controller = StreamController<FrameAlert>.broadcast();
    _subscription = _aggregator.stream.listen(_onReport);
  }

  /// Stops the engine.
  void stop() {
    _subscription?.cancel();
    _subscription = null;
    _controller?.close();
    _controller = null;
    _lastAlertTime = null;
  }

  /// The stream of performance alerts.
  Stream<FrameAlert> get stream {
    if (_controller == null) {
      throw StateError('Cannot access stream before starting the engine.');
    }
    return _controller!.stream;
  }

  void _onReport(FrameReport report) {
    if (_controller == null || _controller!.isClosed) return;

    if (report.jankRate > _thresholds.jankRateLimit) {
      final now = DateTime.now();
      if (_lastAlertTime == null || now.difference(_lastAlertTime!) >= const Duration(seconds: 2)) {
        _lastAlertTime = now;
        
        final alert = FrameAlert(
          severity: AlertSeverity.warning,
          message: 'Jank rate limit exceeded: ${(report.jankRate * 100).toStringAsFixed(1)}% '
              '(Limit: ${(_thresholds.jankRateLimit * 100).toStringAsFixed(1)}%)',
          offendingSample: report.latestSample,
          reportAtAlert: report,
        );
        _controller!.add(alert);
      }
    }
  }
}
