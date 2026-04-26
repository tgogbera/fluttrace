import 'package:fluttrace/fluttrace.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'fluttrace_overlay_hud_panel.dart';

class FluttraceOverlayContent extends StatefulWidget {
  const FluttraceOverlayContent({Key? key}) : super(key: key);

  @override
  State<FluttraceOverlayContent> createState() =>
      _FluttraceOverlayContentState();
}

class _FluttraceOverlayContentState extends State<FluttraceOverlayContent> {
  static const List<String> _levelNames = <String>[
    'Off',
    'Basic',
    'Detailed',
    'Advanced',
  ];

  double _hudLevel = 1;

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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            constraints: BoxConstraints(
              minWidth: _hudLevel.toInt() == 0 ? 230 : 260,
              maxWidth: _hudLevel.toInt() >= 2 ? 430 : 330,
            ),
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
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isJanky ? Icons.warning_amber_rounded : Icons.speed,
                      color: isJanky ? Colors.redAccent : Colors.greenAccent,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Fluttrace HUD',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _levelNames[_hudLevel.toInt()],
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                CupertinoTheme(
                  data: CupertinoThemeData(
                    primaryColor: isJanky
                        ? Colors.redAccent
                        : Colors.greenAccent,
                  ),
                  child: CupertinoSlider(
                    value: _hudLevel,
                    min: 0,
                    max: 3,
                    divisions: 3,
                    activeColor: isJanky
                        ? Colors.redAccent
                        : Colors.greenAccent,
                    onChanged: (value) {
                      setState(() {
                        _hudLevel = value.roundToDouble();
                      });
                    },
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  child: FluttraceOverlayHudPanel(
                    report: report,
                    isJanky: isJanky,
                    level: _hudLevel.toInt(),
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
