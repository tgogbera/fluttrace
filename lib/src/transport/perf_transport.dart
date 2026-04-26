import '../models/models.dart';

/// Defines a transport mechanism for sending performance reports and alerts.
abstract class PerfTransport {
  /// Called when a new [FrameReport] is available.
  Future<void> send(FrameReport report);

  /// Called when a [FrameAlert] is triggered.
  Future<void> onAlert(FrameAlert alert);

  /// Called when the transport should be disposed.
  Future<void> dispose();
}
