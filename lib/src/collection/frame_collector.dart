import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import '../models/models.dart';

/// Collects frame timings from the Flutter engine and converts them to [FrameTimingSample]s.
class FrameCollector {
  final PerfThresholds _thresholds;
  final SchedulerBinding _schedulerBinding;

  StreamController<FrameTimingSample>? _controller;
  bool _isRunning = false;

  /// Creates a [FrameCollector] with the given [thresholds].
  ///
  /// Optionally accepts a [SchedulerBinding] for testing purposes.
  FrameCollector({
    required PerfThresholds thresholds,
    @visibleForTesting SchedulerBinding? schedulerBinding,
  }) : _thresholds = thresholds,
       _schedulerBinding = schedulerBinding ?? SchedulerBinding.instance;

  /// Starts collecting frame timings.
  ///
  /// Throws a [StateError] if already running.
  void start() {
    if (_isRunning) {
      throw StateError('FrameCollector is already running.');
    }
    _isRunning = true;
    _controller = StreamController<FrameTimingSample>.broadcast();
    _schedulerBinding.addTimingsCallback(_onFrameTimings);
  }

  /// Stops collecting frame timings.
  void stop() {
    if (!_isRunning) return;
    _schedulerBinding.removeTimingsCallback(_onFrameTimings);
    _controller?.close();
    _controller = null;
    _isRunning = false;
  }

  /// The stream of captured frame timing samples.
  Stream<FrameTimingSample> get stream {
    if (_controller == null) {
      throw StateError('Cannot access stream before starting the collector.');
    }
    return _controller!.stream;
  }

  void _onFrameTimings(List<FrameTiming> timings) {
    if (_controller == null || _controller!.isClosed) return;

    for (final timing in timings) {
      final sample = FrameTimingSample(
        timing: timing,
        frameBudgetMs: _thresholds.frameBudgetMs,
      );
      _controller!.add(sample);
    }
  }
}
