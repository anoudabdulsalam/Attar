import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class OrderService {
  static Future<Map<String, dynamic>> createOrder({
    required String buyerId,
    required String buyerName,
    required String buyerRole,
    required String storeOwnerId,
    required String storeName,
    required List<Map<String, dynamic>> items,
    required double totalPrice,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/orders');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'buyerId': buyerId,
        'buyerName': buyerName,
        'buyerRole': buyerRole,
        'storeOwnerId': storeOwnerId,
        'storeName': storeName,
        'items': items,
        'totalPrice': totalPrice,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return data['order'];
    } else {
      throw Exception(data['message'] ?? 'Failed to create order');
    }
  }

  static Future<List<dynamic>> getOrdersByBuyer(String buyerId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/orders/buyer/$buyerId');

    final response = await http.get(url);
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data['orders'] ?? [];
    } else {
      throw Exception(data['message'] ?? 'Failed to fetch buyer orders');
    }
  }

static Future<List<dynamic>> getAllOrdersByStoreOwnerForReport(
  String storeOwnerId,
) async {
  final url = Uri.parse(
    '${ApiConfig.baseUrl}/api/orders/store/$storeOwnerId/all',
  );

  final response = await http.get(url);
  final data = jsonDecode(response.body);

  if (response.statusCode == 200) {
    return data['orders'] ?? [];
  } else {
    throw Exception(data['message'] ?? 'Failed to fetch report orders');
  }
}
  static Future<List<dynamic>> getOrdersByStoreOwner(String storeOwnerId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/orders/store/$storeOwnerId');

    final response = await http.get(url);
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data['orders'] ?? [];
    } else {
      throw Exception(data['message'] ?? 'Failed to fetch store orders');
    }
  }

  static Future<Map<String, dynamic>> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/orders/$orderId/status');

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': status}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data['order'];
    } else {
      throw Exception(data['message'] ?? 'Failed to update order');
    }
  }
}