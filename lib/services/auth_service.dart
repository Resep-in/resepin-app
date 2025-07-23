import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static bool isCheckingLoginStatus = false;

  static const String _loginStatusKey = 'isLoggedIn';
  static const String _tokenKey = 'auth_token';

  static Future<void> setLoginStatus(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loginStatusKey, isLoggedIn);
  }

  static Future<bool> getLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loginStatusKey) ?? false;
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loginStatusKey);
    await prefs.remove(_tokenKey);
    await prefs.remove('user_data');
  }

  static Future<bool> isAuthenticated() async {
    bool isLoggedIn = await getLoginStatus();
    String? token = await getToken();
    return isLoggedIn && token != null && token.isNotEmpty;
  }

  static Future<void> validateLogin() async {
    if (isCheckingLoginStatus) {
      return;
    }
    isCheckingLoginStatus = true;

    bool isAuthenticated = await AuthService.isAuthenticated();
    
    if (!isAuthenticated) {
      Get.offAllNamed('/login');
    }

    isCheckingLoginStatus = false;
  }
}