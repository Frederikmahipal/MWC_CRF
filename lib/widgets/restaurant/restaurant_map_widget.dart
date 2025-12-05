import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/restaurant.dart';
import '../../core/app_settings.dart';

class RestaurantMapWidget extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantMapWidget({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppSettings.getPrimaryColor(context);
    final primaryHue = _colorToHue(primaryColor);

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
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  restaurant.location.latitude,
                  restaurant.location.longitude,
                ),
                zoom: 16.0,
              ),
              markers: {
                Marker(
                  markerId: MarkerId(restaurant.id),
                  position: LatLng(
                    restaurant.location.latitude,
                    restaurant.location.longitude,
                  ),
                  icon: BitmapDescriptor.defaultMarkerWithHue(primaryHue),
                  infoWindow: InfoWindow(title: restaurant.name),
                ),
              },
              mapType: MapType.normal,
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              scrollGesturesEnabled: false,
              zoomGesturesEnabled: false,
              tiltGesturesEnabled: false,
              rotateGesturesEnabled: false,
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
      final lng = restaurant.location.longitude;
      final restaurantName = restaurant.name;
      final address = restaurant.address;

      Uri mapsUri;

      if (Platform.isIOS) {
        // Use Apple Maps on iOS - use address if available, otherwise use coordinates with name
        if (address != null && address.isNotEmpty) {
          // Build URL with query parameters properly
          mapsUri = Uri(
            scheme: 'https',
            host: 'maps.apple.com',
            queryParameters: {'q': restaurantName, 'address': address},
          );
        } else {
          mapsUri = Uri(
            scheme: 'https',
            host: 'maps.apple.com',
            queryParameters: {'q': restaurantName, 'll': '$lat,$lng'},
          );
        }
      } else {
        // Use Google Maps on Android - use name and coordinates
        final query = address != null && address.isNotEmpty
            ? '$restaurantName, $address'
            : restaurantName;
        mapsUri = Uri(
          scheme: 'https',
          host: 'www.google.com',
          path: '/maps/search/',
          queryParameters: {'api': '1', 'query': query},
        );
      }

      if (await canLaunchUrl(mapsUri)) {
        await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback to web Google Maps
        final query = address != null && address.isNotEmpty
            ? '$restaurantName, $address'
            : restaurantName;
        final webMapsUri = Uri(
          scheme: 'https',
          host: 'www.google.com',
          path: '/maps/search/',
          queryParameters: {'api': '1', 'query': query},
        );
        if (await canLaunchUrl(webMapsUri)) {
          await launchUrl(webMapsUri, mode: LaunchMode.externalApplication);
        } else {
          if (context.mounted) {
            showCupertinoDialog(
              context: context,
              builder: (context) => CupertinoAlertDialog(
                title: const Text('Error'),
                content: const Text('Could not open maps app'),
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
      print('Error opening maps app: $e');
    }
  }

  /// Convert Flutter Color to Google Maps hue value (0-360)
  double _colorToHue(Color color) {
    // Convert RGB to HSV
    final r = color.red / 255.0;
    final g = color.green / 255.0;
    final b = color.blue / 255.0;

    final max = r > g ? (r > b ? r : b) : (g > b ? g : b);
    final min = r < g ? (r < b ? r : b) : (g < b ? g : b);
    final delta = max - min;

    double hue = 0.0;
    if (delta != 0) {
      if (max == r) {
        hue = 60 * (((g - b) / delta) % 6);
      } else if (max == g) {
        hue = 60 * (((b - r) / delta) + 2);
      } else {
        hue = 60 * (((r - g) / delta) + 4);
      }
    }

    // Ensure hue is in range 0-360
    if (hue < 0) hue += 360;
    return hue;
  }
}
