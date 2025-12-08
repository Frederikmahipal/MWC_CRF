import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/restaurant.dart';
import '../states/chat_state.dart';
import '../services/openrouter_service.dart';
import '../services/restaurant_filter_service.dart';
import '../services/ml_food_search_service.dart';

class ChatController extends ChangeNotifier {
  final OpenRouterService _openRouterService = OpenRouterService();
  final RestaurantFilterService _filterService = RestaurantFilterService();
  final MLFoodSearchService _mlFoodSearchService = MLFoodSearchService();

  ChatState _state = const ChatState();
  ChatState get state => _state;

  List<ChatMessage> get messages => _state.messages;
  bool get isLoading => _state.isLoading;
  String? get error => _state.error;
  bool get isLoadingRestaurants => _state.isLoadingRestaurants;

  ChatController() {
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    _addWelcomeMessage();
 //   _updateState(_state.copyWith(isLoadingRestaurants: false));
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
      // Pre-filter restaurants based on user query
      final filteredRestaurants = await _filterService
          .getFilteredRestaurantsForAI(messageText);

      if (filteredRestaurants.isEmpty) {
        final errorMessage = ChatMessage(
          text:
              "I couldn't find any restaurants matching your request. Please try a different search.",
          isUser: false,
          timestamp: DateTime.now(),
        );

        _updateState(
          _state.copyWith(
            messages: [..._state.messages, errorMessage],
            isLoading: false,
            error: null,
          ),
        );
        return;
      }

      // Send filtered restaurants to AI
      final aiResponse = await _openRouterService.getRestaurantRecommendations(
        messageText,
        filteredRestaurants,
      );

      final recommendedRestaurants = _extractRestaurantRecommendations(
        aiResponse,
        filteredRestaurants,
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
      print('AI Error: $e');
      final errorMessage = ChatMessage(
        isUser: false,
        timestamp: DateTime.now(),
        text: "Sorry, I couldn't process your request. Please try again.",
      );
      _updateState(
        _state.copyWith(
          messages: [..._state.messages, errorMessage],
          isLoading: false,
          error: null,
        ),
      );
    }
  }

  // Extract restaurant recommendations from AI response
  List<Restaurant> _extractRestaurantRecommendations(
    String aiResponse,
    List<Restaurant> availableRestaurants,
  ) {
    final List<Restaurant> recommendations = [];
    final aiResponseLower = aiResponse.toLowerCase();
    final sortedRestaurants = availableRestaurants;
    // Create a map for faster lookup
    final restaurantMap = {
      for (var r in sortedRestaurants) r.name.toLowerCase(): r,
    };

    // Exact name matches
    for (final entry in restaurantMap.entries) {
      if (aiResponseLower.contains(entry.key)) {
        recommendations.add(entry.value);
      }
    }

    if (recommendations.isNotEmpty) {
      // Remove duplicates and limit to 3
      final uniqueRecommendations = recommendations
          .fold<Map<String, Restaurant>>({}, (map, restaurant) {
            map[restaurant.id] = restaurant;
            return map;
          })
          .values
          .toList();

      return uniqueRecommendations.take(3).toList();
    }

    // Partial word matches
    for (final restaurant in sortedRestaurants) {
      final restaurantName = restaurant.name.toLowerCase();
      final words = restaurantName.split(' ');

      for (final word in words) {
        if (word.length > 3 && aiResponseLower.contains(word)) {
          recommendations.add(restaurant);
          break;
        }
      }
    }

    if (recommendations.isNotEmpty) {
      // Remove duplicates and limit to 3
      final uniqueRecommendations = recommendations
          .fold<Map<String, Restaurant>>({}, (map, restaurant) {
            map[restaurant.id] = restaurant;
            return map;
          })
          .values
          .toList();

      return uniqueRecommendations.take(3).toList();
    }

    // If no matches found, return top rated restaurants as fallback
    // Shuffle slightly to add variety if we have enough options
    if (sortedRestaurants.length > 5) {
      final topRated = sortedRestaurants.take(10).toList();
      topRated.shuffle();
      return topRated.take(3).toList();
    }
    return sortedRestaurants.take(3).toList();
  }

  void clearError() {
    _updateState(_state.copyWith(error: null));
  }

  void reset() {
    _state = const ChatState();
    _initializeChat();
  }

  Future<void> sendImageMessage(File imageFile) async {
    // Show user message with image indicator
    final userMessage = ChatMessage(
      text: '📷 [Photo]',
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
      // Use ML food search service to classify and map to cuisine
      final searchResult = await _mlFoodSearchService.searchByFoodImage(
        imageFile,
      );

      if (!searchResult.success || searchResult.detectedFood == null) {
        final errorMessage = ChatMessage(
          text:
              searchResult.error ??
              "I couldn't identify the food in this image. Please try another photo or describe what you're looking for.",
          isUser: false,
          timestamp: DateTime.now(),
        );

        _updateState(
          _state.copyWith(
            messages: [..._state.messages, errorMessage],
            isLoading: false,
            error: null,
          ),
        );
        return;
      }

      final detectedFood = searchResult.detectedFood!;
      final cuisineType = searchResult.cuisineType ?? detectedFood;

      // Use restaurants from search result, or filter if needed
      List<Restaurant> filteredRestaurants = searchResult.restaurants;

      // If no restaurants found from cuisine search, try filtering by query
      if (filteredRestaurants.isEmpty) {
        final query = "I want to find restaurants that serve $detectedFood";
        filteredRestaurants = await _filterService.getFilteredRestaurantsForAI(
          query,
        );
      }

      if (filteredRestaurants.isEmpty) {
        final cuisineText = cuisineType != detectedFood
            ? " ($cuisineType cuisine)"
            : "";
        final errorMessage = ChatMessage(
          text:
              "I detected $detectedFood$cuisineText in your photo, but couldn't find any restaurants serving that. Please try a different photo.",
          isUser: false,
          timestamp: DateTime.now(),
        );

        _updateState(
          _state.copyWith(
            messages: [..._state.messages, errorMessage],
            isLoading: false,
            error: null,
          ),
        );
        return;
      }

      // Send to AI with context about the detected food and cuisine
      final cuisineText = cuisineType != detectedFood
          ? " ($cuisineType cuisine)"
          : "";
      final aiResponse = await _openRouterService.getRestaurantRecommendations(
        "I'm looking for restaurants that serve $detectedFood$cuisineText",
        filteredRestaurants,
      );

      final recommendedRestaurants = _extractRestaurantRecommendations(
        aiResponse,
        filteredRestaurants,
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
      print('Image processing error: $e');
      final errorMessage = ChatMessage(
        text: "Sorry, I couldn't process the image. Please try again.",
        isUser: false,
        timestamp: DateTime.now(),
      );

      _updateState(
        _state.copyWith(
          messages: [..._state.messages, errorMessage],
          isLoading: false,
          error: null,
        ),
      );
    }
  }

  void _updateState(ChatState newState) {
    _state = newState;
    notifyListeners();
  }
}
