import 'dart:convert';
import 'package:http/http.dart' as http;

class FavoriteService {
  static const String baseUrl = 'http://localhost:5000/api/favorites';

  static Future<void> addFavorite(String userId, String herbId) async {
    await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'herbId': herbId}),
    );
  }

  static Future<void> removeFavorite(String userId, String herbId) async {
    await http.delete(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'herbId': herbId}),
    );
  }

  static Future<List<dynamic>> getFavorites(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/$userId'));

    final data = jsonDecode(response.body);

    return data['favorites'];
  }
}
