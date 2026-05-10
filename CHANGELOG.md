## 1.0.1

* Fix: `FluttraceOverlay` FPS estimation metric now correctly calculates using window timestamps instead of max theoretical frames.

## 1.0.0
* Initial release. Includes:
  * Frame Collector for retrieving frame timing data.
  * Aggregator to compute p50, p95, p99 metrics.
  * Threshold Engine for jank detection.
  * Pluggable transport system (`PerfTransport`).
  * Real-time performance HUD overlay (`FluttraceOverlay`).
