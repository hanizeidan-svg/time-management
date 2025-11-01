import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static final PreferencesService _instance = PreferencesService._internal();
  factory PreferencesService() => _instance;
  PreferencesService._internal();

  static const String _lastPersonIdKey = 'last_person_id';
  static const String _lastDayKey = 'last_day';
  static const String _lastPersonNameKey = 'last_person_name';

  // Save last selected person
  Future<void> saveLastPerson(int personId, String personName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastPersonIdKey, personId);
    await prefs.setString(_lastPersonNameKey, personName);
  }

  // Get last selected person ID
  Future<int?> getLastPersonId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_lastPersonIdKey);
  }

  // Get last selected person name
  Future<String?> getLastPersonName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastPersonNameKey);
  }

  // Save last selected day
  Future<void> saveLastDay(String day) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastDayKey, day);
  }

  // Get last selected day
  Future<String?> getLastDay() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastDayKey);
  }

  // Clear all preferences (optional)
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
