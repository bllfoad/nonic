import 'package:flutter/material.dart';
import '../models.dart';
import '../utils.dart';
import '../theme.dart';

class MilestonesScreen extends StatelessWidget {
  final UserProfile profile;
  const MilestonesScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final elapsed = DateTime.now().difference(profile.quitDate);
    final steps = buildHealthTimeline(profile.quitDate);
    String humanize(Duration d) {
      if (d.inDays >= 1) return '${d.inDays}d';
      if (d.inHours >= 1) return '${d.inHours}h';
      if (d.inMinutes >= 1) return '${d.inMinutes}m';
      return '${d.inSeconds}s';
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Milestones')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          for (final s in steps)
            Glass(
              margin: const EdgeInsets.only(bottom: 12),
              child: Row(children: [
                CircleAvatar(backgroundColor: elapsed >= s.at ? Colors.green : Colors.grey, child: Icon(elapsed >= s.at ? Icons.check : Icons.schedule, color: Colors.white)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(s.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(s.subtitle, style: const TextStyle(color: Color(0xFF9CB3A8), fontSize: 12)),
                  const SizedBox(height: 6),
                  Text(elapsed >= s.at ? 'Achieved' : 'In ~${humanize(s.at - elapsed)}'),
                ])),
              ]),
            ),
        ],
      ),
    );
  }
}


