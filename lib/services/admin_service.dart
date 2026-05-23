import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class AdminService {
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/admin/login');

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
      await prefs.setString('userId', data['admin']['id']);
      await prefs.setString('role', data['admin']['role']);
      return data;
    } else {
      throw Exception(data['message'] ?? 'Login failed');
    }
  }

  static Future<List<dynamic>> getAllUsers() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/admin/users');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['users'];
    } else {
      throw Exception('Failed to load users');
    }
  }

  static Future<void> deleteUser(String id) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/admin/users/$id');
    final response = await http.delete(url);
    if (response.statusCode != 200) {
      throw Exception('Failed to delete user');
    }
  }

  static Future<List<dynamic>> getStoreStats() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/admin/stats');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['stats'];
    } else {
      throw Exception('Failed to load stats');
    }
  }

  static Future<List<dynamic>> getMessages() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/admin/messages');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['messages'];
    } else {
      throw Exception('Failed to load messages');
    }
  }
}
