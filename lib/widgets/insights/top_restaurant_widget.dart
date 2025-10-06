import 'package:flutter/cupertino.dart';
import '../../../models/insights.dart';

class TopRestaurantWidget extends StatelessWidget {
  final RestaurantInsight restaurant;
  final String monthName;
  final VoidCallback onTap;

  const TopRestaurantWidget({
    super.key,
    required this.restaurant,
    required this.monthName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: CupertinoColors.systemGreen.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              CupertinoIcons.star_fill,
              color: CupertinoColors.systemGreen,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Top Restaurant in $monthName',
                    style: CupertinoTheme.of(context).textTheme.textStyle
                        .copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: CupertinoColors.systemGreen,
                          letterSpacing: 0.2,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    restaurant.restaurantName,
                    style: CupertinoTheme.of(context).textTheme.textStyle
                        .copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${restaurant.averageRating.toStringAsFixed(1)} ⭐ • ${restaurant.reviewCount} reviews',
                    style: CupertinoTheme.of(context).textTheme.textStyle
                        .copyWith(
                          color: CupertinoColors.systemGrey,
                          fontSize: 13,
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
    );
  }
}
