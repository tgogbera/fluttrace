import 'package:flutter/material.dart';

import 'fluttrace_hud_controller.dart';

/// Standalone slider that controls the shared Fluttrace HUD level.
class FluttraceHudLevelSlider extends StatelessWidget {
  const FluttraceHudLevelSlider({super.key});

  static const List<String> _levelNames = <String>[
    'Off',
    'Basic',
    'Detailed',
    'Advanced',
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: FluttraceHudController.instance.level,
      builder: (context, level, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text(
                  'HUD Level',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 8),
                Text(
                  _levelNames[level],
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ],
            ),
            Slider(
              value: level.toDouble(),
              min: 0,
              max: 3,
              divisions: 3,
              label: _levelNames[level],
              onChanged: (value) {
                FluttraceHudController.instance.setLevel(value.round());
              },
            ),
          ],
        );
      },
    );
  }
}
