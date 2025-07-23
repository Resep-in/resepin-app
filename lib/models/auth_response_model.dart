import 'user_model.dart';

class AuthResponse {
  final bool success;
  final String message;
  final String? token;
  final User? user;
  final Map<String, dynamic>? errors;

  AuthResponse({
    required this.success,
    required this.message,
    this.token,
    this.user,
    this.errors,
  });

  // Factory untuk login response (dengan token)
  factory AuthResponse.fromLoginJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: true, // Status 200 = success
      message: json['message'] ?? 'Login berhasil',
      token: json['token'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      errors: null,
    );
  }

  // Factory untuk user response (tanpa token)
  factory AuthResponse.fromUserJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: true,
      message: 'Data user berhasil diambil',
      token: null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      errors: null,
    );
  }

  // Factory untuk error response
  factory AuthResponse.fromError({
    required String message,
    Map<String, dynamic>? errors,
  }) {
    return AuthResponse(
      success: false,
      message: message,
      token: null,
      user: null,
      errors: errors,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'token': token,
      'user': user?.toJson(),
      'errors': errors,
    };
  }
}