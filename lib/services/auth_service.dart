import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class AuthService {
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String role,
    String? fullName,
    int? age,
    String? ownerName,
    String? storeName,
    String? storeLocation,
    int? yearsOfExperience,
    String? certificateUrl,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/auth/register');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'role': role,
        'fullName': fullName,
        'age': age,
        'ownerName': ownerName,
        'storeName': storeName,
        'storeLocation': storeLocation,
        'yearsOfExperience': yearsOfExperience,
        'certificateUrl': certificateUrl,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', data['user']['id']);
      await prefs.setString('role', data['user']['role']);
      return data;
    } else {
      throw Exception(data['message'] ?? 'Registration failed');
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/auth/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', data['user']['id']);
      await prefs.setString('role', data['user']['role']);
      return data;
    } else {
      throw Exception(data['message'] ?? 'Login failed');
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('role');
  }
}