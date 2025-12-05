import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/restaurant.dart';

class OpenRouterService {
  static String get apiKey => dotenv.env['OPENROUTER_API_KEY'] ?? '';
  static String get apiUrl =>
      'https://openrouter.ai/api/v1/chat/completions';

  Future<String> getRecommendations(String prompt) async {

    try {
      final response = await http.post(
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
                  'You are a Copenhagen restaurant expert. Help users find the perfect restaurants based on their preferences. Be helpful, specific, and provide reasoning for your recommendations.',
            },
            {'role': 'user', 'content': prompt},
          ],
          'max_tokens': 2000,
          'temperature': 0.7,
        }),
      );

      print('📡 OpenRouter API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check if response has the expected structure
        if (data['choices'] == null || data['choices'].isEmpty) {
          print('❌ ERROR: Invalid response structure - no choices found');
          print('Response body: ${response.body}');
          return 'Sorry, I received an unexpected response from the AI service. Please try again.';
        }

        final aiResponse =
            data['choices'][0]['message']['content'] ?? 'No response generated';

        if (aiResponse == 'No response generated') {
          print('❌ ERROR: No content in AI response');
          print('Response body: ${response.body}');
          return 'Sorry, the AI service did not generate a response. Please try again.';
        }
        return aiResponse;
      } else {
        // Log the actual error response
        print('ERROR: API returned status ${response.statusCode}');
        print('Response body: ${response.body}');

        try {
          final errorData = jsonDecode(response.body);
          final errorMessage =
              errorData['error']?['message'] ??
              errorData['error']?['type'] ??
              'Unknown error';
          final errorCode = errorData['error']?['code'] ?? '';
          print('Error message: $errorMessage');
          print('Error code: $errorCode');

          // Check for model availability errors
          if (errorCode == 'model_not_available' ||
              errorMessage.toLowerCase().contains('model') &&
                  errorMessage.toLowerCase().contains('not available')) {
            return 'Sorry, the AI model is currently unavailable. Please try again later or contact support.';
          }

          if (response.statusCode == 401) {
            return 'Sorry, the API key is invalid. Please check your configuration.';
          } else if (response.statusCode == 429) {
            return 'Sorry, too many requests. Please wait a moment and try again.';
          } else if (response.statusCode >= 500) {
            return 'Sorry, the AI service is temporarily unavailable. Please try again later.';
          }
        } catch (_) {
        }

        return 'Sorry, I couldn\'t process your request (Error ${response.statusCode}). Please try again.';
      }
    } catch (e) {
      return 'Sorry, I couldn\'t connect to the AI service. Please check your internet connection.';
    }
  }

  Future<String> getRestaurantRecommendations(
    String userQuery,
    List<Restaurant> restaurants,
  ) async {
    final restaurantData = restaurants
        .map(
          (r) =>
              "${r.name} - ${r.cuisines.join(', ')} - Rating: ${r.averageRating.toStringAsFixed(1)}/5 (${r.totalReviews} reviews) - ${r.neighborhood} - ${r.features.hasOutdoorSeating ? 'Outdoor seating' : ''} - ${r.features.isWheelchairAccessible ? 'Wheelchair accessible' : ''}",
        )
        .join('\n');

    final prompt =
        """
You are a Copenhagen restaurant assistant. You have access to ONLY these restaurants:

$restaurantData



CRITICAL RULES - FOLLOW THESE EXACTLY:
1. You MUST ONLY recommend restaurants from the list above
2. You MUST NOT mention any restaurants not in this list
3. You MUST NOT make up, invent, or create any restaurant names
4. You MUST use the EXACT restaurant names as they appear in the data
5. If a restaurant is not in the list above, DO NOT mention it
6. Double-check every restaurant name you mention against the list above

From the restaurants listed above, recommend the best ones that match the user's request. Consider both the user's preferences AND the restaurant ratings when making your recommendations. Explain why each restaurant is a good choice, mentioning their ratings when relevant.

User Request: "$userQuery"
REMEMBER: ONLY use restaurants from the provided list. Do not invent any names.
""";

    return await getRecommendations(prompt);
  }
}
