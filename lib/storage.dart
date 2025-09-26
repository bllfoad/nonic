import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

class StorageService {
  static const _profileKey = 'profile';
  static const _cravingsKey = 'cravings';

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
}



