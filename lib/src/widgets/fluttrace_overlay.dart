import 'package:flutter/material.dart';
import 'package:fluttrace/fluttrace.dart';

/// A widget that displays real-time frame timing metrics in an overlay.
///
/// Wrap this around your app's root widget or use it in the `builder`
/// of your `MaterialApp`.
class FluttraceOverlay extends StatefulWidget {
  /// The widget below this widget in the tree.
  final Widget child;

  /// Where to place the overlay on the screen. Defaults to [Alignment.topCenter].
  final Alignment alignment;

  /// Creates a [FluttraceOverlay].
  const FluttraceOverlay({
    Key? key,
    required this.child,
    this.alignment = Alignment.topCenter,
  }) : super(key: key);

  @override
  State<FluttraceOverlay> createState() => _FluttraceOverlayState();
}

class _FluttraceOverlayState extends State<FluttraceOverlay> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          widget.child,
          Align(
            alignment: widget.alignment,
            child: const SafeArea(
              child: _FluttraceOverlayContent(),
            ),
          ),
        ],
      ),
    );
  }
}

class _FluttraceOverlayContent extends StatefulWidget {
  const _FluttraceOverlayContent({Key? key}) : super(key: key);

  @override
  State<_FluttraceOverlayContent> createState() => _FluttraceOverlayContentState();
}

class _FluttraceOverlayContentState extends State<_FluttraceOverlayContent> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FrameReport>(
      stream: Fluttrace.instance.reportStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final report = snapshot.data!;
        final isJanky = report.jankRate > 0.05; // > 5% jank is warning

        return Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isJanky ? Colors.redAccent : Colors.greenAccent,
                width: 2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isJanky ? Icons.warning_amber_rounded : Icons.speed,
                      color: isJanky ? Colors.redAccent : Colors.greenAccent,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Fluttrace',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'p50: ${report.p50.toStringAsFixed(1)}ms | p95: ${report.p95.toStringAsFixed(1)}ms',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
                Text(
                  'Jank: ${(report.jankRate * 100).toStringAsFixed(1)}% | Dropped: ${report.droppedFrames}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
