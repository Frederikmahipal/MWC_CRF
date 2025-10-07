import 'package:flutter/cupertino.dart';
import '../../models/restaurant.dart';
import '../../core/app_settings.dart';
import '../../controllers/restaurant_controller.dart';

class RestaurantHeaderWidget extends StatelessWidget {
  final Restaurant restaurant;
  final RestaurantController controller;

  const RestaurantHeaderWidget({
    super.key,
    required this.restaurant,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSettings.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  restaurant.name,
                  style: CupertinoTheme.of(context).textTheme.navTitleTextStyle
                      .copyWith(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              _buildFavoriteButton(context),
            ],
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
          const SizedBox(height: 12),
          _buildRatingDisplay(),
        ],
      ),
    );
  }

  Widget _buildFavoriteButton(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: controller.isLoadingFavorite
          ? null
          : () => controller.toggleFavorite(restaurant.id),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: controller.isFavorited
              ? AppSettings.primaryColor.withOpacity(0.1)
              : AppSettings.getSecondaryTextColor(context).withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: controller.isFavorited
                ? AppSettings.primaryColor.withOpacity(0.3)
                : AppSettings.getSecondaryTextColor(context).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: controller.isLoadingFavorite
            ? const CupertinoActivityIndicator(radius: 8)
            : Icon(
                controller.isFavorited
                    ? CupertinoIcons.heart_fill
                    : CupertinoIcons.heart,
                color: controller.isFavorited
                    ? AppSettings.primaryColor
                    : AppSettings.getSecondaryTextColor(context),
                size: 20,
              ),
      ),
    );
  }

  Widget _buildRatingDisplay() {
    if (controller.isLoadingRating) {
      return const Row(
        children: [
          CupertinoActivityIndicator(radius: 8),
          SizedBox(width: 8),
          Text(
            'Loading rating...',
            style: TextStyle(color: CupertinoColors.systemGrey),
          ),
        ],
      );
    }

    if (controller.totalReviews == 0) {
      return const Row(
        children: [
          Text('⭐', style: TextStyle(fontSize: 16)),
          SizedBox(width: 4),
          Text(
            'No reviews yet',
            style: TextStyle(
              color: CupertinoColors.systemGrey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Row(
          children: List.generate(5, (index) {
            final starRating = index + 1;
            final isFilled = starRating <= controller.averageRating.round();
            final isHalfFilled =
                starRating - 0.5 <= controller.averageRating &&
                controller.averageRating < starRating;

            return Text(
              isFilled ? '⭐' : (isHalfFilled ? '⭐' : '☆'),
              style: const TextStyle(fontSize: 16),
            );
          }),
        ),
        const SizedBox(width: 8),
        Text(
          '${controller.averageRating.toStringAsFixed(1)} (${controller.totalReviews} review${controller.totalReviews == 1 ? '' : 's'})',
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

    if (serviceIcons.isEmpty) return const SizedBox.shrink();

    return Wrap(spacing: 8, runSpacing: 4, children: serviceIcons);
  }
}
