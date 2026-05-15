import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class AiChatService {
  static Future<String> sendMessage(String message) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/ai/herb-chat');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'message': message,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data['reply'] ?? 'لم أتمكن من الحصول على رد.';
    } else {
      throw Exception(data['message'] ?? 'فشل الاتصال بالمساعد الذكي');
    }
  }
}