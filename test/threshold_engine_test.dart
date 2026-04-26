import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttrace/src/models/models.dart';
import 'package:fluttrace/src/processing/frame_aggregator.dart';
import 'package:fluttrace/src/processing/threshold_engine.dart';
import 'package:mocktail/mocktail.dart';

class MockFrameAggregator extends Mock implements FrameAggregator {}
class MockFrameTimingSample extends Mock implements FrameTimingSample {}

void main() {
  late MockFrameAggregator mockAggregator;
  late StreamController<FrameReport> streamController;

  setUp(() {
    mockAggregator = MockFrameAggregator();
    streamController = StreamController<FrameReport>.broadcast();
    when(() => mockAggregator.stream).thenAnswer((_) => streamController.stream);
  });

  tearDown(() {
    streamController.close();
  });

  test('Emits alert when jank rate exceeds limit and debounces', () async {
    const thresholds = PerfThresholds(jankRateLimit: 0.1);
    final engine = ThresholdEngine(aggregator: mockAggregator, thresholds: thresholds);
    
    final alerts = <FrameAlert>[];
    engine.start();
    final sub = engine.stream.listen(alerts.add);

    final dummySample = MockFrameTimingSample();

    streamController.add(FrameReport(
      p50: 10, p95: 15, p99: 20, jankRate: 0.15, droppedFrames: 5, windowSize: 100, sampledAt: DateTime.now(), latestSample: dummySample,
    ));

    await Future.delayed(Duration.zero);
    expect(alerts.length, 1);

    streamController.add(FrameReport(
      p50: 10, p95: 15, p99: 20, jankRate: 0.20, droppedFrames: 8, windowSize: 100, sampledAt: DateTime.now(), latestSample: dummySample,
    ));

    await Future.delayed(Duration.zero);
    expect(alerts.length, 1); // Debounced

    await Future.delayed(const Duration(seconds: 2, milliseconds: 50));

    streamController.add(FrameReport(
      p50: 10, p95: 15, p99: 20, jankRate: 0.20, droppedFrames: 8, windowSize: 100, sampledAt: DateTime.now(), latestSample: dummySample,
    ));

    await Future.delayed(Duration.zero);
    expect(alerts.length, 2);

    await sub.cancel();
    engine.stop();
  });
}
