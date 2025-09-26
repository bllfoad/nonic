import 'dart:convert';

class UserProfile {
  final String name;
  final DateTime quitDate;
  final double packPrice; // in local currency
  final int cigarettesPerDay;

  const UserProfile({
    required this.name,
    required this.quitDate,
    required this.packPrice,
    required this.cigarettesPerDay,
  });

  factory UserProfile.empty() => UserProfile(
        name: '',
        quitDate: DateTime.now(),
        packPrice: 10,
        cigarettesPerDay: 10,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'quitDate': quitDate.toIso8601String(),
        'packPrice': packPrice,
        'cigarettesPerDay': cigarettesPerDay,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        name: json['name'] ?? '',
        quitDate: DateTime.parse(json['quitDate'] as String),
        packPrice: (json['packPrice'] as num).toDouble(),
        cigarettesPerDay: json['cigarettesPerDay'] as int,
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



