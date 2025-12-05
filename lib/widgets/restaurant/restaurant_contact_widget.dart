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
              _getDisplayUrl(restaurant.website!),
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

  String _getDisplayUrl(String url) {
    try {
      // Remove http:// or https://
      String cleanUrl = url.replaceFirst(RegExp(r'^https?://'), '');
      // Remove www.
      cleanUrl = cleanUrl.replaceFirst(RegExp(r'^www\.'), '');
      // Remove query parameters and fragments
      cleanUrl = cleanUrl.split('?').first;
      cleanUrl = cleanUrl.split('#').first;
      // Remove trailing slash
      cleanUrl = cleanUrl.replaceFirst(RegExp(r'/$'), '');
      return cleanUrl;
    } catch (e) {
      // If parsing fails, return original
      return url;
    }
  }

  void _makePhoneCall(String phoneNumber) async {
    try {
      // Remove any non-digit characters except +
      final cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      final phoneUri = Uri.parse('tel:$cleanedNumber');
      
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        print('Could not launch phone call: $phoneNumber');
      }
    } catch (e) {
      print('Error making phone call: $e');
    }
  }

  void _openWebsite(BuildContext context, String website) async {
    try {
      // Ensure URL has a scheme (http:// or https://)
      String urlString = website.trim();
      if (!urlString.startsWith('http://') && !urlString.startsWith('https://')) {
        urlString = 'https://$urlString';
      }

      final Uri url = Uri.parse(urlString);

      // Try to launch URL - on Android 11+, canLaunchUrl might return false
      // even if the URL can be opened, so we try anyway
      try {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } catch (e) {
        // If launchUrl fails, try with platformDefault mode
        try {
          await launchUrl(url, mode: LaunchMode.platformDefault);
        } catch (e2) {
          print('Error opening website: $e2');
          if (context.mounted) {
            showCupertinoDialog(
              context: context,
              builder: (context) => CupertinoAlertDialog(
                title: const Text('Error'),
                content: Text('Could not open website: $urlString'),
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
    } catch (e) {
      print('Error opening website: $e');
      if (context.mounted) {
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
}
