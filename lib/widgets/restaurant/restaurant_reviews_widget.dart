import 'package:flutter/cupertino.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/review.dart';
import '../../core/app_settings.dart';
import '../../controllers/restaurant_controller.dart';
import '../../pages/reviews_list_page.dart';
import '../../pages/review_input_page.dart';

class RestaurantReviewsWidget extends StatelessWidget {
  final String restaurantId;
  final String restaurantName;
  final RestaurantController controller;

  const RestaurantReviewsWidget({
    super.key,
    required this.restaurantId,
    required this.restaurantName,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSettings.defaultPadding),
      padding: const EdgeInsets.all(AppSettings.defaultPadding),
      decoration: BoxDecoration(
        color: AppSettings.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(AppSettings.defaultBorderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Reviews',
                style: CupertinoTheme.of(
                  context,
                ).textTheme.navTitleTextStyle.copyWith(fontSize: 18),
              ),
              const Spacer(),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Text('View All'),
                onPressed: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (context) => ReviewsListPage(
                        restaurantId: restaurantId,
                        restaurantName: restaurantName,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (controller.isLoadingReviews)
            const Center(child: CupertinoActivityIndicator())
          else if (controller.reviews.isEmpty)
            const Text(
              'No reviews yet. Be the first to review this restaurant!',
              style: TextStyle(
                color: CupertinoColors.systemGrey,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            Column(
              children: controller.reviews
                  .map((review) => _buildReviewCard(context, review))
                  .toList(),
            ),

          const SizedBox(height: 16),
          CupertinoButton.filled(
            onPressed: () {
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (context) => ReviewInputPage(
                    restaurantId: restaurantId,
                    restaurantName: restaurantName,
                  ),
                ),
              );
            },
            child: const Text('Write Review'),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(BuildContext context, Review review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppSettings.getChipColor(context),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppSettings.getShadowColor(context),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(review.userAvatar, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: CupertinoTheme.of(context).textTheme.textStyle
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      timeago.format(review.createdAt),
                      style: CupertinoTheme.of(context).textTheme.textStyle
                          .copyWith(
                            color: CupertinoColors.systemGrey,
                            fontSize: 12,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(review.rating, (index) {
              return const Text('⭐', style: TextStyle(fontSize: 14));
            }),
          ),
          const SizedBox(height: 8),
          Text(
            review.comment,
            style: CupertinoTheme.of(context).textTheme.textStyle,
          ),
        ],
      ),
    );
  }
}
