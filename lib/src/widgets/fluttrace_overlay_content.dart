import 'package:fluttrace/fluttrace.dart';
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

        return ValueListenableBuilder<int>(
          valueListenable: FluttraceHudController.instance.level,
          builder: (context, level, _) {
            if (level == 0) {
              return const SizedBox.shrink();
            }

            return Material(
              color: Colors.transparent,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                constraints: BoxConstraints(
                  minWidth: 260,
                  maxWidth: level >= 2 ? 430 : 330,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
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
                          color: isJanky
                              ? Colors.redAccent
                              : Colors.greenAccent,
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
                          _levelNames[level],
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      child: FluttraceOverlayHudPanel(
                        report: report,
                        isJanky: isJanky,
                        level: level,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
