import 'package:shared_preferences/shared_preferences.dart';

class AuthUtils {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Get stored value
  static String? getUserId() {
    return _prefs?.getString("userId");
  }

  // Get stored value
  static String? getToken() {
    return _prefs?.getString("jwt_token");
  }

  // Save values
  static Future<void> setUserId(String userId) async {
    await _prefs?.setString("userId", userId);
  }

  // Save values
  static Future<void> setToken(String token) async {
    await _prefs?.setString("jwt_token", token);
  }

  // Remove value
  static Future<void> clearData() async {
    await _prefs?.remove("userId");
    await _prefs?.remove("token");
    await _prefs?.clear();
  }

  //Expose instance if needed
  static SharedPreferences? get instance => _prefs;
}
