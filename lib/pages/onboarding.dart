import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models.dart';

class OnboardingScreen extends StatefulWidget {
  final void Function(UserProfile) onComplete;
  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final nameCtrl = TextEditingController();
  DateTime quitDate = DateTime.now();
  double packPrice = 10;
  int cigsPerDay = 10;
  int age = 30;
  String gender = 'unspecified';
  double weightKg = 70;
  double heightCm = 170;
  DateTime startedSmokingDate = DateTime.now().subtract(const Duration(days: 365 * 5));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Start Your Journey')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 12),
          Text('Start Your Journey to a Smoke-Free Life', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 24),
          TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(hintText: 'Your name'),
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
          Text('Cigarettes per day: $cigsPerDay'),
          Slider(
            value: cigsPerDay.toDouble(),
            min: 1,
            max: 40,
            divisions: 39,
            label: '$cigsPerDay',
            onChanged: (v) => setState(() => cigsPerDay = v.round()),
          ),
          const SizedBox(height: 16),
          Text('Pack price: ${packPrice.toStringAsFixed(2)}'),
          Slider(
            value: packPrice,
            min: 2,
            max: 30,
            divisions: 56,
            onChanged: (v) => setState(() => packPrice = double.parse(v.toStringAsFixed(2))),
          ),
          const SizedBox(height: 16),
          Text('Age: $age'),
          Slider(
            value: age.toDouble(),
            min: 12,
            max: 90,
            divisions: 78,
            label: '$age',
            onChanged: (v) => setState(() => age = v.round()),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: gender,
            decoration: const InputDecoration(hintText: 'Gender'),
            items: const [
              DropdownMenuItem(value: 'unspecified', child: Text('Prefer not to say')),
              DropdownMenuItem(value: 'male', child: Text('Male')),
              DropdownMenuItem(value: 'female', child: Text('Female')),
              DropdownMenuItem(value: 'other', child: Text('Other')),
            ],
            onChanged: (v) => setState(() => gender = v ?? 'unspecified'),
          ),
          const SizedBox(height: 16),
          Text('Weight (kg): ${weightKg.toStringAsFixed(1)}'),
          Slider(
            value: weightKg,
            min: 40,
            max: 200,
            divisions: 160,
            onChanged: (v) => setState(() => weightKg = double.parse(v.toStringAsFixed(1))),
          ),
          const SizedBox(height: 16),
          Text('Height (cm): ${heightCm.toStringAsFixed(0)}'),
          Slider(
            value: heightCm,
            min: 140,
            max: 210,
            divisions: 70,
            onChanged: (v) => setState(() => heightCm = double.parse(v.toStringAsFixed(0))),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty) return;
              widget.onComplete(UserProfile(
                name: nameCtrl.text.trim(),
                quitDate: quitDate,
                packPrice: packPrice,
                cigarettesPerDay: cigsPerDay,
                age: age,
                gender: gender,
                weightKg: weightKg,
                heightCm: heightCm,
                startedSmokingDate: startedSmokingDate,
              ));
            },
            child: const Text('Begin Your Quit Journey'),
          ),
        ],
      ),
    );
  }
}


