import 'package:flutter/material.dart';
import '../models.dart';
import '../storage.dart';
import '../utils.dart';
import 'dashboard.dart';

class ProgressScreen extends StatelessWidget {
  final UserProfile profile;
  final StorageService storage;
  const ProgressScreen({super.key, required this.profile, required this.storage});

  int daysSmokeFree() {
    final now = DateTime.now();
    return now.difference(DateTime(profile.quitDate.year, profile.quitDate.month, profile.quitDate.day)).inDays;
  }

  int cigarettesAvoided() => daysSmokeFree() * profile.cigarettesPerDay;
  double moneySaved() => cigarettesAvoided() / 20.0 * profile.packPrice;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(children: [
              CircleAvatar(radius: 60, backgroundColor: Theme.of(context).cardColor, child: const Icon(Icons.person, size: 64)),
              const SizedBox(height: 16),
              Text('${profile.name}'),
              Text('Quitting since ${profile.quitDate.toString().split(' ').first}', style: const TextStyle(color: Color(0xFF9CB3A8))),
            ]),
          ),
          const SizedBox(height: 24),
          _MetricRow(label: 'Days smoke-free', value: daysSmokeFree().toString()),
          const SizedBox(height: 12),
          _MetricRow(label: 'Cigarettes avoided', value: cigarettesAvoided().toString()),
          const SizedBox(height: 12),
          _MetricRow(label: 'Money saved', value: money0(moneySaved())),
          const SizedBox(height: 24),
          Text('Health Improvements', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          const _HealthStep(title: 'Blood pressure and heart rate return to normal', subtitle: '20 minutes after quitting'),
          const _HealthStep(title: 'Carbon monoxide level in blood drops to normal', subtitle: '12 hours after quitting'),
          const _HealthStep(title: 'Circulation improves, lung function begins to recover', subtitle: '2 weeks to 3 months after quitting'),
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

class _HealthStep extends StatelessWidget {
  final String title;
  final String subtitle;
  const _HealthStep({required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.favorite, color: Colors.white)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title), Text(subtitle, style: const TextStyle(color: Color(0xFF9CB3A8)))])),
        ],
      ),
    );
  }
}


