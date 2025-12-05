import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/restaurant.dart';

class OpenRouterService {
  static String get apiKey => dotenv.env['OPENROUTER_API_KEY'] ?? '';
  static String get apiUrl => 'https://openrouter.ai/api/v1/chat/completions';

  Future<String> getRecommendations(String prompt) async {
    if (apiKey.isEmpty) {
      throw Exception('OpenRouter API key not configured');
    }

    try {
      final response = await http
          .post(
            Uri.parse(apiUrl),
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': 'tngtech/deepseek-r1t2-chimera:free',
              'messages': [
                {
                  'role': 'system',
                  'content':
                      'You are a Copenhagen restaurant expert. Be concise and helpful.',
                },
                {'role': 'user', 'content': prompt},
              ],
              'max_tokens': 500,
              'temperature': 0.7,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['choices'] != null && data['choices'].isNotEmpty) {
          final content = data['choices'][0]['message']['content'];
          if (content != null && content.toString().isNotEmpty) {
            return content.toString();
          }
        }
        throw Exception('No content in response');
      } else {
        final errorBody = response.body;
        throw Exception(
          'API error ${response.statusCode}: ${errorBody.length > 100 ? errorBody.substring(0, 100) : errorBody}',
        );
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Request timed out. Please try again.');
      }
      rethrow;
    }
  }

  Future<String> getRestaurantRecommendations(
    String userQuery,
    List<Restaurant> restaurants,
  ) async {
    // Limit to top 20 restaurants to reduce prompt size and speed up response
    final limitedRestaurants = restaurants.take(20).toList();

    final restaurantData = limitedRestaurants
        .map(
          (r) =>
              "${r.name}|${r.cuisines.join(',')}|${r.averageRating.toStringAsFixed(1)}|${r.totalReviews}|${r.neighborhood ?? ''}",
        )
        .join('\n');

    final prompt =
        """Recommend restaurants from this list (format: Name|Cuisine|Rating|Reviews|Neighborhood):

$restaurantData

User: "$userQuery"

Rules: Only recommend from the list above. Use exact names. Keep response concise (2-3 restaurants max).""";

    return await getRecommendations(prompt);
  }
}
