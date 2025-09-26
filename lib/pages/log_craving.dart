import 'package:flutter/material.dart';
import '../models.dart';
import '../storage.dart';

class LogCravingScreen extends StatefulWidget {
  final StorageService storage;
  const LogCravingScreen({super.key, required this.storage});

  @override
  State<LogCravingScreen> createState() => _LogCravingScreenState();
}

class _LogCravingScreenState extends State<LogCravingScreen> {
  int intensity = 5;
  final triggersCtrl = TextEditingController();
  final strategiesCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Cravings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Craving Intensity', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          const Text('How strong was your craving?', style: TextStyle(color: Color(0xFF9CB3A8))),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: intensity.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  onChanged: (v) => setState(() => intensity = v.round()),
                ),
              ),
              Text('$intensity'),
            ],
          ),
          const SizedBox(height: 16),
          Text('Triggers', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          TextField(
            controller: triggersCtrl,
            decoration: const InputDecoration(hintText: 'What triggered your craving?'),
            maxLines: 5,
          ),
          const SizedBox(height: 24),
          Text('Coping Strategies', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          TextField(
            controller: strategiesCtrl,
            decoration: const InputDecoration(hintText: 'What did you do to cope with the craving?'),
            maxLines: 5,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              final entry = CravingEntry(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                createdAt: DateTime.now(),
                intensity: intensity,
                triggers: triggersCtrl.text.trim(),
                strategies: strategiesCtrl.text.trim(),
              );
              await widget.storage.addCraving(entry);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}


