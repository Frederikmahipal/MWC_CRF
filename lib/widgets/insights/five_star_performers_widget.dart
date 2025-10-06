import 'package:flutter/cupertino.dart';
import '../../../models/insights.dart';

class FiveStarPerformersWidget extends StatelessWidget {
  final List<RestaurantInsight> restaurants;
  final Function(String restaurantId) onRestaurantTap;

  const FiveStarPerformersWidget({
    super.key,
    required this.restaurants,
    required this.onRestaurantTap,
  });

  @override
  Widget build(BuildContext context) {
    final topFiveStar = restaurants.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoColors.systemYellow.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: CupertinoColors.systemYellow.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    CupertinoIcons.star_fill,
                    color: CupertinoColors.systemYellow,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Most 5⭐ Reviews',
                    style: CupertinoTheme.of(context).textTheme.textStyle
                        .copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: CupertinoColors.systemYellow,
                          letterSpacing: 0.2,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'Count of 5-star reviews this month',
                style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                  fontSize: 11,
                  color: CupertinoColors.systemGrey,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...topFiveStar.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => onRestaurantTap(entry.value.restaurantId),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemYellow.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${entry.value.fiveStarCount}×',
                        style: CupertinoTheme.of(context).textTheme.textStyle
                            .copyWith(
                              fontWeight: FontWeight.bold,
                              color: CupertinoColors.systemYellow,
                              fontSize: 12,
                            ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.value.restaurantName,
                        style: CupertinoTheme.of(context).textTheme.textStyle
                            .copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                    Icon(
                      CupertinoIcons.chevron_right,
                      color: CupertinoColors.systemGrey,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
