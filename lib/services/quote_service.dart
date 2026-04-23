import 'dart:convert';
import 'package:http/http.dart' as http;

class QuoteService {
  static const String _baseUrl = 'https://api.quotable.io';

  static Future<Map<String, dynamic>?> fetchRandomQuote() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/random'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error fetching quote: $e');
    }
    return null;
  }
}
