import 'dart:async';
import '../collection/frame_collector.dart';
import '../models/models.dart';

/// Aggregates frame timing samples over a sliding window and emits [FrameReport]s.
class FrameAggregator {
  final FrameCollector _collector;
  final PerfThresholds _thresholds;

  StreamSubscription<FrameTimingSample>? _subscription;
  StreamController<FrameReport>? _controller;

  late final List<FrameTimingSample?> _buffer;
  int _currentIndex = 0;
  int _count = 0;

  /// Creates a [FrameAggregator] that listens to the given [_collector]
  /// and uses the given [_thresholds].
  FrameAggregator({
    required FrameCollector collector,
    required PerfThresholds thresholds,
  }) : _collector = collector,
       _thresholds = thresholds {
    _buffer = List<FrameTimingSample?>.filled(_thresholds.windowSize, null);
  }

  /// Starts the aggregator.
  void start() {
    if (_controller != null) {
      throw StateError('FrameAggregator is already running.');
    }
    _controller = StreamController<FrameReport>.broadcast();
    _subscription = _collector.stream.listen(_onSample);
  }

  /// Stops the aggregator.
  void stop() {
    _subscription?.cancel();
    _subscription = null;
    _controller?.close();
    _controller = null;
    _buffer.fillRange(0, _buffer.length, null);
    _currentIndex = 0;
    _count = 0;
  }

  /// The stream of performance reports.
  Stream<FrameReport> get stream {
    if (_controller == null) {
      throw StateError('Cannot access stream before starting the aggregator.');
    }
    return _controller!.stream;
  }

  void _onSample(FrameTimingSample sample) {
    if (_controller == null || _controller!.isClosed) return;

    _buffer[_currentIndex] = sample;
    _currentIndex = (_currentIndex + 1) % _thresholds.windowSize;
    if (_count < _thresholds.windowSize) {
      _count++;
    }

    if (_count > 0) {
      _controller!.add(_computeReport(sample));
    }
  }

  FrameReport _computeReport(FrameTimingSample latestSample) {
    final List<double> totals = List<double>.generate(
      _count,
      (i) => _buffer[i]!.totalMs,
      growable: false,
    );
    totals.sort();

    int jankyFrames = 0;
    int droppedFrames = 0;

    for (int i = 0; i < _count; i++) {
      final sample = _buffer[i]!;
      if (sample.isJanky) {
        jankyFrames++;
        droppedFrames +=
            ((sample.totalMs / _thresholds.frameBudgetMs).ceil() - 1);
      }
    }

    final double p50 = totals[(_count * 0.50).floor()];
    final double p95 = totals[(_count * 0.95).floor()];
    final double p99 = totals[(_count * 0.99).floor()];
    final double jankRate = jankyFrames / _count;

    final oldestSample = _count < _thresholds.windowSize
        ? _buffer[0]!
        : _buffer[_currentIndex]!;

    double fps = 0.0;
    if (_count > 1) {
      final elapsedMs = latestSample.timestamp
          .difference(oldestSample.timestamp)
          .inMilliseconds;
      if (elapsedMs > 0) {
        fps = ((_count - 1) * 1000.0) / elapsedMs;
      }
    }

    return FrameReport(
      fps: fps,
      p50: p50,
      p95: p95,
      p99: p99,
      jankRate: jankRate,
      droppedFrames: droppedFrames,
      windowSize: _count,
      sampledAt: DateTime.now(),
      latestSample: latestSample,
    );
  }
}
