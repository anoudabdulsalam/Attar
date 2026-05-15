import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ContactService {
  static Future<void> sendMessage({
    required String name,
    required String email,
    required String subject,
    required String message,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/contact');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'subject': subject,
        'message': message,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to send message');
    }
  }
}