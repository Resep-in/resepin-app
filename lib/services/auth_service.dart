import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

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

  static Future<void> saveUserData(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save user data as JSON string
      await prefs.setString('user_data', jsonEncode(user.toJson()));
      
      // Optionally save individual fields for easier access
      await prefs.setString('user_email', user.email ?? '');
      await prefs.setString('user_name', user.name ?? '');
      // Add other fields as needed
      
      print('✅ User data saved successfully');
    } catch (e) {
      print('❌ Error saving user data: $e');
      throw Exception('Failed to save user data: $e');
    }
  }
  
  // Also add a method to load saved data
  static Future<User?> getSavedUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user_data');
      
      if (userData != null) {
        return User.fromJson(jsonDecode(userData));
      }
      return null;
    } catch (e) {
      print('❌ Error loading user data: $e');
      return null;
    }
  }
}