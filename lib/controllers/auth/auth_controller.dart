import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:resepin/pages/on_boarding/auth/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:resepin/api/api_controller.dart';
import 'package:resepin/services/auth_service.dart';
import 'package:resepin/models/auth_response_model.dart';
import 'package:resepin/models/user_model.dart';
import 'package:resepin/pages/main_page.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;
  var isLoadingUser = false.obs;
  var accessToken = ''.obs;
  var currentUser = Rxn<User>();
  final AuthService authService = AuthService();

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

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final authResponse = AuthResponse.fromLoginJson(responseData);
        
        if (authResponse.token != null) {
          accessToken.value = authResponse.token!;
          await AuthService.setToken(authResponse.token!);
        }
        
        if (authResponse.user != null) {
          currentUser.value = authResponse.user;
          await _saveUserToStorage(authResponse.user!);
        }

        await AuthService.setLoginStatus(true);

        Get.snackbar(
          'Login Berhasil',
          'Selamat datang ${authResponse.user?.name ?? "User"}!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 2),
        );

        Get.offAll(() => MainPage());

        return authResponse;
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        
        String errorMessage = 'Login gagal';
        if (errorData['message'] != null) {
          errorMessage = errorData['message'];
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

  Future<void> getCurrentUser() async {
    if (accessToken.value.isEmpty) {
      return;
    }

    isLoadingUser.value = true;

    try {
      final response = await http.get(
        Uri.parse(RoutesApi.userUrl()),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${accessToken.value}',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final authResponse = AuthResponse.fromUserJson(responseData);
        
        if (authResponse.user != null) {
          currentUser.value = authResponse.user;
          await _saveUserToStorage(authResponse.user!);
        }
      } else {
        if (response.statusCode == 401) {
          await logout();
        }
      }
    } catch (e) {
      // Silent fail
    } finally {
      isLoadingUser.value = false;
    }
  }

  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    isLoading.value = true;

    try {
      final response = await http.post(
        Uri.parse(RoutesApi.registerUrl()),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        
        // Jika register berhasil, langsung login atau redirect ke login
        Get.snackbar(
          'Register Berhasil',
          'Akun berhasil dibuat. Silakan login.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 2),
        );

        // Redirect ke login page
        Get.off(() => LoginPage());

        return AuthResponse(
          success: true,
          message: responseData['message'] ?? 'Register berhasil',
        );
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        
        String errorMessage = 'Register gagal';
        if (errorData['message'] != null) {
          errorMessage = errorData['message'];
        }

        // Handle validation errors
        if (errorData['errors'] != null) {
          Map<String, dynamic> errors = errorData['errors'];
          List<String> errorMessages = [];
          
          errors.forEach((key, value) {
            if (value is List && value.isNotEmpty) {
              errorMessages.add(value.first.toString());
            }
          });
          
          if (errorMessages.isNotEmpty) {
            errorMessage = errorMessages.join('\n');
          }
        }

        Get.snackbar(
          'Register Gagal',
          errorMessage,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 5),
        );

        return AuthResponse.fromError(
          message: errorMessage,
          errors: errorData['errors'],
        );
      }
    } catch (e) {
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
      // Silent fail
    } finally {
      accessToken.value = '';
      currentUser.value = null;
      
      await AuthService.clearAuthData();

      Get.snackbar(
        'Logout Berhasil',
        'Anda telah keluar dari aplikasi',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );

      Get.offAll(() => LoginPage());
    }
  }

  Future<void> _saveUserToStorage(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(user.toJson()));
  }

  Future<void> loadSavedData() async {
    try {
      final token = await AuthService.getToken();
      if (token != null && token.isNotEmpty) {
        accessToken.value = token;
      }
      
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');
      if (userDataString != null) {
        final userData = jsonDecode(userDataString);
        currentUser.value = User.fromJson(userData);
      }
    } catch (e) {
      await AuthService.clearAuthData();
    }
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

  // Tambahkan method validasi register
  bool validateRegisterInput({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) {
    if (name.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Nama harus diisi',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }

    if (name.trim().length < 2) {
      Get.snackbar(
        'Error',
        'Nama minimal 2 karakter',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }

    if (email.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Email harus diisi',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }

    if (!GetUtils.isEmail(email.trim())) {
      Get.snackbar(
        'Error',
        'Format email tidak valid',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }

    if (password.isEmpty) {
      Get.snackbar(
        'Error',
        'Password harus diisi',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }

    if (password.length < 6) {
      Get.snackbar(
        'Error',
        'Password minimal 6 karakter',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }

    if (password != passwordConfirmation) {
      Get.snackbar(
        'Error',
        'Konfirmasi password tidak cocok',
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