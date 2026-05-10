import 'package:flutter/material.dart';

import 'fluttrace_overlay_content.dart';

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
  Offset _dragOffset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          widget.child,
          Positioned.fill(
            child: Transform.translate(
              offset: _dragOffset,
              child: Align(
                alignment: widget.alignment,
                child: SafeArea(
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        _dragOffset += details.delta;
                      });
                    },
                    child: const Material(
                      type: MaterialType.transparency,
                      child: FluttraceOverlayContent(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
