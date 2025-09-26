import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

class StorageService {
  static const _profileKey = 'profile';
  static const _cravingsKey = 'cravings';
  static const _slipsKey = 'slips';
  static const _goalsKey = 'goals';
  static const _checkinsKey = 'checkins';
  static const _practiceCountsKey = 'practice_counts';

  Future<SharedPreferences> _prefs() => SharedPreferences.getInstance();

  Future<UserProfile?> getProfile() async {
    final prefs = await _prefs();
    final raw = prefs.getString(_profileKey);
    if (raw == null || raw.isEmpty) return null;
    return UserProfile.decode(raw);
  }

  Future<void> saveProfile(UserProfile profile) async {
    final prefs = await _prefs();
    await prefs.setString(_profileKey, profile.encode());
  }

  Future<List<CravingEntry>> getCravings() async {
    final prefs = await _prefs();
    final raw = prefs.getString(_cravingsKey);
    if (raw == null || raw.isEmpty) return [];
    return CravingEntry.decodeList(raw);
  }

  Future<void> saveCravings(List<CravingEntry> entries) async {
    final prefs = await _prefs();
    await prefs.setString(_cravingsKey, CravingEntry.encodeList(entries));
  }

  Future<void> addCraving(CravingEntry entry) async {
    final current = await getCravings();
    final next = [entry, ...current];
    await saveCravings(next);
  }

  Future<void> removeCraving(String id) async {
    final current = await getCravings();
    current.removeWhere((e) => e.id == id);
    await saveCravings(current);
  }

  // Slips (cigarettes smoked after quit)
  Future<List<SlipEntry>> getSlips() async {
    final prefs = await _prefs();
    final raw = prefs.getString(_slipsKey);
    if (raw == null || raw.isEmpty) return [];
    return SlipEntry.decodeList(raw);
  }

  Future<void> saveSlips(List<SlipEntry> entries) async {
    final prefs = await _prefs();
    await prefs.setString(_slipsKey, SlipEntry.encodeList(entries));
  }

  Future<void> addSlip(SlipEntry entry) async {
    final current = await getSlips();
    await saveSlips([entry, ...current]);
  }

  Future<void> removeSlip(String id) async {
    final current = await getSlips();
    current.removeWhere((e) => e.id == id);
    await saveSlips(current);
  }

  // Goals
  Future<List<SavingsGoal>> getGoals() async {
    final prefs = await _prefs();
    final raw = prefs.getString(_goalsKey);
    if (raw == null || raw.isEmpty) return [];
    return SavingsGoal.decodeList(raw);
  }

  Future<void> saveGoals(List<SavingsGoal> goals) async {
    final prefs = await _prefs();
    await prefs.setString(_goalsKey, SavingsGoal.encodeList(goals));
  }

  Future<void> addGoal(SavingsGoal goal) async {
    final current = await getGoals();
    await saveGoals([goal, ...current]);
  }

  Future<void> updateGoal(SavingsGoal updated) async {
    final current = await getGoals();
    final next = current.map((g) => g.id == updated.id ? updated : g).toList();
    await saveGoals(next);
  }

  Future<void> removeGoal(String id) async {
    final current = await getGoals();
    current.removeWhere((g) => g.id == id);
    await saveGoals(current);
  }

  // Daily Check-ins
  Future<List<DailyCheckIn>> getCheckIns() async {
    final prefs = await _prefs();
    final raw = prefs.getString(_checkinsKey);
    if (raw == null || raw.isEmpty) return [];
    return DailyCheckIn.decodeList(raw);
  }

  Future<void> saveCheckIns(List<DailyCheckIn> checkins) async {
    final prefs = await _prefs();
    await prefs.setString(_checkinsKey, DailyCheckIn.encodeList(checkins));
  }

  Future<void> upsertCheckIn(DailyCheckIn checkin) async {
    final current = await getCheckIns();
    final normalizedDate = checkin.normalizedDate;
    final idx = current.indexWhere((c) => c.normalizedDate == normalizedDate);
    if (idx >= 0) {
      current[idx] = checkin;
    } else {
      current.insert(0, checkin);
    }
    await saveCheckIns(current);
  }

  // SOS Breathing practice counters (per-day counts stored as dateString -> int)
  Future<Map<String, int>> _getPracticeMap() async {
    final prefs = await _prefs();
    final raw = prefs.getString(_practiceCountsKey);
    if (raw == null || raw.isEmpty) return {};
    final decoded = Map<String, dynamic>.from(jsonDecode(raw) as Map);
    return decoded.map((k, v) => MapEntry(k, (v as num).toInt()));
  }

  Future<void> _savePracticeMap(Map<String, int> map) async {
    final prefs = await _prefs();
    await prefs.setString(_practiceCountsKey, jsonEncode(map));
  }

  String _dateKey(DateTime d) => DateTime(d.year, d.month, d.day).toIso8601String();

  Future<int> getTodayPracticeCount() async {
    final map = await _getPracticeMap();
    final key = _dateKey(DateTime.now());
    return map[key] ?? 0;
  }

  Future<void> incrementTodayPracticeCount() async {
    final map = await _getPracticeMap();
    final key = _dateKey(DateTime.now());
    map[key] = (map[key] ?? 0) + 1;
    await _savePracticeMap(map);
  }
}



