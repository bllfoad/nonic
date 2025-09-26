import 'package:flutter/material.dart';
import '../models.dart';
import '../storage.dart';
import '../utils.dart';
import 'log_craving.dart';
import 'cravings_list.dart';
import 'settings.dart';

class DashboardScreen extends StatelessWidget {
  final UserProfile profile;
  final StorageService storage;
  const DashboardScreen({super.key, required this.profile, required this.storage});

  int daysSmokeFree() {
    final now = DateTime.now();
    return now.difference(DateTime(profile.quitDate.year, profile.quitDate.month, profile.quitDate.day)).inDays;
  }

  int cigarettesAvoided() => daysSmokeFree() * profile.cigarettesPerDay;
  double moneySaved() => cigarettesAvoided() / 20.0 * profile.packPrice;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => SettingsScreen(profile: profile, storage: storage),
              ));
            },
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(children: [
              CircleAvatar(radius: 60, backgroundColor: Theme.of(context).cardColor, child: const Icon(Icons.person, size: 64)),
              const SizedBox(height: 16),
              Text(profile.name, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text('${daysSmokeFree()} days smoke-free', style: const TextStyle(color: Color(0xFF9CB3A8))),
            ]),
          ),
          const SizedBox(height: 24),
          _MetricRow(label: 'Cigarettes avoided', value: cigarettesAvoided().toString()),
          const SizedBox(height: 12),
          _MetricRow(label: 'Money saved', value: money0(moneySaved())),
          const SizedBox(height: 24),
          Text('Quick Actions', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    await Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => LogCravingScreen(storage: storage),
                    ));
                  },
                  child: const Text('Log Craving'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    await Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => CravingsListScreen(storage: storage),
                    ));
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                    side: BorderSide(color: Theme.of(context).colorScheme.outline),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: const StadiumBorder(),
                  ),
                  child: const Text('View Savings'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final String value;
  const _MetricRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        ],
      ),
    );
  }
}


