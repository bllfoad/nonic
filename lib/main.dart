import 'package:flutter/material.dart';
import 'theme.dart';
import 'models.dart';
import 'storage.dart';
import 'pages/onboarding.dart';
import 'pages/home_shell.dart';
import 'utils.dart';

void main() {
  runApp(const NonicApp());
}

class NonicApp extends StatefulWidget {
  const NonicApp({super.key});
  @override
  State<NonicApp> createState() => _NonicAppState();
}

class _NonicAppState extends State<NonicApp> {
  final StorageService storage = StorageService();
  UserProfile? profile;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final loaded = await storage.getProfile();
    await NotificationService.instance.initialize();
    setState(() => profile = loaded);
    if (loaded != null) {
      _scheduleDefaultNotifications(loaded);
    }
  }

  void _scheduleDefaultNotifications(UserProfile p) {
    // Daily check-in reminder at 8 PM
    NotificationService.instance.scheduleDailyAtHourMinute(
      id: 1001,
      hour: 20,
      minute: 0,
      title: 'Daily Check-in',
      body: 'How was your day? Log your mood and urges.',
    );
    // Health milestone notifications from quit timeline
    final steps = buildHealthTimeline(p.quitDate);
    final now = DateTime.now();
    for (int i = 0; i < steps.length; i++) {
      final when = p.quitDate.add(steps[i].at);
      if (when.isAfter(now)) {
        NotificationService.instance.scheduleAt(
          id: 2000 + i,
          when: when,
          title: 'Milestone: ${steps[i].title}',
          body: steps[i].subtitle,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nonic',
      debugShowCheckedModeBanner: false,
      theme: buildNonicTheme(),
      home: profile == null
          ? OnboardingScreen(
              onComplete: (p) async {
                await storage.saveProfile(p);
                setState(() => profile = p);
              },
            )
          : HomeShell(profile: profile!, storage: storage),
    );
  }
}


