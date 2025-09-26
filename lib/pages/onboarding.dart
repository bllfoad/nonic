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
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty) return;
              widget.onComplete(UserProfile(
                name: nameCtrl.text.trim(),
                quitDate: quitDate,
                packPrice: packPrice,
                cigarettesPerDay: cigsPerDay,
              ));
            },
            child: const Text('Begin Your Quit Journey'),
          ),
        ],
      ),
    );
  }
}


