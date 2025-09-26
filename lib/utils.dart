import 'package:intl/intl.dart';
import 'models.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

String money0(num value) {
  return NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(value);
}

// Smart engine helpers

/// Calculates a simple relapse risk score (0..100) using last 7 days check-ins and cravings.
int computeRiskScore({required List<DailyCheckIn> checkins, required List<CravingEntry> cravings}) {
  // Base from average urge in last 7 days
  final now = DateTime.now();
  final sevenDaysAgo = now.subtract(const Duration(days: 7));
  final recentCheckins = checkins.where((c) => c.normalizedDate.isAfter(sevenDaysAgo)).toList();
  final recentCravings = cravings.where((e) => e.createdAt.isAfter(sevenDaysAgo)).toList();

  double urgeAvg = recentCheckins.isEmpty
      ? 0
      : recentCheckins.map((c) => c.urge).reduce((a, b) => a + b) / recentCheckins.length;
  double moodPenalty = recentCheckins.isEmpty
      ? 0
      : (3 - (recentCheckins.map((c) => c.mood).reduce((a, b) => a + b) / recentCheckins.length)) * 10; // low mood increases risk
  double cravingFreq = recentCravings.length * 5.0; // each craving adds 5 points

  double score = urgeAvg * 8 + moodPenalty + cravingFreq; // weights tuned by hand
  if (score > 100) score = 100;
  if (score < 0) score = 0;
  return score.round();
}

List<String> suggestTips({required int riskScore}) {
  if (riskScore >= 70) {
    return [
      'Use the 4-7-8 breathing for 90 seconds',
      'Avoid triggers for the next hour (coffee, alcohol, social smoking)',
      'Message a friend or support group',
    ];
  } else if (riskScore >= 40) {
    return [
      'Carry water and take 10 sips slowly',
      'Short walk: 5 minutes to reset',
      'Prepare a healthy snack',
    ];
  } else {
    return [
      'Plan tomorrow: when cravings hit, chew gum immediately',
      'Write 1 reason you’re quitting',
    ];
  }
}

// Analytics: BMI, Pack-Years, Years Smoked, Demographic-aware risk adjunct
double computeBmiKgM2({required double weightKg, required double heightCm}) {
  final meters = heightCm / 100.0;
  if (meters <= 0) return 0;
  return weightKg / (meters * meters);
}

double computePackYears({required int cigarettesPerDay, required DateTime startedSmokingDate, DateTime? until}) {
  final end = until ?? DateTime.now();
  final years = end.difference(DateTime(startedSmokingDate.year, startedSmokingDate.month, startedSmokingDate.day)).inDays / 365.25;
  final packsPerDay = cigarettesPerDay / 20.0;
  if (years <= 0 || packsPerDay <= 0) return 0;
  return packsPerDay * years;
}

int computeCompositeRisk({
  required List<DailyCheckIn> checkins,
  required List<CravingEntry> cravings,
  required int age,
  required String gender,
  required double bmi,
  required double packYears,
}) {
  int base = computeRiskScore(checkins: checkins, cravings: cravings);
  double adj = 0;
  if (packYears >= 20) adj += 10;
  if (packYears >= 40) adj += 10;
  if (bmi >= 30) adj += 5;
  if (age >= 50) adj += 5;
  // no gender penalty, but can be used later for tailored tips
  final total = (base + adj).clamp(0, 100).round();
  return total;
}

class Milestone {
  final String label;
  final bool achieved;
  const Milestone(this.label, this.achieved);
}

List<Milestone> computeMilestones(DateTime quitDate) {
  final now = DateTime.now();
  final days = now.difference(DateTime(quitDate.year, quitDate.month, quitDate.day)).inDays;
  final milestones = <Milestone>[
    Milestone('1 day', days >= 1),
    Milestone('3 days', days >= 3),
    Milestone('1 week', days >= 7),
    Milestone('1 month', days >= 30),
    Milestone('3 months', days >= 90),
    Milestone('6 months', days >= 180),
    Milestone('1 year', days >= 365),
  ];
  return milestones;
}

class HealthImprovement {
  final Duration at;
  final String title;
  final String subtitle;
  const HealthImprovement({required this.at, required this.title, required this.subtitle});
}

List<HealthImprovement> buildHealthTimeline(DateTime quitDate) {
  // Evidence-informed milestones (approximate, for motivational UI)
  final items = <HealthImprovement>[
    HealthImprovement(at: const Duration(minutes: 20), title: 'Pulse & BP normalize', subtitle: 'About 20 minutes after quitting'),
    HealthImprovement(at: const Duration(hours: 12), title: 'CO levels drop', subtitle: 'Carbon monoxide in blood returns to normal'),
    HealthImprovement(at: const Duration(days: 1), title: 'Heart attack risk drops', subtitle: 'Within 24 hours after quitting'),
    HealthImprovement(at: const Duration(days: 14), title: 'Circulation improves', subtitle: '2 weeks to 3 months: lung function improves'),
    HealthImprovement(at: const Duration(days: 90), title: 'Lung capacity rises', subtitle: 'Coughing and shortness of breath decrease'),
    HealthImprovement(at: const Duration(days: 365), title: 'Heart disease risk halves', subtitle: '1 year: about half that of a smoker'),
  ];
  return items;
}


class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();
    // Try to use DateTime.now().timeZoneName when native plugin is unavailable
    try {
      final String localName = DateTime.now().timeZoneName;
      // Map common abbreviations to Olson names when possible; fallback to UTC
      final Map<String, String> map = {
        'UTC': 'UTC',
        'GMT': 'GMT',
      };
      final String target = map[localName] ?? tz.local.name;
      tz.setLocalLocation(tz.getLocation(target));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
    await _plugin.initialize(initSettings);
    _initialized = true;
  }

  Future<void> showNow({required String title, required String body, String? payload}) async {
    await initialize();
    const android = AndroidNotificationDetails('nonic_general', 'General', importance: Importance.max, priority: Priority.high);
    const ios = DarwinNotificationDetails();
    const details = NotificationDetails(android: android, iOS: ios);
    await _plugin.show(DateTime.now().millisecondsSinceEpoch % 100000, title, body, details, payload: payload);
  }

  Future<void> scheduleAt({required int id, required DateTime when, required String title, required String body}) async {
    await initialize();
    const android = AndroidNotificationDetails('nonic_schedule', 'Scheduled');
    const ios = DarwinNotificationDetails();
    final details = const NotificationDetails(android: android, iOS: ios);
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(when, tz.local),
      details,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: null,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> scheduleDailyAtHourMinute({required int id, required int hour, required int minute, required String title, required String body}) async {
    await initialize();
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) scheduled = scheduled.add(const Duration(days: 1));
    const android = AndroidNotificationDetails('nonic_daily', 'Daily');
    const ios = DarwinNotificationDetails();
    final details = const NotificationDetails(android: android, iOS: ios);
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      details,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
}

