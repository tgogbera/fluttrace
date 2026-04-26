import 'dart:async';
import 'package:flutter/foundation.dart';

import 'collection/frame_collector.dart';
import 'models/models.dart';
import 'processing/frame_aggregator.dart';
import 'processing/threshold_engine.dart';
import 'transport/perf_transport.dart';

/// The main entry point for the Fluttrace performance monitor.
class Fluttrace {
  static Fluttrace? _instance;

  /// Returns the singleton instance of [Fluttrace].
  static Fluttrace get instance {
    _instance ??= Fluttrace._();
    return _instance!;
  }

  Fluttrace._();

  FrameCollector? _collector;
  FrameAggregator? _aggregator;
  ThresholdEngine? _engine;

  StreamSubscription<FrameReport>? _reportSubscription;
  StreamSubscription<FrameAlert>? _alertSubscription;

  final List<PerfTransport> _transports = [];
  bool _isRunning = false;
  FrameReport? _latestReport;

  /// Starts the performance monitor.
  ///
  /// You can optionally provide custom [thresholds].
  Future<void> start({PerfThresholds? thresholds}) async {
    if (_isRunning) return;

    final config = thresholds ?? const PerfThresholds();

    _collector = FrameCollector(thresholds: config);
    _aggregator = FrameAggregator(collector: _collector!, thresholds: config);
    _engine = ThresholdEngine(aggregator: _aggregator!, thresholds: config);

    _collector!.start();
    _aggregator!.start();
    _engine!.start();

    _reportSubscription = _aggregator!.stream.listen((report) {
      _latestReport = report;
      for (final transport in _transports) {
        transport.send(report).catchError((e) {
          debugPrint('Fluttrace transport error: $e');
        });
      }
    });

    _alertSubscription = _engine!.stream.listen((alert) {
      for (final transport in _transports) {
        transport.onAlert(alert).catchError((e) {
          debugPrint('Fluttrace transport error: $e');
        });
      }
    });

    _isRunning = true;
  }

  /// Stops the performance monitor.
  Future<void> stop() async {
    if (!_isRunning) return;

    _collector?.stop();
    _engine?.stop();
    _aggregator?.stop();

    await _reportSubscription?.cancel();
    await _alertSubscription?.cancel();

    _reportSubscription = null;
    _alertSubscription = null;

    _collector = null;
    _aggregator = null;
    _engine = null;
    
    _isRunning = false;
  }

  /// Returns the latest [FrameReport] snapshot, or null if no report is available.
  FrameReport? snapshot() => _latestReport;

  /// The stream of performance reports.
  Stream<FrameReport> get reportStream {
    if (_aggregator == null) {
      throw StateError('Fluttrace must be started before accessing reportStream.');
    }
    return _aggregator!.stream;
  }

  /// The stream of performance alerts.
  Stream<FrameAlert> get alertStream {
    if (_engine == null) {
      throw StateError('Fluttrace must be started before accessing alertStream.');
    }
    return _engine!.stream;
  }

  /// Adds a [transport] to receive reports and alerts.
  void addTransport(PerfTransport transport) {
    if (!_transports.contains(transport)) {
      _transports.add(transport);
    }
  }

  /// Removes a [transport].
  void removeTransport(PerfTransport transport) {
    _transports.remove(transport);
  }
}
