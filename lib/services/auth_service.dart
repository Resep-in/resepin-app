import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static bool isCheckingLoginStatus = false;

  Future<void> setLoginStatus(bool isLoggedIn) async {
    print('Setting login status: $isLoggedIn');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
  }

  static Future<bool> getLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  // Get stored token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Validate login - check if user is logged in
  static Future<void> validateLogin() async {
    if (isCheckingLoginStatus) {
      return;
    }
    isCheckingLoginStatus = true;

    bool isLoggedIn = await getLoginStatus();
    if (!isLoggedIn) {
      Get.offAllNamed('/login');
    }

    isCheckingLoginStatus = false;
  }
}