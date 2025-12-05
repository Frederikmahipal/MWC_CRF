import 'package:flutter/cupertino.dart';
import '../../models/restaurant.dart';
import '../../core/app_settings.dart';

class RestaurantHeaderWidget extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantHeaderWidget({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSettings.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            restaurant.name,
            style: CupertinoTheme.of(context).textTheme.navTitleTextStyle
                .copyWith(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (restaurant.cuisines.isNotEmpty) ...[
            Text(
              restaurant.cuisines.join(' • '),
              style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                fontSize: 16,
                color: CupertinoColors.systemBlue,
              ),
            ),
            const SizedBox(height: 4),
          ],
          if (restaurant.neighborhood != null) ...[
            Text(
              restaurant.neighborhood!,
              style: CupertinoTheme.of(
                context,
              ).textTheme.textStyle.copyWith(color: CupertinoColors.systemGrey),
            ),
            const SizedBox(height: 8),
          ],
          _buildServiceIcons(context),
          if (restaurant.averageRating > 0) ...[
            const SizedBox(height: 12),
            _buildRatingDisplay(context),
          ],
        ],
      ),
    );
  }

  Widget _buildRatingDisplay(BuildContext context) {
    final rating = restaurant.averageRating;
    final ratingCount = restaurant.totalReviews;

    return Row(
      children: [
        Row(
          children: List.generate(5, (index) {
            final starRating = index + 1;
            final isFilled = starRating <= rating.round();

            return Text(
              isFilled ? '⭐' : '☆',
              style: const TextStyle(fontSize: 16),
            );
          }),
        ),
        const SizedBox(width: 8),
        Text(
          '${rating.toStringAsFixed(1)}${ratingCount > 0 ? ' ($ratingCount)' : ''}',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: CupertinoColors.systemBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildServiceIcons(BuildContext context) {
    final List<Widget> serviceIcons = [];

    if (restaurant.features.hasDelivery) {
      serviceIcons.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
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
                size: 14,
                color: CupertinoColors.systemGreen,
              ),
              const SizedBox(width: 4),
              Text(
                'Delivery',
                style: TextStyle(
                  color: CupertinoColors.systemGreen,
                  fontSize: 12,
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: CupertinoColors.systemOrange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
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
                size: 14,
                color: CupertinoColors.systemOrange,
              ),
              const SizedBox(width: 4),
              Text(
                'Takeaway',
                style: TextStyle(
                  color: CupertinoColors.systemOrange,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (restaurant.features.isWheelchairAccessible) {
      serviceIcons.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: CupertinoColors.systemBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: CupertinoColors.systemBlue.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                CupertinoIcons.arrow_up_right,
                size: 14,
                color: CupertinoColors.systemBlue,
              ),
              const SizedBox(width: 4),
              Text(
                'Wheelchair',
                style: TextStyle(
                  color: CupertinoColors.systemBlue,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (serviceIcons.isEmpty) return const SizedBox.shrink();

    return Wrap(spacing: 8, runSpacing: 4, children: serviceIcons);
  }
}
