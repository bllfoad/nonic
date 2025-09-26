import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models.dart';
import '../storage.dart';
import '../utils.dart';
import 'goals.dart';

class SettingsScreen extends StatefulWidget {
  final UserProfile profile;
  final StorageService storage;
  const SettingsScreen({super.key, required this.profile, required this.storage});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController nameCtrl;
  late DateTime quitDate;
  late int cigsPerDay;
  late double packPrice;
  late int age;
  late String gender;
  late double weightKg;
  late double heightCm;
  late DateTime startedSmokingDate;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.profile.name);
    quitDate = widget.profile.quitDate;
    cigsPerDay = widget.profile.cigarettesPerDay;
    packPrice = widget.profile.packPrice;
    age = widget.profile.age;
    gender = widget.profile.gender;
    weightKg = widget.profile.weightKg;
    heightCm = widget.profile.heightCm;
    startedSmokingDate = widget.profile.startedSmokingDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ListTile(
            title: const Text('Personal Goals'),
            subtitle: const Text('Set your personal goals for quitting'),
            tileColor: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onTap: () async {
              await Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => GoalsScreen(storage: widget.storage),
              ));
            },
          ),
          const SizedBox(height: 24),
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Quit date'),
            subtitle: Text(DateFormat.yMMMd().format(quitDate)),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: quitDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null) setState(() => quitDate = picked);
            },
          ),
          const SizedBox(height: 12),
          Text('Cigarettes per day: $cigsPerDay'),
          Slider(value: cigsPerDay.toDouble(), min: 1, max: 40, divisions: 39, onChanged: (v) => setState(() => cigsPerDay = v.round())),
          const SizedBox(height: 12),
          Text('Pack price: ${packPrice.toStringAsFixed(2)}'),
          Slider(value: packPrice, min: 2, max: 30, divisions: 56, onChanged: (v) => setState(() => packPrice = double.parse(v.toStringAsFixed(2)))),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Started smoking'),
            subtitle: Text(DateFormat.yMMMd().format(startedSmokingDate)),
            trailing: const Icon(Icons.calendar_month),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: startedSmokingDate,
                firstDate: DateTime(1970),
                lastDate: DateTime.now(),
              );
              if (picked != null) setState(() => startedSmokingDate = picked);
            },
          ),
          const SizedBox(height: 12),
          Text('Age: $age'),
          Slider(value: age.toDouble(), min: 12, max: 90, divisions: 78, onChanged: (v) => setState(() => age = v.round())),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: gender,
            decoration: const InputDecoration(labelText: 'Gender'),
            items: const [
              DropdownMenuItem(value: 'unspecified', child: Text('Prefer not to say')),
              DropdownMenuItem(value: 'male', child: Text('Male')),
              DropdownMenuItem(value: 'female', child: Text('Female')),
              DropdownMenuItem(value: 'other', child: Text('Other')),
            ],
            onChanged: (v) => setState(() => gender = v ?? 'unspecified'),
          ),
          const SizedBox(height: 12),
          Text('Weight (kg): ${weightKg.toStringAsFixed(1)}'),
          Slider(value: weightKg, min: 40, max: 200, divisions: 160, onChanged: (v) => setState(() => weightKg = double.parse(v.toStringAsFixed(1)))),
          const SizedBox(height: 12),
          Text('Height (cm): ${heightCm.toStringAsFixed(0)}'),
          Slider(value: heightCm, min: 140, max: 210, divisions: 70, onChanged: (v) => setState(() => heightCm = double.parse(v.toStringAsFixed(0)))),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () async {
              // Reschedule daily and milestones
              await NotificationService.instance.initialize();
              final profile = UserProfile(
                name: nameCtrl.text.trim(),
                quitDate: quitDate,
                cigarettesPerDay: cigsPerDay,
                packPrice: packPrice,
                age: age,
                gender: gender,
                weightKg: weightKg,
                heightCm: heightCm,
                startedSmokingDate: startedSmokingDate,
              );
              // Daily reminder
              await NotificationService.instance.scheduleDailyAtHourMinute(
                id: 1001,
                hour: 20,
                minute: 0,
                title: 'Daily Check-in',
                body: 'How was your day? Log your mood and urges.',
              );
              // Milestones
              final steps = buildHealthTimeline(profile.quitDate);
              final now = DateTime.now();
              for (int i = 0; i < steps.length; i++) {
                final when = profile.quitDate.add(steps[i].at);
                if (when.isAfter(now)) {
                  await NotificationService.instance.scheduleAt(
                    id: 2000 + i,
                    when: when,
                    title: 'Milestone: ${steps[i].title}',
                    body: steps[i].subtitle,
                  );
                }
              }
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notifications scheduled')));
              }
            },
            child: const Text('Reschedule Notifications'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              final updated = UserProfile(
                name: nameCtrl.text.trim(),
                quitDate: quitDate,
                cigarettesPerDay: cigsPerDay,
                packPrice: packPrice,
                age: age,
                gender: gender,
                weightKg: weightKg,
                heightCm: heightCm,
                startedSmokingDate: startedSmokingDate,
              );
              await widget.storage.saveProfile(updated);
              if (mounted) Navigator.pop(context, updated);
            },
            child: const Text('Save Settings'),
          ),
        ],
      ),
    );
  }
}


