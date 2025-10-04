import 'package:flutter/cupertino.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../core/app_settings.dart';
import '../services/openrouter_service.dart';
import '../services/restaurant_service.dart';
import '../models/restaurant.dart';
import 'restaurants/restaurant_main_page.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<Restaurant>? recommendedRestaurants;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.recommendedRestaurants,
  });
}

class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final OpenRouterService _aiService = OpenRouterService();
  final RestaurantService _restaurantService = RestaurantService();
  List<Restaurant> _restaurants = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadRestaurants() async {
    try {
      final restaurants = await _restaurantService
          .getAllRestaurantsWithRatings();
      setState(() {
        _restaurants = restaurants;
      });
    } catch (e) {
      print('Error loading restaurants: $e');
    }
  }

  void _addWelcomeMessage() {
    setState(() {
      _messages.add(
        ChatMessage(
          text:
              "Hi! I'm your AI restaurant assistant. I can help you find the perfect restaurants in Copenhagen. What are you looking for?",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(text: message, isUser: true, timestamp: DateTime.now()),
      );
      _isLoading = true;
    });

    _messageController.clear();

    try {
      final response = await _aiService.getRestaurantRecommendations(
        message,
        _restaurants,
      );

      final recommendedRestaurants = _extractRestaurantRecommendations(
        response,
      );

      setState(() {
        _messages.add(
          ChatMessage(
            text: response,
            isUser: false,
            timestamp: DateTime.now(),
            recommendedRestaurants: recommendedRestaurants,
          ),
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(
            text: "Sorry, I encountered an error. Please try again.",
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        _isLoading = false;
      });
    }
  }

  List<Restaurant> _extractRestaurantRecommendations(String aiResponse) {
    final List<Restaurant> recommendations = [];
    final aiResponseLower = aiResponse.toLowerCase();

    for (final restaurant in _restaurants) {
      final restaurantName = restaurant.name.toLowerCase();
      if (aiResponseLower.contains(restaurantName)) {
        recommendations.add(restaurant);
      }
    }

    if (recommendations.isNotEmpty) {
      final validRecommendations = recommendations
          .where((r) => _restaurants.any((restaurant) => restaurant.id == r.id))
          .toList();
      return validRecommendations.take(5).toList();
    }

    for (final restaurant in _restaurants) {
      final restaurantName = restaurant.name.toLowerCase();
      final words = restaurantName.split(' ');

      for (final word in words) {
        if (word.length > 2 && aiResponseLower.contains(word)) {
          recommendations.add(restaurant);
          break;
        }
      }
    }

    if (recommendations.isNotEmpty) {
      return recommendations.take(5).toList();
    }

    String cuisineType = '';
    if (aiResponseLower.contains('indian'))
      cuisineType = 'indian';
    else if (aiResponseLower.contains('italian') ||
        aiResponseLower.contains('pizza'))
      cuisineType = 'italian';
    else if (aiResponseLower.contains('chinese') ||
        aiResponseLower.contains('asian'))
      cuisineType = 'chinese';
    else if (aiResponseLower.contains('japanese') ||
        aiResponseLower.contains('sushi'))
      cuisineType = 'japanese';
    else if (aiResponseLower.contains('mexican'))
      cuisineType = 'mexican';
    else if (aiResponseLower.contains('french'))
      cuisineType = 'french';
    else if (aiResponseLower.contains('steak') ||
        aiResponseLower.contains('meat'))
      cuisineType = 'steak';
    else if (aiResponseLower.contains('burger'))
      cuisineType = 'burger';
    else if (aiResponseLower.contains('coffee') ||
        aiResponseLower.contains('cafe'))
      cuisineType = 'coffee';


    // Find restaurants by cuisine type
    if (cuisineType.isNotEmpty) {
      for (final restaurant in _restaurants) {
        final restaurantCuisines = restaurant.cuisines.join(' ').toLowerCase();
        if (restaurantCuisines.contains(cuisineType)) {
          print(
            '✅ Cuisine match: ${restaurant.name} (${restaurant.cuisines.join(', ')})',
          );
          recommendations.add(restaurant);
        }
      }
    }

    if (recommendations.isNotEmpty) {
      return recommendations.take(5).toList();
    }

    final sortedRestaurants = List<Restaurant>.from(_restaurants)
      ..sort((a, b) => b.averageRating.compareTo(a.averageRating));

    final topRestaurants = sortedRestaurants.take(5).toList();
    return topRestaurants;
  }

  void _navigateToRestaurant(Restaurant restaurant) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => RestaurantMainPage(restaurant: restaurant),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('AI Restaurant Finder'),
        backgroundColor: AppSettings.getBackgroundColor(context),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isLoading) {
                    return _buildLoadingMessage();
                  }
                  return _buildMessage(_messages[index]);
                },
              ),
            ),
            _buildInputField(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    if (message.isUser) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppSettings.getPrimaryColor(context),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  message.text,
                  style: const TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppSettings.getSecondaryTextColor(context),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                CupertinoIcons.person_fill,
                color: CupertinoColors.white,
                size: 16,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppSettings.getPrimaryColor(context),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    CupertinoIcons.chat_bubble_2,
                    color: CupertinoColors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(child: _buildAIResponseWithCards(message)),
              ],
            ),
          ],
        ),
      );
    }
  }

  Widget _buildAIResponseWithCards(ChatMessage message) {
    if (message.recommendedRestaurants == null ||
        message.recommendedRestaurants!.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppSettings.getSurfaceColor(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppSettings.getBorderColor(context),
            width: 1,
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: AppSettings.getTextColor(context),
            fontSize: 16,
          ),
        ),
      );
    }

    return _buildResponseWithInlineCards(message);
  }

  Widget _buildResponseWithInlineCards(ChatMessage message) {
    final restaurants = message.recommendedRestaurants!;
    final responseText = message.text;

    final List<Widget> widgets = [];

    widgets.add(_buildTextBubble(responseText));
    widgets.add(const SizedBox(height: 12));

    for (final restaurant in restaurants) {
      widgets.add(_buildRestaurantCard(restaurant));
      widgets.add(const SizedBox(height: 8));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _buildTextBubble(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppSettings.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppSettings.getBorderColor(context),
          width: 1,
        ),
      ),
      child: MarkdownBody(
        data: text,
        styleSheet: MarkdownStyleSheet(
          p: TextStyle(color: AppSettings.getTextColor(context), fontSize: 16),
          strong: TextStyle(
            color: AppSettings.getTextColor(context),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          em: TextStyle(
            color: AppSettings.getTextColor(context),
            fontStyle: FontStyle.italic,
            fontSize: 16,
          ),
          listBullet: TextStyle(
            color: AppSettings.getTextColor(context),
            fontSize: 16,
          ),
          h1: TextStyle(
            color: AppSettings.getTextColor(context),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          h2: TextStyle(
            color: AppSettings.getTextColor(context),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          h3: TextStyle(
            color: AppSettings.getTextColor(context),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildRestaurantCard(Restaurant restaurant) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => _navigateToRestaurant(restaurant),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppSettings.getSurfaceColor(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppSettings.getBorderColor(context),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppSettings.getPrimaryColor(context).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    _getRestaurantEmoji(restaurant),
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant.name,
                      style: TextStyle(
                        color: AppSettings.getTextColor(context),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      restaurant.cuisines.join(', '),
                      style: TextStyle(
                        color: AppSettings.getSecondaryTextColor(context),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.star_fill,
                          color: CupertinoColors.systemYellow,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${restaurant.averageRating.toStringAsFixed(1)}/5 (${restaurant.totalReviews} reviews)',
                          style: TextStyle(
                            color: AppSettings.getSecondaryTextColor(context),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
                Icon(
                CupertinoIcons.chevron_right,
                color: AppSettings.getSecondaryTextColor(context),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getRestaurantEmoji(Restaurant restaurant) {
    final cuisines = restaurant.cuisines.join(' ').toLowerCase();

    if (cuisines.contains('italian') || cuisines.contains('pizza')) return '🍝';
    if (cuisines.contains('chinese') || cuisines.contains('asian')) return '🥢';
    if (cuisines.contains('japanese') || cuisines.contains('sushi'))
      return '🍣';
    if (cuisines.contains('mexican')) return '🌮';
    if (cuisines.contains('indian')) return '🍛';
    if (cuisines.contains('french')) return '🥐';
    if (cuisines.contains('steak') || cuisines.contains('meat')) return '🥩';
    if (cuisines.contains('seafood') || cuisines.contains('fish')) return '🐟';
    if (cuisines.contains('coffee') || cuisines.contains('cafe')) return '☕';
    if (cuisines.contains('burger') || cuisines.contains('fast')) return '🍔';

    return '🍽️'; 
  }

  Widget _buildLoadingMessage() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppSettings.getPrimaryColor(context),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              CupertinoIcons.chat_bubble_2,
              color: CupertinoColors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppSettings.getSurfaceColor(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppSettings.getBorderColor(context),
                width: 1,
              ),
            ),
            child: const CupertinoActivityIndicator(),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppSettings.getSurfaceColor(context),
        border: Border(
          top: BorderSide(color: AppSettings.getBorderColor(context), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: CupertinoTextField(
              controller: _messageController,
              placeholder: 'Ask about restaurants...',
              decoration: BoxDecoration(
                color: AppSettings.getBackgroundColor(context),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppSettings.getBorderColor(context),
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          CupertinoButton.filled(
            onPressed: _isLoading ? null : _sendMessage,
            child: const Icon(CupertinoIcons.paperplane_fill),
          ),
        ],
      ),
    );
  }
}
