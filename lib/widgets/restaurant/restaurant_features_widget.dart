import 'package:flutter/cupertino.dart';
import '../../models/restaurant.dart';
import '../../core/app_settings.dart';

class RestaurantFeaturesWidget extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantFeaturesWidget({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    final features = <Widget>[];

    if (restaurant.features.hasOutdoorSeating) {
      features.add(
        _buildFeatureChip(
          CupertinoIcons.leaf_arrow_circlepath,
          'Outdoor Seating',
          CupertinoColors.systemGreen,
        ),
      );
    }

    if (restaurant.features.isWheelchairAccessible) {
      features.add(
        _buildFeatureChip(
          CupertinoIcons.checkmark_circle,
          'Wheelchair Accessible',
          CupertinoColors.systemBlue,
        ),
      );
    }

    if (restaurant.features.hasTakeaway) {
      features.add(
        _buildFeatureChip(
          CupertinoIcons.bag,
          'Takeaway',
          CupertinoColors.systemOrange,
        ),
      );
    }

    if (restaurant.features.hasDelivery) {
      features.add(
        _buildFeatureChip(
          CupertinoIcons.car,
          'Delivery',
          CupertinoColors.systemPurple,
        ),
      );
    }

    if (restaurant.features.hasWifi) {
      features.add(
        _buildFeatureChip(
          CupertinoIcons.wifi,
          'WiFi',
          CupertinoColors.systemIndigo,
        ),
      );
    }

    if (features.isEmpty) {
      return const SizedBox.shrink();
    }

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
          Text(
            'Features',
            style: CupertinoTheme.of(
              context,
            ).textTheme.navTitleTextStyle.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: features),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
