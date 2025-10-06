import '../models/restaurant.dart';

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

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;
  final List<Restaurant> restaurants;
  final bool isLoadingRestaurants;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.restaurants = const [],
    this.isLoadingRestaurants = false,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
    List<Restaurant>? restaurants,
    bool? isLoadingRestaurants,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      restaurants: restaurants ?? this.restaurants,
      isLoadingRestaurants: isLoadingRestaurants ?? this.isLoadingRestaurants,
    );
  }

  @override
  String toString() {
    return 'ChatState('
        'messages: ${messages.length}, '
        'isLoading: $isLoading, '
        'error: $error, '
        'restaurants: ${restaurants.length}, '
        'isLoadingRestaurants: $isLoadingRestaurants'
        ')';
  }
}
