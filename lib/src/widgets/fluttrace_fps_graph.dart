import 'package:flutter/material.dart';
import 'package:fluttrace/src/models/frame_report.dart';

class FluttraceFpsGraph extends StatefulWidget {
  const FluttraceFpsGraph({super.key, required this.report});

  final FrameReport report;

  @override
  State<FluttraceFpsGraph> createState() => _FluttraceFpsGraphState();
}

class _FluttraceFpsGraphState extends State<FluttraceFpsGraph> {
  final List<double> _fpsHistory = [];
  final int _maxHistory = 60;

  @override
  void initState() {
    super.initState();
    _fpsHistory.add(widget.report.fps);
  }

  @override
  void didUpdateWidget(FluttraceFpsGraph oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.report.sampledAt != widget.report.sampledAt) {
      setState(() {
        _fpsHistory.add(widget.report.fps);
        if (_fpsHistory.length > _maxHistory) {
          _fpsHistory.removeAt(0);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.only(top: 8, bottom: 4, left: 4, right: 4),
      child: CustomPaint(
        painter: _FpsGraphPainter(
          fpsHistory: _fpsHistory,
          maxHistory: _maxHistory,
        ),
      ),
    );
  }
}

class _FpsGraphPainter extends CustomPainter {
  final List<double> fpsHistory;
  final int maxHistory;

  _FpsGraphPainter({required this.fpsHistory, required this.maxHistory});

  @override
  void paint(Canvas canvas, Size size) {
    if (fpsHistory.isEmpty) return;

    final paint = Paint()
      ..color = Colors.cyanAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final gradient = LinearGradient(
      colors: [
        Colors.cyanAccent.withValues(alpha: 0.4),
        Colors.cyanAccent.withValues(alpha: 0.0),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    final fillPaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      )
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = Colors.white12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    double maxFps = 60.0;
    for (final fps in fpsHistory) {
      if (fps > maxFps) maxFps = fps;
    }
    maxFps = maxFps * 1.1;

    double getY(double fps) => size.height - (fps / maxFps) * size.height;

    final y60 = getY(60.0);
    final y30 = getY(30.0);

    canvas.drawLine(Offset(0, y60), Offset(size.width, y60), gridPaint);
    canvas.drawLine(Offset(0, y30), Offset(size.width, y30), gridPaint);
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      gridPaint,
    );

    final path = Path();
    final fillPath = Path();

    final widthStep = size.width / (maxHistory - 1);

    double startX = size.width - ((fpsHistory.length - 1) * widthStep);
    if (startX < 0) startX = 0;

    path.moveTo(startX, getY(fpsHistory.first));
    fillPath.moveTo(startX, size.height);
    fillPath.lineTo(startX, getY(fpsHistory.first));

    for (int i = 1; i < fpsHistory.length; i++) {
      final x = startX + i * widthStep;
      final y = getY(fpsHistory[i]);

      final prevX = startX + (i - 1) * widthStep;
      final prevY = getY(fpsHistory[i - 1]);

      final cp1x = prevX + (x - prevX) / 2;
      final cp1y = prevY;

      final cp2x = prevX + (x - prevX) / 2;
      final cp2y = y;

      path.cubicTo(cp1x, cp1y, cp2x, cp2y, x, y);
      fillPath.cubicTo(cp1x, cp1y, cp2x, cp2y, x, y);
    }

    fillPath.lineTo(startX + (fpsHistory.length - 1) * widthStep, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _FpsGraphPainter oldDelegate) {
    return true;
  }
}
