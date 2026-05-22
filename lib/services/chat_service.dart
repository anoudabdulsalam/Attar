import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ChatService {
  static Future<Map<String, dynamic>> createConversation({
    required String user1Id,
    required String user1Role,
    required String user2Id,
    required String user2Role,
    String? chatName,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/chat/conversation'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user1Id': user1Id,
        'user1Role': user1Role,
        'user2Id': user2Id,
        'user2Role': user2Role,
        'chatName': chatName,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(response.body);
    }

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderRole,
    required String receiverId,
    required String receiverRole,
    required String text,
    String type = 'text',
    Map<String, dynamic>? herb,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/chat/message'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'conversationId': conversationId,
        'senderId': senderId,
        'senderRole': senderRole,
        'receiverId': receiverId,
        'receiverRole': receiverRole,
        'text': text,
        'type': type,
        'herb': herb,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(response.body);
    }

    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> getMessages(String conversationId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/chat/messages/$conversationId'),
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> getConversations(String userId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/chat/conversations/$userId'),
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    return jsonDecode(response.body);
  }

  static Future<void> markMessagesAsRead({
    required String conversationId,
    required String userId,
  }) async {
    await http.put(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/chat/messages/read/$conversationId/$userId',
      ),
    );
  }
}