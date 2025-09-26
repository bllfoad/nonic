import 'package:flutter/material.dart';
import '../models.dart';
import '../storage.dart';
import '../theme.dart';

class LogSlipScreen extends StatefulWidget {
  final StorageService storage;
  const LogSlipScreen({super.key, required this.storage});

  @override
  State<LogSlipScreen> createState() => _LogSlipScreenState();
}

class _LogSlipScreenState extends State<LogSlipScreen> {
  int count = 1;
  final contextCtrl = TextEditingController();
  final noteCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Slip')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('How many cigarettes did you smoke?', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Glass(
            child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Count'),
              Text('$count'),
            ],
            ),
          ),
          Slider(
            value: count.toDouble(),
            min: 1,
            max: 20,
            divisions: 19,
            onChanged: (v) => setState(() => count = v.round()),
          ),
          const SizedBox(height: 16),
          Glass(child: TextField(controller: contextCtrl, decoration: const InputDecoration(hintText: 'What was the context/trigger?'), maxLines: 3)),
          const SizedBox(height: 12),
          Glass(child: TextField(controller: noteCtrl, decoration: const InputDecoration(hintText: 'Any note or reflection?'), maxLines: 4)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              final entry = SlipEntry(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                createdAt: DateTime.now(),
                count: count,
                context: contextCtrl.text.trim(),
                note: noteCtrl.text.trim(),
              );
              await widget.storage.addSlip(entry);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Save Slip'),
          ),
        ],
      ),
    );
  }
}


