import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../core/app_settings.dart';
import '../services/restaurant_service.dart';
import '../models/restaurant.dart';
import 'restaurant_main_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final RestaurantService _restaurantService = RestaurantService();

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
    super.dispose();
  }

  Future<void> _loadRestaurants() async {
    try {
      final restaurants = await _restaurantService.getAllRestaurants();

      // Debug: Print some sample cuisine data
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

  void _filterRestaurants() {
    String query = _searchController.text.toLowerCase();

    setState(() {
      _filteredRestaurants = _allRestaurants.where((restaurant) {
        // Search by name, cuisine, or neighborhood
        bool matchesSearch =
            query.isEmpty ||
            restaurant.name.toLowerCase().contains(query) ||
            restaurant.cuisines.any(
              (cuisine) => cuisine.toLowerCase().contains(query),
            ) ||
            (restaurant.neighborhood?.toLowerCase().contains(query) ?? false);

        // Filter by selected cuisines (case-insensitive matching)
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
      navigationBar: CupertinoNavigationBar(
        middle: Text(_isMapExpanded ? 'Map View' : 'Search & Map'),
        backgroundColor: CupertinoColors.systemGroupedBackground,
        trailing: _isMapExpanded
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _toggleMapExpansion,
                child: const Text('Done'),
              )
            : null,
      ),
      child: _isLoading
          ? const Center(child: CupertinoActivityIndicator(radius: 20))
          : _buildMainContent(),
    );
  }

  Widget _buildMainContent() {
    if (_isMapExpanded) {
      return _buildExpandedMap();
    }

    return SafeArea(
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
                  ? CupertinoColors.systemBlue
                  : CupertinoColors.systemGrey5,
              borderRadius: BorderRadius.circular(20),
              onPressed: () => _toggleCuisineFilter(cuisine),
              child: Text(
                cuisine,
                style: TextStyle(
                  color: isSelected
                      ? CupertinoColors.white
                      : CupertinoColors.label,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMiniMap() {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CupertinoColors.systemGrey4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: const LatLng(55.6761, 12.5683),
                initialZoom: 13.0,
                minZoom: 10.0,
                maxZoom: 18.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
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
                MarkerLayer(markers: _buildFilteredMarkers()),
              ],
            ),
            Positioned(
              top: 8,
              right: 8,
              child: CupertinoButton(
                padding: const EdgeInsets.all(8),
                color: CupertinoColors.systemBlue.withOpacity(0.8),
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
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    return FlutterMap(
      options: MapOptions(
        initialCenter: const LatLng(55.6761, 12.5683),
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
        MarkerLayer(markers: _buildFilteredMarkers()),
      ],
    );
  }

  List<Marker> _buildFilteredMarkers() {
    return _filteredRestaurants.map((restaurant) {
      return Marker(
        point: restaurant.location,
        width: 20,
        height: 20,
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (context) =>
                    RestaurantMainPage(restaurant: restaurant),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: CupertinoColors.systemBlue,
              shape: BoxShape.circle,
              border: Border.all(color: CupertinoColors.white, width: 1),
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
              size: 10,
            ),
          ),
        ),
      );
    }).toList();
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
            Text(restaurant.cuisines.join(', ')),
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
            const Icon(CupertinoIcons.chevron_right),
          ],
        ),
        onTap: () {
          Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (context) => RestaurantMainPage(restaurant: restaurant),
            ),
          );
        },
      ),
    );
  }
}

 
