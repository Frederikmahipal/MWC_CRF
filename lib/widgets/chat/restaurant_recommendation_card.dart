import 'package:flutter/cupertino.dart';
import '../../core/app_settings.dart';
import '../../models/restaurant.dart';

class RestaurantRecommendationCard extends StatelessWidget {
  final Restaurant restaurant;
  final ValueChanged<Restaurant>? onTap;

  const RestaurantRecommendationCard({
    super.key,
    required this.restaurant,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => onTap?.call(restaurant),
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
                    if (restaurant.cuisines.isNotEmpty) ...[
                      Text(
                        restaurant.cuisines.join(', '),
                        style: TextStyle(
                          color: AppSettings.getSecondaryTextColor(context),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
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
                    const SizedBox(height: 4),
                    _buildServiceIcons(context),
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

  Widget _buildServiceIcons(BuildContext context) {
    final List<Widget> serviceIcons = [];

    if (restaurant.features.hasDelivery) {
      serviceIcons.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: CupertinoColors.systemGreen.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.car,
                size: 10,
                color: CupertinoColors.systemGreen,
              ),
              const SizedBox(width: 2),
              Text(
                'Delivery',
                style: TextStyle(
                  color: CupertinoColors.systemGreen,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (restaurant.features.hasTakeaway) {
      serviceIcons.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: CupertinoColors.systemOrange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: CupertinoColors.systemOrange.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.bag,
                size: 10,
                color: CupertinoColors.systemOrange,
              ),
              const SizedBox(width: 2),
              Text(
                'Takeaway',
                style: TextStyle(
                  color: CupertinoColors.systemOrange,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (serviceIcons.isEmpty) return const SizedBox.shrink();

    return Wrap(spacing: 4, runSpacing: 2, children: serviceIcons);
  }
}
