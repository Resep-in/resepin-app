import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:resepin/api/api_controller.dart';
import 'package:resepin/services/auth_service.dart';

class PasswordController extends GetxController {
  var isLoading = false.obs;

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    isLoading.value = true;

    try {
      String? token = await AuthService.getToken();
      if (token == null) {
        Get.snackbar(
          'Error',
          'Token not found. Please login again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }

      final Map<String, dynamic> requestBody = {
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': confirmPassword,
      };

      print('🔐 Changing password...');
      print('📤 Request: ${requestBody.keys.join(', ')}');

      final response = await http.post(
        Uri.parse(RoutesApi.changePasswordUrl()),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('🔐 Password Change Status: ${response.statusCode}');
      print('🔐 Password Change Response: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['message'] == 'Password changed successfully' || 
            responseData['success'] == true) {
          
          Get.snackbar(
            'Success',
            responseData['message'] ?? 'Password changed successfully',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );

          return true;
        } else {
          Get.snackbar(
            'Error',
            responseData['message'] ?? 'Failed to change password',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
          return false;
        }
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        String errorMessage = 'Failed to change password';

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
        } else if (errorData['message'] != null) {
          errorMessage = errorData['message'];
        }

        Get.snackbar(
          'Error',
          errorMessage,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 5),
        );

        return false;
      }
    } catch (e) {
      print('❌ Password Change Error: $e');
      
      Get.snackbar(
        'Error',
        'Connection error occurred. Please check your internet connection.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Method untuk validasi input password
  bool validatePasswordInput({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) {
    if (oldPassword.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Current password cannot be empty',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }

    if (newPassword.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'New password cannot be empty',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }

    if (newPassword.trim().length < 6) {
      Get.snackbar(
        'Error',
        'New password must be at least 6 characters',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }

    if (confirmPassword.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Password confirmation cannot be empty',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }

    if (newPassword.trim() != confirmPassword.trim()) {
      Get.snackbar(
        'Error',
        'Password confirmation does not match',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }

    if (oldPassword.trim() == newPassword.trim()) {
      Get.snackbar(
        'Error',
        'New password must be different from current password',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }

    return true;
  }
}