import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/restaurant_service.dart';
import '../models/restaurant.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final RestaurantService _restaurantService = RestaurantService();
  List<Restaurant> _restaurants = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }

  Future<void> _loadRestaurants() async {
    try {
      print('🗺️ Loading restaurants for map...');
      final restaurants = await _restaurantService.getAllRestaurants().timeout(
        const Duration(seconds: 30),
      );
      print('🗺️ Loaded ${restaurants.length} restaurants');
      setState(() {
        _restaurants = restaurants;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      print('🗺️ Error loading restaurants: $e');
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          _isLoading ? 'Loading...' : 'Restaurants (${_restaurants.length})',
        ),
        backgroundColor: CupertinoColors.systemBackground,
      ),
      child: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: const LatLng(
                55.6761,
                12.5683,
              ), // Copenhagen coordinates
              initialZoom: 13.0,
              minZoom: 10.0,
              maxZoom: 18.0,
            ),
            children: [
              TileLayer(
                urlTemplate: isDark
                    ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
                    : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.crf',
              ),
              if (!_isLoading) MarkerLayer(markers: _buildRestaurantMarkers()),
            ],
          ),
          if (_isLoading)
            const Center(child: CupertinoActivityIndicator(radius: 20)),
          if (_error != null)
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemRed.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Failed to load restaurants',
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CupertinoButton.filled(
                      onPressed: _loadRestaurants,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Marker> _buildRestaurantMarkers() {
    return _restaurants.map((restaurant) {
      return Marker(
        point: restaurant.location,
        width: 24,
        height: 24,
        child: GestureDetector(
          onTap: () => _showRestaurantInfo(restaurant),
          child: Container(
            decoration: BoxDecoration(
              color: CupertinoColors.systemBlue,
              shape: BoxShape.circle,
              border: Border.all(color: CupertinoColors.white, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: CupertinoColors.black.withOpacity(0.2),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: const Icon(
              CupertinoIcons.location_solid,
              color: CupertinoColors.white,
              size: 12,
            ),
          ),
        ),
      );
    }).toList();
  }

  void _showRestaurantInfo(Restaurant restaurant) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(restaurant.name),
        message: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cuisines: ${restaurant.cuisines.join(', ')}'),
            if (restaurant.neighborhood != null)
              Text('Neighborhood: ${restaurant.neighborhood}'),
            if (restaurant.phone != null) Text('Phone: ${restaurant.phone}'),
            if (restaurant.website != null)
              Text('Website: ${restaurant.website}'),
            const SizedBox(height: 8),
            Row(
              children: [
                if (restaurant.features.hasOutdoorSeating)
                  const Icon(
                    CupertinoIcons.leaf_arrow_circlepath,
                    size: 16,
                    color: CupertinoColors.systemGreen,
                  ),
                if (restaurant.features.isWheelchairAccessible)
                  const Icon(
                    CupertinoIcons.checkmark_circle,
                    size: 16,
                    color: CupertinoColors.systemBlue,
                  ),
              ],
            ),
          ],
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to restaurant details
            },
            child: const Text('View Details'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Get directions
            },
            child: const Text('Get Directions'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }
}
