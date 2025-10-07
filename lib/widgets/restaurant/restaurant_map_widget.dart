import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/restaurant.dart';
import '../../core/app_settings.dart';

class RestaurantMapWidget extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantMapWidget({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(AppSettings.defaultPadding),
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSettings.defaultBorderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSettings.defaultBorderRadius),
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: restaurant.location,
                initialZoom: 16.0,
                minZoom: 10.0,
                maxZoom: 18.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: isDark
                      ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
                      : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                  userAgentPackageName: 'com.example.crf',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: restaurant.location,
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemRed,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: CupertinoColors.white,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: CupertinoColors.black.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          CupertinoIcons.location_solid,
                          color: CupertinoColors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Invisible layer that covers map
            Positioned.fill(
              child: GestureDetector(
                onTap: () => _openInMapsApp(context),
                child: Container(color: Colors.transparent),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openInMapsApp(BuildContext context) async {
    try {
      final lat = restaurant.location.latitude;
      final long = restaurant.location.longitude;
      final restaurantName = restaurant.name;

      final appleMapsUrl =
          'https://maps.apple.com/?q=$restaurantName&ll=$lat,$long';
      final appleMapsUri = Uri.parse(appleMapsUrl);

      if (await canLaunchUrl(appleMapsUri)) {
        await launchUrl(appleMapsUri, mode: LaunchMode.externalApplication);
      } else {
        final googleMapsUrl =
            'https://maps.google.com/?q=$restaurantName&ll=$lat,$long';
        final googleMapsUri = Uri.parse(googleMapsUrl);

        if (await canLaunchUrl(googleMapsUri)) {
          await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication);
        } else {
          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text('Error'),
              content: Text('Could not open maps app'),
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
    } catch (e) {
      print('Error opening maps app: $e');
    }
  }
}
