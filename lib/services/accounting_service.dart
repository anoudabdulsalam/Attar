import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class AccountingService {
  static Future<Map<String, dynamic>> getAccountingByStoreOwner(
    String storeOwnerId,
  ) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/api/accounting/store/$storeOwnerId',
    );

    final response = await http.get(url);
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'فشل تحميل بيانات المحاسبة');
    }
  }
}