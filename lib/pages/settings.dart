import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models.dart';
import '../storage.dart';

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

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.profile.name);
    quitDate = widget.profile.quitDate;
    cigsPerDay = widget.profile.cigarettesPerDay;
    packPrice = widget.profile.packPrice;
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
            onTap: () {},
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Account'),
            subtitle: const Text('Manage your account settings'),
            tileColor: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onTap: () {},
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
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              final updated = UserProfile(
                name: nameCtrl.text.trim(),
                quitDate: quitDate,
                cigarettesPerDay: cigsPerDay,
                packPrice: packPrice,
              );
              await widget.storage.saveProfile(updated);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Save Settings'),
          ),
        ],
      ),
    );
  }
}


