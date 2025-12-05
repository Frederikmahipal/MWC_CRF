import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart' as latlong;
import '../core/app_settings.dart';
import '../services/restaurant_service.dart';
import '../models/restaurant.dart';
import 'restaurants/restaurant_main_page.dart';
import 'package:geolocator/geolocator.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final RestaurantService _restaurantService = RestaurantService();
  GoogleMapController? _mapController;
  latlong.LatLng? _userLocation;
  bool _isGettingLocation = false;

  List<Restaurant> _allRestaurants = [];
  List<Restaurant> _filteredRestaurants = [];
  List<String> _selectedCuisines = [];
  bool _isLoading = true;
  bool _isMapExpanded = false;

  late AnimationController _mapAnimationController;

  @override
  void initState() {
    super.initState();
    _mapAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _loadRestaurants();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapAnimationController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadRestaurants() async {
    try {
      final restaurants = await _restaurantService.getAllRestaurants();

      if (restaurants.isNotEmpty) {
        print('🍽️ Sample restaurant cuisines:');
        for (int i = 0; i < 5 && i < restaurants.length; i++) {
          print('  ${restaurants[i].name}: ${restaurants[i].cuisines}');
        }
      }

      setState(() {
        _allRestaurants = restaurants;
        _filteredRestaurants = restaurants;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getUserLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text('Location Services Disabled'),
              content: const Text(
                'Please enable location services to use this feature.',
              ),
              actions: [
                CupertinoDialogAction(
                  child: const Text('OK'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          );
        }
        setState(() {
          _isGettingLocation = false;
        });
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            showCupertinoDialog(
              context: context,
              builder: (context) => CupertinoAlertDialog(
                title: const Text('Location Permission Denied'),
                content: const Text(
                  'Location permission is required to show your location on the map.',
                ),
                actions: [
                  CupertinoDialogAction(
                    child: const Text('OK'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            );
          }
          setState(() {
            _isGettingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text('Location Permission Permanently Denied'),
              content: const Text(
                'Please enable location permission in app settings.',
              ),
              actions: [
                CupertinoDialogAction(
                  child: const Text('OK'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          );
        }
        setState(() {
          _isGettingLocation = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final userLocation = latlong.LatLng(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _userLocation = userLocation;
        _isGettingLocation = false;
      });

      // Animate map to user location
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(userLocation.latitude, userLocation.longitude),
          15.0,
        ),
      );
    } catch (e) {
      print('Error getting location: $e');
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: Text('Failed to get your location: $e'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }
      setState(() {
        _isGettingLocation = false;
      });
    }
  }

  void _filterRestaurants() {
    String query = _searchController.text.toLowerCase();

    setState(() {
      _filteredRestaurants = _allRestaurants.where((restaurant) {
        bool matchesSearch =
            query.isEmpty ||
            restaurant.name.toLowerCase().contains(query) ||
            restaurant.cuisines.any(
              (cuisine) => cuisine.toLowerCase().contains(query),
            ) ||
            (restaurant.neighborhood?.toLowerCase().contains(query) ?? false);

        bool matchesCuisine =
            _selectedCuisines.isEmpty ||
            restaurant.cuisines.any((restaurantCuisine) {
              return _selectedCuisines.any((selectedCuisine) {
                return restaurantCuisine.toLowerCase().contains(
                      selectedCuisine.toLowerCase(),
                    ) ||
                    selectedCuisine.toLowerCase().contains(
                      restaurantCuisine.toLowerCase(),
                    );
              });
            });

        return matchesSearch && matchesCuisine;
      }).toList();
    });
  }

  void _toggleCuisineFilter(String cuisine) {
    setState(() {
      if (_selectedCuisines.contains(cuisine)) {
        _selectedCuisines.remove(cuisine);
      } else {
        _selectedCuisines.add(cuisine);
      }
      print('🔍 Selected cuisines: $_selectedCuisines');
      _filterRestaurants();
    });
  }

  void _toggleMapExpansion() {
    setState(() {
      _isMapExpanded = !_isMapExpanded;
      if (_isMapExpanded) {
        _mapAnimationController.forward();
      } else {
        _mapAnimationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: _isLoading
          ? const Center(child: CupertinoActivityIndicator(radius: 20))
          : _buildMainContent(),
    );
  }

  Widget _buildMainContent() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          ),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: _isMapExpanded
          ? _buildExpandedMap()
          : SafeArea(
              key: const ValueKey('normal'),
              child: Column(
                children: [
                  _buildSearchSection(),
                  _buildCuisineFilters(),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(flex: 1, child: _buildMiniMap()),
                        Expanded(flex: 1, child: _buildResultsList()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: CupertinoSearchTextField(
        controller: _searchController,
        placeholder: 'Search restaurants or cuisines...',
        onChanged: (value) => _filterRestaurants(),
      ),
    );
  }

  Widget _buildCuisineFilters() {
    final popularCuisines = [
      'Italian',
      'Asian',
      'Danish',
      'French',
      'Mexican',
      'Sushi',
    ];

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: popularCuisines.map((cuisine) {
          final isSelected = _selectedCuisines.contains(cuisine);
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: isSelected
                  ? AppSettings.primaryColor
                  : AppSettings.getChipColor(context),
              borderRadius: BorderRadius.circular(20),
              onPressed: () => _toggleCuisineFilter(cuisine),
              child: Text(
                cuisine,
                style: TextStyle(
                  color: isSelected
                      ? CupertinoColors.white
                      : AppSettings.getTextColor(context),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMiniMap() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(
                  55.6761,
                  12.5683,
                ), // Copenhagen - Google Maps LatLng
                zoom: 13.0,
              ),
              markers: _buildGoogleMapMarkers(),
              mapType: MapType.normal,
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              scrollGesturesEnabled: true,
              zoomGesturesEnabled: true,
              tiltGesturesEnabled: false,
              rotateGesturesEnabled: false,
              onMapCreated: (GoogleMapController controller) {
                // Mini map doesn't need controller
              },
            ),
            Positioned(
              top: 8,
              right: 8,
              child: CupertinoButton(
                padding: const EdgeInsets.all(8),
                color: AppSettings.primaryColor.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                onPressed: _toggleMapExpansion,
                child: const Icon(
                  CupertinoIcons.fullscreen,
                  color: CupertinoColors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedMap() {
    return Stack(
      key: const ValueKey('expanded'),
      children: [
        GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(55.6761, 12.5683), // Copenhagen - Google Maps LatLng
            zoom: 13.0,
          ),
          markers: _buildGoogleMapMarkers(),
          mapType: MapType.normal,
          zoomControlsEnabled: true,
          myLocationButtonEnabled: false,
          myLocationEnabled: _userLocation != null,
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
          },
        ),
        Positioned(
          top: 50,
          right: 16,
          child: Column(
            children: [
              // Location button
              CupertinoButton(
                padding: const EdgeInsets.all(12),
                color: AppSettings.primaryColor.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                onPressed: _isGettingLocation ? null : _getUserLocation,
                child: _isGettingLocation
                    ? const CupertinoActivityIndicator(
                        color: CupertinoColors.white,
                      )
                    : const Icon(
                        CupertinoIcons.location_fill,
                        color: CupertinoColors.white,
                        size: 18,
                      ),
              ),
              const SizedBox(height: 8),
              // Close button
              CupertinoButton(
                padding: const EdgeInsets.all(12),
                color: AppSettings.primaryColor.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                onPressed: _toggleMapExpansion,
                child: const Icon(
                  CupertinoIcons.xmark,
                  color: CupertinoColors.white,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Set<Marker> _buildGoogleMapMarkers() {
    final markers = <Marker>{};
    final primaryColor = AppSettings.getPrimaryColor(context);
    final accentColor = AppSettings.accentColor;

    // Convert Color to HSV hue for Google Maps markers
    // Google Maps uses hue values 0-360, where 0=red, 120=green, 240=blue
    final primaryHue = _colorToHue(primaryColor);
    final accentHue = _colorToHue(accentColor);

    // Add restaurant markers
    for (final restaurant in _filteredRestaurants) {
      markers.add(
        Marker(
          markerId: MarkerId(restaurant.id),
          position: LatLng(
            restaurant.location.latitude,
            restaurant.location.longitude,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(primaryHue),
          infoWindow: InfoWindow(
            title: restaurant.name,
            snippet: restaurant.cuisines.join(', '),
          ),
          onTap: () {
            print(
              '🔵 Clicked restaurant: ${restaurant.id} (${restaurant.name})',
            );
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (context) => RestaurantMainPage(
                  key: ValueKey(restaurant.id),
                  restaurant: restaurant,
                ),
              ),
            );
          },
        ),
      );
    }

    // Add user location marker if available
    if (_userLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: LatLng(_userLocation!.latitude, _userLocation!.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(accentHue),
          infoWindow: const InfoWindow(title: 'Your Location'),
        ),
      );
    }

    return markers;
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

  Widget _buildResultsList() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${_filteredRestaurants.length} restaurants',
                  style: CupertinoTheme.of(
                    context,
                  ).textTheme.textStyle.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              if (_selectedCuisines.isNotEmpty)
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    setState(() {
                      _selectedCuisines.clear();
                      _filterRestaurants();
                    });
                  },
                  child: const Text('Clear'),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filteredRestaurants.length,
            itemBuilder: (context, index) {
              final restaurant = _filteredRestaurants[index];
              return _buildRestaurantCard(restaurant);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRestaurantCard(Restaurant restaurant) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppSettings.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CupertinoListTile(
        title: Text(restaurant.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (restaurant.neighborhood != null)
              Text(
                restaurant.neighborhood!,
                style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                  color: CupertinoColors.systemGrey,
                ),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
            if (restaurant.features.hasDelivery)
              const Icon(
                CupertinoIcons.car,
                size: 16,
                color: CupertinoColors.systemGreen,
              ),
            if (restaurant.features.hasTakeaway)
              const Icon(
                CupertinoIcons.bag,
                size: 16,
                color: CupertinoColors.systemOrange,
              ),
            const Icon(CupertinoIcons.chevron_right),
          ],
        ),
        onTap: () {
          print(
            '🔵 Clicked restaurant from list: ${restaurant.id} (${restaurant.name})',
          );
          Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (context) => RestaurantMainPage(
                key: ValueKey(restaurant.id),
                restaurant: restaurant,
              ),
            ),
          );
        },
      ),
    );
  }
}
