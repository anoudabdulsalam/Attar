import 'dart:convert';
import 'package:http/http.dart' as http;

class PasswordService {
static const String baseUrl = 'http://localhost:5000/api/auth';

  static Future<void> sendCode(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/forgot-password'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['message']);
    }
  }

  static Future<void> verifyCode(
    String email,
    String code,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verify-reset-code'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'code': code,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['message']);
    }
  }

  static Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reset-password'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'code': code,
        'newPassword': newPassword,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['message']);
    }
  }
}