import 'dart:convert';
import 'package:http/http.dart' as http;

class QuoteService {
  static const String _baseUrl = 'https://api.quotable.io';
  static const Duration _timeout = Duration(seconds: 5);

  static Future<Map<String, dynamic>?> fetchRandomQuote() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/random'))
          .timeout(
            _timeout,
            onTimeout: () {
              print('Quote API timeout');
              throw TimeoutException('Failed to fetch quote');
            },
          );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error fetching quote: $e');
    }
    // Return null silently - don't block the UI
    return null;
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => message;
}
