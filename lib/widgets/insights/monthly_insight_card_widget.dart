import 'package:flutter/cupertino.dart';
import '../../../models/insights.dart';
import '../../../core/app_settings.dart';
import 'overall_stats_widget.dart';
import 'most_reviewed_widget.dart';
import 'highest_rated_widget.dart';
import 'most_visited_widget.dart';
import 'most_liked_widget.dart';

class MonthlyInsightCardWidget extends StatelessWidget {
  final MonthlyInsights insight;
  final Function(String restaurantId) onRestaurantTap;

  const MonthlyInsightCardWidget({
    super.key,
    required this.insight,
    required this.onRestaurantTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppSettings.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMonthHeader(context),
          const SizedBox(height: 16),

          OverallStatsWidget(insight: insight),
          const SizedBox(height: 16),

          if (insight.highestRatedRestaurants.isNotEmpty)
            HighestRatedWidget(
              restaurants: insight.highestRatedRestaurants.take(3).toList(),
              onRestaurantTap: onRestaurantTap,
            ),
          const SizedBox(height: 12),

          if (insight.mostReviewedRestaurants.isNotEmpty)
            MostReviewedWidget(
              restaurant: insight.mostReviewedRestaurants.first,
              onTap: () => onRestaurantTap(
                insight.mostReviewedRestaurants.first.restaurantId,
              ),
            ),
          const SizedBox(height: 12),

          // Most visited restaurants
          if (insight.mostVisitedRestaurants.isNotEmpty)
            MostVisitedWidget(
              restaurants: insight.mostVisitedRestaurants.take(3).toList(),
              onRestaurantTap: onRestaurantTap,
            ),
          const SizedBox(height: 12),

          // Most liked restaurants
          if (insight.mostLikedRestaurants.isNotEmpty)
            MostLikedWidget(
              restaurants: insight.mostLikedRestaurants.take(3).toList(),
              onRestaurantTap: onRestaurantTap,
            ),
        ],
      ),
    );
  }

  Widget _buildMonthHeader(BuildContext context) {
    return Row(
      children: [
        Icon(
          CupertinoIcons.calendar,
          color: CupertinoColors.systemBlue,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          '${insight.monthName} ${insight.year}',
          style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 19,
            letterSpacing: -0.4,
          ),
        ),
        const Spacer(),
        Text(
          '${insight.totalReviews} reviews',
          style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
            color: CupertinoColors.systemGrey,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
