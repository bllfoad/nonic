import 'dart:convert';

class UserProfile {
  final String name;
  final DateTime quitDate;
  final double packPrice; // in local currency
  final int cigarettesPerDay;
  final int age; // in years
  final String gender; // 'male' | 'female' | 'other' | 'unspecified'
  final double weightKg; // kilograms
  final double heightCm; // centimeters
  final DateTime startedSmokingDate; // when user started smoking

  const UserProfile({
    required this.name,
    required this.quitDate,
    required this.packPrice,
    required this.cigarettesPerDay,
    required this.age,
    required this.gender,
    required this.weightKg,
    required this.heightCm,
    required this.startedSmokingDate,
  });

  factory UserProfile.empty() => UserProfile(
        name: '',
        quitDate: DateTime.now(),
        packPrice: 10,
        cigarettesPerDay: 10,
        age: 30,
        gender: 'unspecified',
        weightKg: 70,
        heightCm: 170,
        startedSmokingDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'quitDate': quitDate.toIso8601String(),
        'packPrice': packPrice,
        'cigarettesPerDay': cigarettesPerDay,
        'age': age,
        'gender': gender,
        'weightKg': weightKg,
        'heightCm': heightCm,
        'startedSmokingDate': startedSmokingDate.toIso8601String(),
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        name: json['name'] ?? '',
        quitDate: DateTime.parse(json['quitDate'] as String),
        packPrice: (json['packPrice'] as num).toDouble(),
        cigarettesPerDay: json['cigarettesPerDay'] as int,
        age: (json['age'] as int?) ?? 30,
        gender: (json['gender'] as String?) ?? 'unspecified',
        weightKg: (json['weightKg'] as num?)?.toDouble() ?? 70.0,
        heightCm: (json['heightCm'] as num?)?.toDouble() ?? 170.0,
        startedSmokingDate: json['startedSmokingDate'] != null
            ? DateTime.parse(json['startedSmokingDate'] as String)
            : DateTime.parse(json['quitDate'] as String).subtract(const Duration(days: 365)),
      );

  String encode() => jsonEncode(toJson());
  static UserProfile decode(String value) =>
      UserProfile.fromJson(jsonDecode(value) as Map<String, dynamic>);
}

class CravingEntry {
  final String id;
  final DateTime createdAt;
  final int intensity; // 1..10
  final String triggers;
  final String strategies;

  const CravingEntry({
    required this.id,
    required this.createdAt,
    required this.intensity,
    required this.triggers,
    required this.strategies,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'intensity': intensity,
        'triggers': triggers,
        'strategies': strategies,
      };

  factory CravingEntry.fromJson(Map<String, dynamic> json) => CravingEntry(
        id: json['id'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        intensity: json['intensity'] as int,
        triggers: json['triggers'] as String? ?? '',
        strategies: json['strategies'] as String? ?? '',
      );

  static String encodeList(List<CravingEntry> list) => jsonEncode(
        list.map((e) => e.toJson()).toList(),
      );

  static List<CravingEntry> decodeList(String value) {
    final data = jsonDecode(value) as List<dynamic>;
    return data
        .map((e) => CravingEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}


class SlipEntry {
  final String id;
  final DateTime createdAt;
  final int count; // number of cigarettes smoked in this slip event
  final String context; // optional context/trigger
  final String note; // optional note

  const SlipEntry({
    required this.id,
    required this.createdAt,
    required this.count,
    this.context = '',
    this.note = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'count': count,
        'context': context,
        'note': note,
      };

  factory SlipEntry.fromJson(Map<String, dynamic> json) => SlipEntry(
        id: json['id'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        count: (json['count'] as num).toInt(),
        context: json['context'] as String? ?? '',
        note: json['note'] as String? ?? '',
      );

  static String encodeList(List<SlipEntry> list) => jsonEncode(
        list.map((e) => e.toJson()).toList(),
      );

  static List<SlipEntry> decodeList(String value) {
    final data = jsonDecode(value) as List<dynamic>;
    return data
        .map((e) => SlipEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

class SavingsGoal {
  final String id;
  final String name;
  final double targetAmount;
  final DateTime targetDate;
  final DateTime createdAt;
  final bool achieved;

  const SavingsGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.targetDate,
    required this.createdAt,
    this.achieved = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'targetAmount': targetAmount,
        'targetDate': targetDate.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'achieved': achieved,
      };

  factory SavingsGoal.fromJson(Map<String, dynamic> json) => SavingsGoal(
        id: json['id'] as String,
        name: json['name'] as String,
        targetAmount: (json['targetAmount'] as num).toDouble(),
        targetDate: DateTime.parse(json['targetDate'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
        achieved: (json['achieved'] as bool?) ?? false,
      );

  static String encodeList(List<SavingsGoal> list) => jsonEncode(
        list.map((e) => e.toJson()).toList(),
      );

  static List<SavingsGoal> decodeList(String value) {
    final data = jsonDecode(value) as List<dynamic>;
    return data
        .map((e) => SavingsGoal.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

class DailyCheckIn {
  final DateTime date; // Store as date (no time semantics)
  final int mood; // 1..5
  final int urge; // 1..10
  final String notes;

  const DailyCheckIn({
    required this.date,
    required this.mood,
    required this.urge,
    this.notes = '',
  });

  DateTime get normalizedDate => DateTime(date.year, date.month, date.day);

  Map<String, dynamic> toJson() => {
        'date': normalizedDate.toIso8601String(),
        'mood': mood,
        'urge': urge,
        'notes': notes,
      };

  factory DailyCheckIn.fromJson(Map<String, dynamic> json) => DailyCheckIn(
        date: DateTime.parse(json['date'] as String),
        mood: json['mood'] as int,
        urge: json['urge'] as int,
        notes: json['notes'] as String? ?? '',
      );

  static String encodeList(List<DailyCheckIn> list) => jsonEncode(
        list.map((e) => e.toJson()).toList(),
      );

  static List<DailyCheckIn> decodeList(String value) {
    final data = jsonDecode(value) as List<dynamic>;
    return data
        .map((e) => DailyCheckIn.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}



