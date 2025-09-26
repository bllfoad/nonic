import 'dart:async';
import 'package:flutter/material.dart';
import '../storage.dart';

class SosBreatheScreen extends StatefulWidget {
  final StorageService? storage;
  const SosBreatheScreen({super.key, this.storage});
  @override
  State<SosBreatheScreen> createState() => _SosBreatheScreenState();
}

class _SosBreatheScreenState extends State<SosBreatheScreen> {
  Timer? _timer;
  int _phase = 0; // 0: inhale(4), 1: hold(7), 2: exhale(8)
  int _remaining = 4;

  @override
  void initState() {
    super.initState();
    _startPhase(0, 4);
  }

  void _startPhase(int phase, int seconds) {
    _timer?.cancel();
    setState(() {
      _phase = phase;
      _remaining = seconds;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remaining <= 1) {
        if (_phase == 0) {
          _startPhase(1, 7);
        } else if (_phase == 1) {
          _startPhase(2, 8);
        } else {
          _startPhase(0, 4);
        }
      } else {
        setState(() => _remaining -= 1);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label = _phase == 0 ? 'Inhale' : _phase == 1 ? 'Hold' : 'Exhale';
    return Scaffold(
      appBar: AppBar(title: const Text('SOS Breathing')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              width: _phase == 2 ? 120 : 200,
              height: _phase == 2 ? 120 : 200,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text('$_remaining s', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),
            const Text('4-7-8 technique: inhale 4s, hold 7s, exhale 8s'),
            const SizedBox(height: 12),
            FutureBuilder(
              future: widget.storage?.getTodayPracticeCount() ?? Future.value(0),
              builder: (context, snapshot) {
                final count = snapshot.data ?? 0;
                return Text("Today's practices: $count");
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (widget.storage != null) {
            await widget.storage!.incrementTodayPracticeCount();
            if (mounted) setState(() {});
          }
        },
        icon: const Icon(Icons.check_circle_outline),
        label: const Text('Mark Completed'),
      ),
    );
  }
}


