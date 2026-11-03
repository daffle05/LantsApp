
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthUser {
  final int id;
  final String fullName;
  final String email;
  final String role;
  final String status;

  AuthUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.status,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: int.parse(json['id'].toString()),
      fullName: json['full_name'].toString(),
      email: json['email'].toString(),
      role: json['role'].toString(),
      status: json['status'].toString(),
    );
  }
}

class AuthService {
  // Address of the PHP backend running in XAMPP
  static const String baseUrl = 'http://localhost/lantsapp_api/';

  static String lastError = '';

  // REGISTER ACCOUNT
  static Future<String?> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {
    lastError = '';

    try {
      final response = await http
          .post(
            Uri.parse('${baseUrl}register.php'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'full_name': fullName.trim(),
              'email': email.trim(),
              'password': password,
              'role': role,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return null;
      }

      return data['message']?.toString() ??
          'Registration failed. Please try again.';
    } catch (e) {
      return 'Cannot connect to the server. Check XAMPP and your internet settings.';
    }
  }

  // LOGIN ACCOUNT
  static Future<AuthUser?> login({
    required String email,
    required String password,
  }) async {
    lastError = '';

    try {
      final response = await http
          .post(
            Uri.parse('${baseUrl}login.php'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'email': email.trim(),
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return AuthUser.fromJson(
          data['user'] as Map<String, dynamic>,
        );
      }

      lastError = data['message']?.toString() ??
          'Invalid email or password.';

      return null;
    } catch (e) {
      lastError =
          'Cannot connect to the server. Check XAMPP and your internet settings.';
      return null;
    }
  }
}
