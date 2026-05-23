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

  static Future<Map<String, dynamic>> getHerbById(String herbId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/herbs/$herbId');

    final response = await http.get(url);
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data['herb'];
    } else {
      throw Exception(data['message'] ?? 'Failed to fetch herb');
    }
  }

  static Future<Map<String, dynamic>> addComment({
  required String herbId,
  required String userId,
  required String userName,
  required String userRole,
  required String text,
}) async {
  final url = Uri.parse('${ApiConfig.baseUrl}/api/herbs/$herbId/comments');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'userId': userId,
      'userName': userName,
      'userRole': userRole,
      'text': text,
    }),
  );

  final data = jsonDecode(response.body);

  if (response.statusCode == 200) {
    return data['herb'];
  } else {
    throw Exception(data['message'] ?? 'Failed to add comment');
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
    bool onSale = false,
    double? salePrice,
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
        'onSale': onSale,
        'salePrice': salePrice,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return data['herb'];
    } else {
      throw Exception(data['message'] ?? 'Failed to add herb');
    }
  }

  static Future<Map<String, dynamic>> updateHerb({
    required String herbId,
    String? name,
    String? benefits,
    String? usageMethod,
    double? price,
    int? quantity,
    String? category,
    String? imageUrl,
    bool? onSale,
    double? salePrice,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/herbs/$herbId');

    final Map<String, dynamic> body = {};

    if (name != null) body['name'] = name;
    if (benefits != null) body['benefits'] = benefits;
    if (usageMethod != null) body['usageMethod'] = usageMethod;
    if (price != null) body['price'] = price;
    if (quantity != null) body['quantity'] = quantity;
    if (category != null) body['category'] = category;
    if (imageUrl != null) body['imageUrl'] = imageUrl;
    if (onSale != null) body['onSale'] = onSale;
    body['salePrice'] = salePrice;

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data['herb'];
    } else {
      throw Exception(data['message'] ?? 'Failed to update herb');
    }
  }

  static Future<void> deleteHerb(String herbId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/herbs/$herbId');

    final response = await http.delete(url);
    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Failed to delete herb');
    }
  }

  static Future<Map<String, dynamic>> rateHerb({
    required String herbId,
    required String userId,
    required int rating,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/herbs/$herbId/rate');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'rating': rating,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data['herb'];
    } else {
      throw Exception(data['message'] ?? 'Failed to rate herb');
    }
  }
}