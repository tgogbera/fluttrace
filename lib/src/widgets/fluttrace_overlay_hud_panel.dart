import 'package:fluttrace/fluttrace.dart';
import 'package:flutter/material.dart';

class FluttraceOverlayHudPanel extends StatelessWidget {
  const FluttraceOverlayHudPanel({
    super.key,
    required this.report,
    required this.isJanky,
    required this.level,
  });

  final FrameReport report;
  final bool isJanky;
  final int level;

  String _formatMs(double value) => '${value.toStringAsFixed(1)}ms';

  double _estimateFps() {
    if (report.p50 <= 0) {
      return 0;
    }
    return 1000.0 / report.p50;
  }

  @override
  Widget build(BuildContext context) {
    final fps = _estimateFps();

    if (level == 0) {
      return const SizedBox.shrink();
    }

    if (level == 1) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FluttraceMetricTile(label: 'FPS', value: fps.toStringAsFixed(0)),
          const SizedBox(width: 8),
          FluttraceMetricTile(
            label: 'JANK',
            value: '${(report.jankRate * 100).toStringAsFixed(1)}%',
            valueColor: isJanky ? Colors.redAccent : Colors.greenAccent,
          ),
        ],
      );
    }

    if (level == 2) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FluttraceMetricTile(label: 'FPS', value: fps.toStringAsFixed(0)),
              FluttraceMetricTile(label: 'P50', value: _formatMs(report.p50)),
              FluttraceMetricTile(label: 'P95', value: _formatMs(report.p95)),
              FluttraceMetricTile(
                label: 'JANK',
                value: '${(report.jankRate * 100).toStringAsFixed(1)}%',
                valueColor: isJanky ? Colors.redAccent : Colors.greenAccent,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Dropped ${report.droppedFrames} frames in last ${report.windowSize} samples',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontFamily: 'monospace',
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FluttraceMetricTile(label: 'FPS', value: fps.toStringAsFixed(0)),
            FluttraceMetricTile(label: 'P50', value: _formatMs(report.p50)),
            FluttraceMetricTile(label: 'P95', value: _formatMs(report.p95)),
            FluttraceMetricTile(label: 'P99', value: _formatMs(report.p99)),
            FluttraceMetricTile(
              label: 'UI',
              value: _formatMs(report.latestSample.uiMs),
            ),
            FluttraceMetricTile(
              label: 'RASTER',
              value: _formatMs(report.latestSample.rasterMs),
            ),
            FluttraceMetricTile(
              label: 'TOTAL',
              value: _formatMs(report.latestSample.totalMs),
            ),
            FluttraceMetricTile(
              label: 'JANK',
              value: '${(report.jankRate * 100).toStringAsFixed(1)}%',
              valueColor: isJanky ? Colors.redAccent : Colors.greenAccent,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Dropped ${report.droppedFrames} frames in last ${report.windowSize} samples',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}

class FluttraceMetricTile extends StatelessWidget {
  const FluttraceMetricTile({
    super.key,
    required this.label,
    required this.value,
    this.valueColor = Colors.white,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 12,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
