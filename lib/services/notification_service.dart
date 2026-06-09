import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';
import 'api_config.dart';

class NotificationService {
  static Future<List<NotificationModel>> getNotifications(String role) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null || userId.isEmpty) {
      throw Exception('UserId غير موجود');
    }

    final url = Uri.parse(
      '${ApiConfig.baseUrl}/api/notifications/$userId/$role',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List data = decoded['notifications'] ?? [];

      return data.map((e) => NotificationModel.fromJson(e)).toList();
    } else {
      throw Exception('فشل تحميل الإشعارات: ${response.body}');
    }
  }

  static Future<void> markAsRead(String id) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/notifications/$id/read');

    final response = await http.put(url);

    if (response.statusCode != 200) {
      throw Exception('فشل تحديث الإشعار');
    }
  }

  static Future<void> createNotification({
    required String userId,
    required String targetRole,
    required String title,
    required String body,
    required int type,
    String? herbName,
    String? imageUrl,
    String? storeName,
    String? price,
    String? senderName,
    Map<String, dynamic>? herbPayload,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/notifications');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'targetRole': targetRole,
        'title': title,
        'body': body,
        'type': type,
        'herbName': herbName,
        'imageUrl': imageUrl,
        'storeName': storeName,
        'price': price,
        'senderName': senderName,
        'herbPayload': herbPayload,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('فشل إنشاء الإشعار: ${response.body}');
    }
  }
}