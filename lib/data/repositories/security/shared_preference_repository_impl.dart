import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_list_app/domain/repositories/security/shared_preference_repository.dart';

class SharedPreferencesRepositoryImpl extends SharedPreferencesRepository {
  late SharedPreferences _prefs;

  SharedPreferencesRepositoryImpl() {
    SharedPreferences.getInstance().then((value) => _prefs = value);
  }

  Future<bool> clearAll() async {
    return await _prefs.clear();
  }

  /*Future<void> _set(String key, value) async {
    if (value is bool) {
      await _prefs.setBool(key, value);
    } else if (value is String) {
      await _prefs.setString(key, value);
    } else if (value is double) {
      await _prefs.setDouble(key, value);
    } else if (value is int) {
      await _prefs.setInt(key, value);
    } else if (value is List<String>) {
      await _prefs.setStringList(key, value);
    }
  }

  dynamic _get(String key, {dynamic defaultValue}) {
    if (defaultValue is bool) {
      return _prefs.getBool(key) ?? defaultValue;
    } else if (defaultValue is String) {
      return _prefs.getString(key) ?? defaultValue;
    } else if (defaultValue is double) {
      return _prefs.getDouble(key) ?? defaultValue;
    } else if (defaultValue is int) {
      return _prefs.getInt(key) ?? defaultValue;
    } else if (defaultValue is List<String>) {
      return _prefs.getStringList(key) ?? defaultValue;
    }
  }

  Future<bool> _remove(String key) async {
    return await _prefs.remove(key);
  }*/
}
