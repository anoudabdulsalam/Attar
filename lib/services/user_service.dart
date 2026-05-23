import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class UserService {
  static Future<Map<String, dynamic>> getUserById(String id) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/users/$id');

    final response = await http.get(url);
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data['user'];
    } else {
      throw Exception(data['message'] ?? 'Failed to get user');
    }
  }

  static Future<Map<String, dynamic>> updateUserById(
  String id,
  Map<String, dynamic> body,
) async {
  final url = Uri.parse('${ApiConfig.baseUrl}/api/users/$id');

  final response = await http.put(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(body),
  );

  final data = jsonDecode(response.body);

  if (response.statusCode == 200) {
    return data['user'];
  } else {
    throw Exception(data['message'] ?? 'Failed to update user');
  }
}
static Future<List<dynamic>> getAllUsers() async {
  final url = Uri.parse('${ApiConfig.baseUrl}/api/users');

  final response = await http.get(url);
  final data = jsonDecode(response.body);

  if (response.statusCode == 200) {
    return data['users'];
  } else {
    throw Exception(data['message'] ?? 'Failed to get users');
  }
}

  static Future<void> logInteraction(String userId, String herbId, String type) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/users/$userId/interact');

    try {
      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'herbId': herbId,
          'type': type,
        }),
      );
    } catch (e) {
      // Ignore errors for logging
    }
  }
}