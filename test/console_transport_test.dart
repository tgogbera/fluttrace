import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttrace/src/models/models.dart';
import 'package:fluttrace/src/transport/console_perf_transport.dart';
import 'package:mocktail/mocktail.dart';

class MockFrameTimingSample extends Mock implements FrameTimingSample {}

void main() {
  test('send calls debugPrint', () async {
    const transport = ConsolePerfTransport(forceInRelease: true);
    final dummySample = MockFrameTimingSample();

    final report = FrameReport(
      p50: 10.1,
      p95: 15.2,
      p99: 20.3,
      jankRate: 0.05,
      droppedFrames: 2,
      windowSize: 120,
      sampledAt: DateTime.now(),
      latestSample: dummySample,
    );

    final logs = <String>[];
    final originalDebugPrint = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) {
      if (message != null) logs.add(message);
    };

    await transport.send(report);

    debugPrint = originalDebugPrint;

    expect(logs.length, 1);
    expect(logs.first, contains('p50: 10.1ms'));
    expect(logs.first, contains('p95: 15.2ms'));
    expect(logs.first, contains('p99: 20.3ms'));
    expect(logs.first, contains('Jank: 5.0%'));
  });
}
