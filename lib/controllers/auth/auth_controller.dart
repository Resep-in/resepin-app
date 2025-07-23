import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:resepin/api/api_controller.dart';
import 'package:resepin/services/auth_service.dart';
import 'package:resepin/models/auth_response_model.dart';
import 'package:resepin/models/user_model.dart';
import 'package:resepin/pages/main_page.dart';

class LoginController extends GetxController {
  var isLoading = false.obs;
  var isLoadingUser = false.obs;
  var accessToken = ''.obs;
  var currentUser = Rxn<User>();
  final AuthService authService = AuthService();

  // Login method
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    isLoading.value = true;

    try {
      final response = await http.post(
        Uri.parse(RoutesApi.loginUrl()),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('Login Status: ${response.statusCode}');
      print('Login Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final authResponse = AuthResponse.fromLoginJson(responseData);
        
        // Simpan token dan user data
        if (authResponse.token != null) {
          accessToken.value = authResponse.token!;
          await _saveTokenToStorage(authResponse.token!);
        }
        
        if (authResponse.user != null) {
          currentUser.value = authResponse.user;
          await _saveUserToStorage(authResponse.user!);
        }

        // Set login status
        await authService.setLoginStatus(true);

        Get.snackbar(
          'Login Berhasil',
          'Selamat datang ${authResponse.user?.name ?? "User"}!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 2),
        );

        // Navigate to main page
        Get.offAll(() => MainPage());

        return authResponse;
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        
        String errorMessage = 'Login gagal';
        if (errorData['message'] != null) {
          errorMessage = errorData['message'];
        } else if (errorData['errors'] != null) {
          errorMessage = _formatErrors(errorData['errors']);
        }

        Get.snackbar(
          'Login Gagal',
          errorMessage,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 3),
        );

        return AuthResponse.fromError(
          message: errorMessage,
          errors: errorData['errors'],
        );
      }
    } catch (e) {
      print('Login Error: $e');
      
      Get.snackbar(
        'Error',
        'Terjadi kesalahan koneksi. Periksa internet Anda.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );

      return AuthResponse.fromError(
        message: 'Terjadi kesalahan koneksi',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Get current user data from API
  Future<void> getCurrentUser() async {
    if (accessToken.value.isEmpty) {
      print('No token available');
      return;
    }

    isLoadingUser.value = true;

    try {
      final response = await http.get(
        Uri.parse(RoutesApi.userUrl()), // Tambahkan ini ke RoutesApi
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${accessToken.value}',
        },
      );

      print('User Status: ${response.statusCode}');
      print('User Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final authResponse = AuthResponse.fromUserJson(responseData);
        
        if (authResponse.user != null) {
          currentUser.value = authResponse.user;
          await _saveUserToStorage(authResponse.user!);
        }
      } else {
        print('Failed to get user data: ${response.statusCode}');
        // Token mungkin expired, logout user
        if (response.statusCode == 401) {
          await logout();
        }
      }
    } catch (e) {
      print('Get User Error: $e');
    } finally {
      isLoadingUser.value = false;
    }
  }

  // Logout method
  Future<void> logout() async {
    try {
      if (accessToken.value.isNotEmpty) {
        await http.post(
          Uri.parse(RoutesApi.logoutUrl()),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer ${accessToken.value}',
          },
        );
      }
    } catch (e) {
      print('Logout API Error: $e');
    } finally {
      // Clear local data
      accessToken.value = '';
      currentUser.value = null;
      await authService.setLoginStatus(false);
      await _removeTokenFromStorage();
      await _removeUserFromStorage();

      Get.snackbar(
        'Logout Berhasil',
        'Anda telah keluar dari aplikasi',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );

      Get.offAllNamed('/login');
    }
  }

  // Storage helper methods
  Future<void> _saveTokenToStorage(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> _saveUserToStorage(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(user.toJson()));
  }

  Future<void> _removeTokenFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Future<void> _removeUserFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
  }

  // Load saved data
  Future<void> loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    
    final token = prefs.getString('auth_token');
    if (token != null) {
      accessToken.value = token;
      // Get fresh user data from API
      await getCurrentUser();
    }
    
    final userDataString = prefs.getString('user_data');
    if (userDataString != null && currentUser.value == null) {
      final userData = jsonDecode(userDataString);
      currentUser.value = User.fromJson(userData);
    }
  }

  String _formatErrors(Map<String, dynamic> errors) {
    List<String> errorMessages = [];
    errors.forEach((key, value) {
      if (value is List) {
        errorMessages.addAll(value.cast<String>());
      } else {
        errorMessages.add(value.toString());
      }
    });
    return errorMessages.join('\n');
  }

  bool validateLoginInput({
    required String email,
    required String password,
  }) {
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Error',
        'Email dan password harus diisi',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }

    if (!GetUtils.isEmail(email)) {
      Get.snackbar(
        'Error',
        'Format email tidak valid',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }

    return true;
  }

  @override
  void onInit() {
    super.onInit();
    loadSavedData();
  }
}