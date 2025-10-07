import 'package:flutter/cupertino.dart';
import '../../core/app_settings.dart';
import '../../controllers/restaurant_controller.dart';

class RestaurantInfoWidget extends StatelessWidget {
  final String? openingHours;
  final RestaurantController controller;

  const RestaurantInfoWidget({
    super.key,
    this.openingHours,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSettings.defaultPadding,
      ),
      padding: const EdgeInsets.all(AppSettings.defaultPadding),
      decoration: BoxDecoration(
        color: AppSettings.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(AppSettings.defaultBorderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Restaurant Information',
            style: CupertinoTheme.of(
              context,
            ).textTheme.navTitleTextStyle.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 12),
          if (openingHours != null) ...[
            _buildInfoRow(
              context,
              CupertinoIcons.clock,
              'Opening Hours',
              openingHours!,
            ),
            const SizedBox(height: 8),
          ],
          _buildInfoRow(
            context,
            CupertinoIcons.location,
            'Address',
            controller.isLoadingAddress
                ? 'Loading address...'
                : controller.address ?? 'Address not available',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: CupertinoColors.systemGrey),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: CupertinoTheme.of(
                  context,
                ).textTheme.textStyle.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                value,
                style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                  color: CupertinoColors.systemGrey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
