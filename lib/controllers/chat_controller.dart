import 'package:flutter/foundation.dart';
import '../models/restaurant.dart';
import '../states/chat_state.dart';
import '../services/openrouter_service.dart';
import '../services/restaurant_service.dart';
import '../services/review_service.dart';

class ChatController extends ChangeNotifier {
  final OpenRouterService _aiService = OpenRouterService();
  final RestaurantService _restaurantService = RestaurantService();

  ChatState _state = const ChatState();
  ChatState get state => _state;

  List<ChatMessage> get messages => _state.messages;
  bool get isLoading => _state.isLoading;
  String? get error => _state.error;
  List<Restaurant> get restaurants => _state.restaurants;
  bool get isLoadingRestaurants => _state.isLoadingRestaurants;

  ChatController() {
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    _addWelcomeMessage();
    await _loadRestaurants();
  }

  Future<void> _loadRestaurants() async {
    _updateState(_state.copyWith(isLoadingRestaurants: true, error: null));

    try {
      final restaurants = await _restaurantService.getAllRestaurants();

      _updateState(
        _state.copyWith(
          restaurants: restaurants,
          isLoadingRestaurants: false,
          error: null,
        ),
      );
    } catch (e) {
      _updateState(
        _state.copyWith(
          isLoadingRestaurants: false,
          error: 'Failed to load restaurants: $e',
        ),
      );
    }
  }

  void _addWelcomeMessage() {
    final welcomeMessage = ChatMessage(
      text:
          "Hi! I'm your AI restaurant assistant. I can help you find the perfect restaurants in Copenhagen. What are you looking for?",
      isUser: false,
      timestamp: DateTime.now(),
    );

    _updateState(
      _state.copyWith(messages: [..._state.messages, welcomeMessage]),
    );
  }

  Future<void> sendMessage(String messageText) async {
    if (messageText.trim().isEmpty) return;

    if (_state.restaurants.isEmpty) {
      return;
    }

    final userMessage = ChatMessage(
      text: messageText.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );

    _updateState(
      _state.copyWith(
        messages: [..._state.messages, userMessage],
        isLoading: true,
        error: null,
      ),
    );

    try {
      final aiResponse = await _aiService.getRestaurantRecommendations(
        messageText,
        _state.restaurants,
      );

      final recommendedRestaurants = await _extractRestaurantRecommendations(
        aiResponse,
      );

      final aiMessage = ChatMessage(
        text: aiResponse,
        isUser: false,
        timestamp: DateTime.now(),
        recommendedRestaurants: recommendedRestaurants,
      );

      _updateState(
        _state.copyWith(
          messages: [..._state.messages, aiMessage],
          isLoading: false,
          error: null,
        ),
      );
    } catch (e) {
      final errorMessage = ChatMessage(
        text: "Sorry, I encountered an error. Please try again.",
        isUser: false,
        timestamp: DateTime.now(),
      );

      _updateState(
        _state.copyWith(
          messages: [..._state.messages, errorMessage],
          isLoading: false,
          error: e.toString(),
        ),
      );
    }
  }

  Future<List<Restaurant>> _extractRestaurantRecommendations(
    String aiResponse,
  ) async {
    final List<Restaurant> recommendations = [];
    final aiResponseLower = aiResponse.toLowerCase();

    // exact name matches
    for (final restaurant in _state.restaurants) {
      final restaurantName = restaurant.name.toLowerCase();
      if (aiResponseLower.contains(restaurantName)) {
        recommendations.add(restaurant);
      }
    }

    if (recommendations.isNotEmpty) {
      final uniqueRecommendations = recommendations
          .fold<Map<String, Restaurant>>({}, (map, restaurant) {
            map[restaurant.id] = restaurant;
            return map;
          })
          .values
          .toList();

      return await _calculateRatingsForRestaurants(uniqueRecommendations);
    }

    // partial word matches
    for (final restaurant in _state.restaurants) {
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
      // Remove duplicates based on restaurant ID
      final uniqueRecommendations = recommendations
          .fold<Map<String, Restaurant>>({}, (map, restaurant) {
            map[restaurant.id] = restaurant;
            return map;
          })
          .values
          .toList();

      return await _calculateRatingsForRestaurants(uniqueRecommendations);
    }

    // cuisine-based matching
    final cuisineType = _extractCuisineType(aiResponseLower);
    if (cuisineType.isNotEmpty) {
      for (final restaurant in _state.restaurants) {
        final restaurantCuisines = restaurant.cuisines.join(' ').toLowerCase();
        if (restaurantCuisines.contains(cuisineType)) {
          recommendations.add(restaurant);
        }
      }
    }

    if (recommendations.isNotEmpty) {
      final uniqueRecommendations = recommendations
          .fold<Map<String, Restaurant>>({}, (map, restaurant) {
            map[restaurant.id] = restaurant;
            return map;
          })
          .values
          .toList();

      return await _calculateRatingsForRestaurants(uniqueRecommendations);
    }

    return [];
  }

  String _extractCuisineType(String aiResponseLower) {
    final cuisineMap = {
      'indian': 'indian',
      'italian': 'italian',
      'pizza': 'italian',
      'chinese': 'chinese',
      'asian': 'chinese',
      'japanese': 'japanese',
      'sushi': 'japanese',
      'mexican': 'mexican',
      'french': 'french',
      'steak': 'steak',
      'meat': 'steak',
      'burger': 'burger',
      'coffee': 'coffee',
      'cafe': 'coffee',
    };

    for (final entry in cuisineMap.entries) {
      if (aiResponseLower.contains(entry.key)) {
        return entry.value;
      }
    }

    return '';
  }

  Future<List<Restaurant>> _calculateRatingsForRestaurants(
    List<Restaurant> restaurants,
  ) async {
    final List<Restaurant> restaurantsWithRatings = [];

    for (final restaurant in restaurants) {
      try {
        // Calculate real rating from reviews
        final ratingSummary = await ReviewService.getRestaurantRatingSummary(
          restaurant.id,
        );

        final restaurantWithRating = Restaurant(
          id: restaurant.id,
          name: restaurant.name,
          cuisines: restaurant.cuisines,
          location: restaurant.location,
          neighborhood: restaurant.neighborhood,
          phone: restaurant.phone,
          website: restaurant.website,
          openingHours: restaurant.openingHours,
          features: restaurant.features,
          averageRating: ratingSummary['averageRating'] ?? 0.0,
          totalReviews: ratingSummary['totalReviews'] ?? 0,
        );

        restaurantsWithRatings.add(restaurantWithRating);
      } catch (e) {
        restaurantsWithRatings.add(restaurant);
      }
    }

    return restaurantsWithRatings;
  }

  void clearError() {
    _updateState(_state.copyWith(error: null));
  }

  void reset() {
    _state = const ChatState();
    _initializeChat();
  }

  void _updateState(ChatState newState) {
    _state = newState;
    notifyListeners();
  }
}
