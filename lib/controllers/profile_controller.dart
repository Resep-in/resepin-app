import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:resepin/api/api_controller.dart';
import 'package:resepin/controllers/auth/auth_controller.dart';
import 'package:resepin/models/user_model.dart';
import 'package:resepin/services/auth_service.dart';

class ProfileController extends GetxController {
  var isLoading = false.obs;
  var isImageUploading = false.obs;

  Future<bool> updateProfile({
    required String name,
    required String email,
    File? image,
  }) async {
    isLoading.value = true;

    try {
      String? token = await AuthService.getToken();
      if (token == null) {
        Get.snackbar(
          'Error',
          'Token tidak ditemukan. Silakan login ulang.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(RoutesApi.editProfileUrl()),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      request.fields['name'] = name;
      request.fields['email'] = email;

      if (image != null) {
        isImageUploading.value = true;
        var stream = http.ByteStream(image.openRead());
        var length = await image.length();
        var multipartFile = http.MultipartFile(
          'image',
          stream,
          length,
          filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        request.files.add(multipartFile);
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['message'] == 'Profile updated successfully' || 
            responseData['success'] == true) {
          
          if (responseData['user'] != null) {
            final AuthController authController = Get.find<AuthController>();
            authController.currentUser.value = User.fromJson(responseData['user']);
            await AuthService.saveUserData(authController.currentUser.value!);
          }

          Get.snackbar(
            'Berhasil',
            responseData['message'] ?? 'Profile berhasil diperbarui',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );

          return true;
        } else {
          Get.snackbar(
            'Error',
            responseData['message'] ?? 'Gagal memperbarui profile',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
          return false;
        }
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        String errorMessage = 'Gagal memperbarui profile';

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
      Get.snackbar(
        'Error',
        'Terjadi kesalahan koneksi. Periksa internet Anda.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );

      return false;
    } finally {
      isLoading.value = false;
      isImageUploading.value = false;
    }
  }

  bool validateProfileInput({
    required String name,
    required String email,
  }) {
    if (name.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Nama tidak boleh kosong',
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
        'Email tidak boleh kosong',
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

    return true;
  }
}