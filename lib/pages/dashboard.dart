import 'package:flutter/material.dart';
import '../models.dart';
import '../storage.dart';
import '../utils.dart';
import '../theme.dart';
import 'check_in.dart';
import 'sos_breathe.dart';
import 'goals.dart';
import 'log_craving.dart';
import 'cravings_list.dart';
import 'settings.dart';
import 'log_slip.dart';

class DashboardScreen extends StatelessWidget {
  final UserProfile profile;
  final StorageService storage;
  final ValueChanged<UserProfile>? onProfileUpdated;
  const DashboardScreen({super.key, required this.profile, required this.storage, this.onProfileUpdated});

  int daysSmokeFree() {
    final now = DateTime.now();
    return now.difference(DateTime(profile.quitDate.year, profile.quitDate.month, profile.quitDate.day)).inDays;
  }

  int cigarettesAvoided() => daysSmokeFree() * profile.cigarettesPerDay;
  double moneySaved() => cigarettesAvoided() / 20.0 * profile.packPrice;

  String nextMilestoneCountdown() {
    final milestones = computeMilestones(profile.quitDate);
    final now = DateTime.now();
    final elapsed = now.difference(profile.quitDate);
    // find first not achieved timeline from buildHealthTimeline for richer countdown
    final steps = buildHealthTimeline(profile.quitDate);
    for (final s in steps) {
      if (elapsed < s.at) {
        final remaining = s.at - elapsed;
        if (remaining.inDays >= 1) return '${remaining.inDays}d to ${s.title}';
        if (remaining.inHours >= 1) return '${remaining.inHours}h to ${s.title}';
        return '${remaining.inMinutes}m to ${s.title}';
      }
    }
    // fallback to milestone labels
    for (final m in milestones) {
      if (!m.achieved) {
        final target = DateTime(profile.quitDate.year, profile.quitDate.month, profile.quitDate.day)
            .add(Duration(days: {
          '1 day': 1,
          '3 days': 3,
          '1 week': 7,
          '1 month': 30,
          '3 months': 90,
          '6 months': 180,
          '1 year': 365,
        }[m.label]!));
        final remaining = target.difference(now);
        return '${remaining.inDays}d to ${m.label}';
      }
    }
    return 'Keep it up!';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              final result = await Navigator.of(context).push<UserProfile>(MaterialPageRoute(
                builder: (_) => SettingsScreen(profile: profile, storage: storage),
              ));
              if (result != null) {
                onProfileUpdated?.call(result);
              }
            },
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _HeroHeader(
            name: profile.name,
            subtitle: '${daysSmokeFree()} days smoke-free',
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _MetricCard(icon: Icons.whatshot, label: 'Avoided', value: cigarettesAvoided().toString(), color: Colors.orange)),
            const SizedBox(width: 12),
            Expanded(child: _MetricCard(icon: Icons.savings, label: 'Saved', value: money0(moneySaved()), color: Colors.greenAccent)),
          ]),
          const SizedBox(height: 12),
          _MetricRow(label: 'Streak', value: '${daysSmokeFree()} days'),
          const SizedBox(height: 12),
          _MetricRow(label: 'Next up', value: nextMilestoneCountdown()),
          const SizedBox(height: 24),
          FutureBuilder(
            future: Future.wait([storage.getCheckIns(), storage.getCravings()]),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();
              final checkins = (snapshot.data![0]) as List<DailyCheckIn>;
              final cravings = (snapshot.data![1]) as List<CravingEntry>;
              final risk = computeRiskScore(checkins: checkins, cravings: cravings);
              final tips = suggestTips(riskScore: risk);
              final milestones = computeMilestones(profile.quitDate);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Today\'s Insight', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  _InsightCard(risk: risk, tip: tips.first, onSos: () async {
                    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => SosBreatheScreen(storage: storage)));
                  }),
                  const SizedBox(height: 16),
                  _MilestonesCompact(milestones: milestones),
                ],
              );
            },
          ),
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
                  child: const Text('Cravings Log'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () async {
                  await Navigator.of(context).push(MaterialPageRoute(builder: (_) => DailyCheckInScreen(storage: storage)));
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                  side: BorderSide(color: Theme.of(context).colorScheme.outline),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: const StadiumBorder(),
                ),
                child: const Text('Daily Check-in'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () async {
                  await Navigator.of(context).push(MaterialPageRoute(builder: (_) => LogSlipScreen(storage: storage)));
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                  side: BorderSide(color: Theme.of(context).colorScheme.outline),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: const StadiumBorder(),
                ),
                child: const Text('Log Slip'),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  final String name;
  final String subtitle;
  const _HeroHeader({required this.name, required this.subtitle});
  @override
  Widget build(BuildContext context) {
    return Glass(
      borderRadius: 20,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          CircleAvatar(radius: 36, backgroundColor: Theme.of(context).cardColor, child: const Icon(Icons.person, size: 40)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Hi, $name', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: Color(0xFF9CB3A8))),
            ]),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _MetricCard({required this.icon, required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Glass(
      child: Row(
        children: [
          CircleAvatar(backgroundColor: color.withOpacity(0.2), child: Icon(icon, color: color)),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(color: Color(0xFF9CB3A8))),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
          ]),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final int risk;
  final String tip;
  final VoidCallback onSos;
  const _InsightCard({required this.risk, required this.tip, required this.onSos});
  @override
  Widget build(BuildContext context) {
    return Glass(
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Relapse risk: $risk/100', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text('Top tip: $tip'),
            ]),
          ),
          ElevatedButton(onPressed: onSos, child: const Text('SOS')),
        ],
      ),
    );
  }
}

class _MilestonesCompact extends StatelessWidget {
  final List<Milestone> milestones;
  const _MilestonesCompact({required this.milestones});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: milestones.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Center(
                child: Text('Milestones', style: Theme.of(context).textTheme.titleSmall),
              ),
            );
          }
          final m = milestones[index - 1];
          final achieved = m.achieved;
          return Glass(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            borderRadius: 999,
            child: Row(
              children: [
                Icon(achieved ? Icons.check : Icons.fiber_manual_record, size: 14, color: achieved ? Colors.green : Colors.grey),
                const SizedBox(width: 6),
                Text(m.label, style: const TextStyle(fontSize: 12)),
              ],
            ),
          );
        },
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
    return Glass(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Row(
        children: [
          Expanded(child: Text(label, overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              textAlign: TextAlign.right,
              overflow: TextOverflow.fade,
              softWrap: false,
            ),
          ),
        ],
      ),
    );
  }
}


