import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttrace/src/collection/frame_collector.dart';
import 'package:fluttrace/src/models/models.dart';
import 'package:fluttrace/src/processing/frame_aggregator.dart';
import 'package:mocktail/mocktail.dart';

class MockFrameCollector extends Mock implements FrameCollector {}
class MockFrameTimingSample extends Mock implements FrameTimingSample {}

void main() {
  late MockFrameCollector mockCollector;
  late StreamController<FrameTimingSample> streamController;

  setUp(() {
    mockCollector = MockFrameCollector();
    streamController = StreamController<FrameTimingSample>.broadcast();
    when(() => mockCollector.stream).thenAnswer((_) => streamController.stream);
  });

  tearDown(() {
    streamController.close();
  });

  test('Computes p50, p95, p99 correctly', () async {
    const thresholds = PerfThresholds(windowSize: 100);
    final aggregator = FrameAggregator(collector: mockCollector, thresholds: thresholds);
    
    final reports = <FrameReport>[];
    aggregator.start();
    final sub = aggregator.stream.listen(reports.add);

    // Feed 100 samples with totalMs from 1 to 100
    for (int i = 1; i <= 100; i++) {
      final sample = MockFrameTimingSample();
      when(() => sample.totalMs).thenReturn(i.toDouble());
      when(() => sample.isJanky).thenReturn(false);
      streamController.add(sample);
    }

    // Wait for microtasks to process stream
    await Future.delayed(Duration.zero);
    
    expect(reports.isNotEmpty, isTrue);
    final finalReport = reports.last;
    
    expect(finalReport.windowSize, 100);
    expect(finalReport.p50, 51.0); // 100 * 0.50 = 50 -> index 50 is value 51
    expect(finalReport.p95, 96.0); // 100 * 0.95 = 95 -> index 95 is value 96
    expect(finalReport.p99, 100.0); // 100 * 0.99 = 99 -> index 99 is value 100
    expect(finalReport.jankRate, 0.0);
    
    await sub.cancel();
    aggregator.stop();
  });
}
