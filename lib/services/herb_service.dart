import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class HerbService {
  static Future<List<dynamic>> getAllHerbs() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/herbs');

    final response = await http.get(url);
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data['herbs'] ?? [];
    } else {
      throw Exception(data['message'] ?? 'Failed to fetch herbs');
    }
  }

  static Future<Map<String, dynamic>> addHerb({
    required String name,
    required String benefits,
    required String usageMethod,
    required double price,
    required int quantity,
    required String category,
    required String imageUrl,
    required String storeOwnerId,
    required String storeName,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/herbs');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'benefits': benefits,
        'usageMethod': usageMethod,
        'price': price,
        'quantity': quantity,
        'category': category,
        'imageUrl': imageUrl,
        'storeOwnerId': storeOwnerId,
        'storeName': storeName,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return data['herb'];
    } else {
      throw Exception(data['message'] ?? 'Failed to add herb');
    }
  }
}