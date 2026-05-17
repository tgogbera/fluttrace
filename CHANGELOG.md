## 1.1.2

* Fix: Resolved an issue where the demo GIF would not display correctly on pub.dev by using an absolute URL.

## 1.1.1

* Docs: Added demo GIF to README to showcase the performance HUD.

## 1.1.0

* Feature: Added real-time visual framerate graph (`FluttraceFpsGraph`) to the Advanced HUD level.
* Enhancement: Improved `FluttraceMetricTile` UI stability by adding a minimum width to prevent text layout jumps.

## 1.0.3

* Feature: `PerfThresholds` now dynamically resolves the device's hardware refresh rate natively, automatically adapting FPS and jank calculations to 120Hz/ProMotion displays without configuration.

## 1.0.2

* Feature: `FluttraceOverlay` is now continuously draggable across the screen.
* Fix: FPS estimation metric heavily improved. FPS is now accurately calculated using active frame durations rather than wall-clock time, preventing misleading drops in the metric when the app is idle.
* Fix: Frame timestamps now use the engine's exact `FramePhase.buildStart` rather than `DateTime.now()` to prevent inaccuracies from asynchronous batch delivery of frame timings.

## 1.0.1

* Fix: `FluttraceOverlay` FPS estimation metric now correctly calculates using window timestamps instead of max theoretical frames.

## 1.0.0
* Initial release. Includes:
  * Frame Collector for retrieving frame timing data.
  * Aggregator to compute p50, p95, p99 metrics.
  * Threshold Engine for jank detection.
  * Pluggable transport system (`PerfTransport`).
  * Real-time performance HUD overlay (`FluttraceOverlay`).
