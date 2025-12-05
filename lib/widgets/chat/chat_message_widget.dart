import 'package:flutter/cupertino.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../core/app_settings.dart';
import '../../states/chat_state.dart';
import '../../models/restaurant.dart';
import 'restaurant_recommendation_card.dart';

class ChatMessageWidget extends StatelessWidget {
  final ChatMessage message;
  final ValueChanged<Restaurant>? onRestaurantTap;

  const ChatMessageWidget({
    super.key,
    required this.message,
    this.onRestaurantTap,
  });

  @override
  Widget build(BuildContext context) {
    if (message.isUser) {
      return _buildUserMessage(context);
    } else {
      return _buildAIMessage(context);
    }
  }

  Widget _buildUserMessage(BuildContext context) {
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
  }

  Widget _buildAIMessage(BuildContext context) {
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
              Expanded(
                child: _buildAIResponseWithCards(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAIResponseWithCards(BuildContext context) {
    if (message.recommendedRestaurants == null ||
        message.recommendedRestaurants!.isEmpty) {
      return _buildTextBubble(context, message.text);
    }

    return _buildResponseWithInlineCards(context);
  }

  Widget _buildResponseWithInlineCards(BuildContext context) {
    final restaurants = message.recommendedRestaurants!;
    final responseText = message.text;

    final List<Widget> widgets = [];

    widgets.add(_buildTextBubble(context, responseText));
    widgets.add(const SizedBox(height: 12));

    for (final restaurant in restaurants) {
      widgets.add(
        RestaurantRecommendationCard(
          restaurant: restaurant,
          onTap: (restaurant) => onRestaurantTap?.call(restaurant),
        ),
      );
      widgets.add(const SizedBox(height: 8));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _buildTextBubble(BuildContext context, String text) {
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
}
