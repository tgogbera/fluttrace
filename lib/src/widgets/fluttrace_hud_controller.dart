import 'package:flutter/foundation.dart';

/// Shared state for controlling the Fluttrace HUD level from anywhere.
class FluttraceHudController {
  FluttraceHudController._();

  /// Global singleton used by the overlay and control widgets.
  static final FluttraceHudController instance = FluttraceHudController._();

  /// 0: Off, 1: Basic, 2: Detailed, 3: Advanced.
  final ValueNotifier<int> level = ValueNotifier<int>(1);

  void setLevel(int nextLevel) {
    level.value = nextLevel.clamp(0, 3);
  }
}
