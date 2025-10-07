import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/restaurant.dart';
import '../../core/app_settings.dart';

class RestaurantContactWidget extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantContactWidget({super.key, required this.restaurant});

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
            'Contact Information',
            style: CupertinoTheme.of(
              context,
            ).textTheme.navTitleTextStyle.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 12),
          if (restaurant.phone != null) ...[
            _buildContactButton(
              context,
              CupertinoIcons.phone,
              'Call',
              restaurant.phone!,
              () => _makePhoneCall(restaurant.phone!),
            ),
            const SizedBox(height: 8),
          ],
          if (restaurant.website != null) ...[
            _buildContactButton(
              context,
              CupertinoIcons.globe,
              'Visit Website',
              restaurant.website!,
              () => _openWebsite(context, restaurant.website!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContactButton(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    VoidCallback onTap,
  ) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Row(
        children: [
          Icon(icon, size: 16, color: CupertinoColors.systemBlue),
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
                  style: CupertinoTheme.of(context).textTheme.textStyle
                      .copyWith(color: CupertinoColors.systemGrey),
                ),
              ],
            ),
          ),
          const Icon(
            CupertinoIcons.chevron_right,
            size: 16,
            color: CupertinoColors.systemGrey,
          ),
        ],
      ),
    );
  }

  void _makePhoneCall(String phoneNumber) {
    // TODO: Implement phone call functionality
    print('Calling: $phoneNumber');
  }

  void _openWebsite(BuildContext context, String website) async {
    try {
      final Uri url = Uri.parse(website);

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: const Text('Could not open website'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Error opening website: $e');
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Error'),
          content: Text('Invalid URL: $website'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }
}
