import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/restaurant.dart';

class OpenRouterService {
  static String get apiKey => dotenv.env['OPENROUTER_API_KEY'] ?? '';
  static String get apiUrl =>
      dotenv.env['OPENROUTER_API_URL'] ??
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
          'model': 'deepseek/deepseek-r1-distill-llama-70b:free',
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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

      
        final aiResponse =
            data['choices'][0]['message']['content'] ?? 'No response generated';

        final isTruncated =
            aiResponse.endsWith('"') ||
            aiResponse.endsWith('...') ||
            aiResponse.length < 100;

        if (isTruncated) {
          print('⚠️ WARNING: Response appears to be truncated!');
          print(
            '⚠️ Response ends with: "${aiResponse.substring(aiResponse.length - 20)}"',
          );
        }

        return aiResponse;
      } else {
        return 'Sorry, I couldn\'t process your request. Please try again.';
      }
    } catch (e) {
      print('OpenRouter error: $e');
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
