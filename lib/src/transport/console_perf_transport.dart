import 'package:flutter/foundation.dart';
import '../models/models.dart';
import 'perf_transport.dart';

/// A transport that prints performance metrics to the console using [debugPrint].
class ConsolePerfTransport implements PerfTransport {
  /// Whether to force printing in release mode. By default, it only prints in debug mode.
  final bool forceInRelease;

  /// Creates a [ConsolePerfTransport].
  const ConsolePerfTransport({this.forceInRelease = false});

  @override
  Future<void> send(FrameReport report) async {
    if (!kDebugMode && !forceInRelease) return;

    final p50 = report.p50.toStringAsFixed(1);
    final p95 = report.p95.toStringAsFixed(1);
    final p99 = report.p99.toStringAsFixed(1);
    final jankRate = (report.jankRate * 100).toStringAsFixed(1);

    debugPrint(
      '[Fluttrace] Window: ${report.windowSize} frames | '
      'p50: ${p50}ms | p95: ${p95}ms | p99: ${p99}ms | '
      'Jank: $jankRate% | Dropped: ${report.droppedFrames}',
    );
  }

  @override
  Future<void> onAlert(FrameAlert alert) async {
    if (!kDebugMode && !forceInRelease) return;

    final severityStr = alert.severity == AlertSeverity.critical
        ? 'CRITICAL'
        : 'WARNING';
    debugPrint('[Fluttrace ALERT - $severityStr] ${alert.message}');
  }

  @override
  Future<void> dispose() async {
    // Nothing to dispose
  }
}
