import 'package:shared_preferences/shared_preferences.dart';

class StudentPrefs {
  StudentPrefs(this._prefs);

  final SharedPreferences _prefs;

  static const _keyLastQuery = 'last_query';

  static Future<StudentPrefs> create() async {
    return StudentPrefs(await SharedPreferences.getInstance());
  }

  String lastQuery() => _prefs.getString(_keyLastQuery) ?? '';

  Future<void> saveQuery(String query) async {
    final cleaned = query.trim().toUpperCase();
    if (cleaned.isEmpty) {
      await _prefs.remove(_keyLastQuery);
    } else {
      await _prefs.setString(_keyLastQuery, cleaned);
    }
  }
}
