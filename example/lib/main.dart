import 'package:flutter/material.dart';
import 'package:fluttrace/fluttrace.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Fluttrace.instance.addTransport(ConsolePerfTransport());
  await Fluttrace.instance.start();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fluttrace Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      builder: (context, child) => FluttraceOverlay(child: child!),
      home: const MyHomePage(title: 'Fluttrace Overlay Playground'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  bool _autoStress = false;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _simulateJank([int milliseconds = 45]) {
    final stopTime = DateTime.now().add(Duration(milliseconds: milliseconds));
    while (DateTime.now().isBefore(stopTime)) {
      // Intentional busy loop for demo/testing of performance overlay.
    }
  }

  Future<void> _runBurstStress() async {
    for (var i = 0; i < 20; i++) {
      if (!mounted) {
        return;
      }
      _simulateJank(35 + (i % 3) * 10);
      setState(() {
        _counter++;
      });
      await Future<void>.delayed(const Duration(milliseconds: 60));
    }
  }

  Future<void> _toggleAutoStress(bool value) async {
    setState(() {
      _autoStress = value;
    });

    while (_autoStress && mounted) {
      _simulateJank(25);
      setState(() {
        _counter++;
      });
      await Future<void>.delayed(const Duration(milliseconds: 80));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Use the HUD slider at the top to switch levels:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            const Text('Off -> Basic -> Detailed -> Advanced'),
            const SizedBox(height: 18),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stress Controls',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _incrementCounter();
                            _simulateJank(50);
                          },
                          child: const Text('Single Jank Spike'),
                        ),
                        ElevatedButton(
                          onPressed: _runBurstStress,
                          child: const Text('Burst Stress (20x)'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Auto stress loop'),
                      subtitle: const Text(
                        'Continuously creates frame pressure for HUD testing.',
                      ),
                      value: _autoStress,
                      onChanged: _toggleAutoStress,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Counter: $_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
}
