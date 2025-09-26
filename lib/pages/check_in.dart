import 'package:flutter/material.dart';
import '../models.dart';
import '../storage.dart';
import '../theme.dart';

class DailyCheckInScreen extends StatefulWidget {
  final StorageService storage;
  const DailyCheckInScreen({super.key, required this.storage});

  @override
  State<DailyCheckInScreen> createState() => _DailyCheckInScreenState();
}

class _DailyCheckInScreenState extends State<DailyCheckInScreen> {
  int mood = 3; // 1..5
  int urge = 5; // 1..10
  final notesCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Check-in')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('How do you feel today?', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Glass(
            child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Mood'),
              Text('$mood/5'),
            ],
            ),
          ),
          Slider(
            value: mood.toDouble(),
            min: 1,
            max: 5,
            divisions: 4,
            onChanged: (v) => setState(() => mood = v.round()),
          ),
          const SizedBox(height: 16),
          Glass(
            child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Urge to smoke'),
              Text('$urge/10'),
            ],
            ),
          ),
          Slider(
            value: urge.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            onChanged: (v) => setState(() => urge = v.round()),
          ),
          const SizedBox(height: 16),
          Glass(child: TextField(controller: notesCtrl, maxLines: 4, decoration: const InputDecoration(hintText: 'Any notes or triggers?'))),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              final entry = DailyCheckIn(
                date: DateTime.now(),
                mood: mood,
                urge: urge,
                notes: notesCtrl.text.trim(),
              );
              await widget.storage.upsertCheckIn(entry);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Save Check-in'),
          ),
        ],
      ),
    );
  }
}


