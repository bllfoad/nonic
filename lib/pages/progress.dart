import 'package:flutter/material.dart';
import '../models.dart';
import '../storage.dart';
import '../utils.dart';
import '../storage.dart';
import 'package:intl/intl.dart';
import 'dashboard.dart';
import 'log_slip.dart';
import '../theme.dart';

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
  double bmi() => computeBmiKgM2(weightKg: profile.weightKg, heightCm: profile.heightCm);
  double packYears() => computePackYears(
        cigarettesPerDay: profile.cigarettesPerDay,
        startedSmokingDate: profile.startedSmokingDate,
        until: profile.quitDate,
      );
  double yearsSmoked() {
    final days = DateTime(profile.quitDate.year, profile.quitDate.month, profile.quitDate.day)
        .difference(DateTime(profile.startedSmokingDate.year, profile.startedSmokingDate.month, profile.startedSmokingDate.day))
        .inDays;
    return days / 365.25;
  }

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
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _MetricRow(label: 'BMI', value: bmi().toStringAsFixed(1))),
            const SizedBox(width: 12),
            Expanded(child: _MetricRow(label: 'Pack-years', value: packYears().toStringAsFixed(1))),
          ]),
          const SizedBox(height: 12),
          _MetricRow(label: 'Years smoked', value: yearsSmoked().toStringAsFixed(1)),
          const SizedBox(height: 24),
          FutureBuilder(
            future: Future.wait([storage.getCravings(), storage.getCheckIns(), storage.getSlips()]),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();
              final cravings = (snapshot.data![0]) as List<CravingEntry>;
              final checkins = (snapshot.data![1]) as List<DailyCheckIn>;
              final slips = (snapshot.data![2]) as List<SlipEntry>;
              final risk = computeCompositeRisk(
                checkins: checkins,
                cravings: cravings,
                age: profile.age,
                gender: profile.gender,
                bmi: bmi(),
                packYears: packYears(),
              );
              Color riskColor = risk >= 70
                  ? Colors.redAccent.withOpacity(0.5)
                  : risk >= 40
                      ? Colors.orange.withOpacity(0.5)
                      : Colors.green.withOpacity(0.5);
              final byHour = List<int>.filled(24, 0);
              for (final c in cravings) {
                byHour[c.createdAt.hour]++;
              }
              final topHour = byHour.asMap().entries.reduce((a, b) => a.value > b.value ? a : b).key;

              final byWeekday = List<int>.filled(7, 0);
              for (final c in cravings) {
                byWeekday[c.createdAt.weekday % 7]++;
              }
              final topDayIdx = byWeekday.asMap().entries.reduce((a, b) => a.value > b.value ? a : b).key;
              const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Risk & Insights', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  Glass(
                    child: Row(children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Relapse risk today: $risk/100', style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text('BMI ${bmi().toStringAsFixed(1)} • Pack-years ${packYears().toStringAsFixed(1)} • Smoked ${yearsSmoked().toStringAsFixed(1)}y'),
                        ]),
                      ),
                      const Icon(Icons.shield, color: Colors.white70),
                    ]),
                  ),
                  const SizedBox(height: 20),
                  Text('Craving Analytics', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  Glass(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Peak hour: ${NumberFormat('00').format(topHour)}:00'),
                        Text('Toughest day: ${days[topDayIdx]}'),
                        const SizedBox(height: 12),
                        Wrap(spacing: 8, children: [for (int i = 0; i < 24; i++) Chip(label: Text('${NumberFormat('00').format(i)}'), backgroundColor: byHour[i] > 0 ? Colors.orange.withOpacity(0.2) : Theme.of(context).cardColor)]),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Slips', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  if (slips.isEmpty)
                    const Glass(child: Text('No slips logged. Stay strong!'))
                  else
                    Glass(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Past 30 days: ${slips.where((s) => DateTime.now().difference(s.createdAt).inDays <= 30).fold<int>(0, (acc, s) => acc + s.count)} cigarettes'),
                        const SizedBox(height: 8),
                        for (final s in slips.take(5))
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text(DateFormat.yMMMd().add_jm().format(s.createdAt), style: const TextStyle(color: Color(0xFF9CB3A8))),
                              Text('x${s.count}')
                            ]),
                          ),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () async {
                            await Navigator.of(context).push(MaterialPageRoute(builder: (_) => LogSlipScreen(storage: storage)));
                          },
                          child: const Text('Log Slip'),
                        )
                      ]),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          Text('Health Improvements', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          ...() {
            final elapsed = DateTime.now().difference(profile.quitDate);
            final steps = buildHealthTimeline(profile.quitDate);
            String humanize(Duration d) {
              if (d.inDays >= 1) return '${d.inDays}d';
              if (d.inHours >= 1) return '${d.inHours}h';
              if (d.inMinutes >= 1) return '${d.inMinutes}m';
              return '${d.inSeconds}s';
            }
            return [
              for (final s in steps)
                _HealthStep(
                  title: s.title,
                  subtitle: elapsed >= s.at ? 'Achieved' : 'In ~${humanize(s.at - elapsed)}',
                  achieved: elapsed >= s.at,
                  note: s.subtitle,
                )
            ];
          }(),
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
  final bool achieved;
  final String note;
  const _HealthStep({required this.title, required this.subtitle, required this.achieved, required this.note});
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
          CircleAvatar(backgroundColor: achieved ? Colors.green : Colors.grey, child: Icon(achieved ? Icons.check : Icons.schedule, color: Colors.white)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Color(0xFF9CB3A8))),
            const SizedBox(height: 4),
            Text(note, style: const TextStyle(color: Color(0xFF9CB3A8), fontSize: 12)),
          ])),
        ],
      ),
    );
  }
}


