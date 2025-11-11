import 'package:flutter/cupertino.dart';
import '../../../models/insights.dart';

class MostVisitedWidget extends StatelessWidget {
  final List<RestaurantInsight> restaurants;
  final Function(String restaurantId) onRestaurantTap;

  const MostVisitedWidget({
    super.key,
    required this.restaurants,
    required this.onRestaurantTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoColors.systemOrange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: CupertinoColors.systemOrange.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.location_fill,
                color: CupertinoColors.systemOrange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Most Visited',
                style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: CupertinoColors.systemOrange,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...restaurants.asMap().entries.map(
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
                        color: CupertinoColors.systemOrange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${entry.value.uniqueVisitors}',
                        style: CupertinoTheme.of(context).textTheme.textStyle
                            .copyWith(
                              fontWeight: FontWeight.bold,
                              color: CupertinoColors.systemOrange,
                              fontSize: 12,
                            ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.value.restaurantName,
                            style: CupertinoTheme.of(context)
                                .textTheme
                                .textStyle
                                .copyWith(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          Text(
                            '${entry.value.uniqueVisitors} visitors this month',
                            style: CupertinoTheme.of(context)
                                .textTheme
                                .textStyle
                                .copyWith(
                                  fontSize: 12,
                                  color: CupertinoColors.systemGrey,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
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
