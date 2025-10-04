import 'package:flutter/cupertino.dart';
import '../../core/app_settings.dart';
import '../../services/restaurant_service.dart';
import '../../models/restaurant.dart';
import 'restaurant_main_page.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
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
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final restaurants = await _restaurantService.getAllRestaurants();

      setState(() {
        _restaurants = restaurants;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(child: SafeArea(child: _buildBody()));
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CupertinoActivityIndicator(radius: 20));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.exclamationmark_triangle,
              size: 64,
              color: CupertinoColors.systemRed,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load restaurants',
              style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: CupertinoTheme.of(context).textTheme.textStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            CupertinoButton.filled(
              onPressed: _loadRestaurants,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.all(AppSettings.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Copenhagen Restaurants',
                  style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
                ),
                const SizedBox(height: 8),
                Text(
                  '${_restaurants.length} restaurants found',
                  style: CupertinoTheme.of(context).textTheme.textStyle,
                ),
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final restaurant = _restaurants[index];
            return _buildRestaurantCard(restaurant);
          }, childCount: _restaurants.length),
        ),
      ],
    );
  }

  Widget _buildRestaurantCard(Restaurant restaurant) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSettings.defaultPadding,
        vertical: 6,
      ),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (context) => RestaurantMainPage(restaurant: restaurant),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppSettings.getSurfaceColor(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppSettings.getBorderColor(context),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppSettings.getPrimaryColor(context).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    _getRestaurantEmoji(restaurant.cuisines.first),
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant.name,
                      style: CupertinoTheme.of(context).textTheme.textStyle
                          .copyWith(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      restaurant.cuisines.join(' • '),
                      style: CupertinoTheme.of(context).textTheme.textStyle
                          .copyWith(
                            color: AppSettings.getSecondaryTextColor(context),
                            fontSize: 14,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (restaurant.features.hasOutdoorSeating)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemGreen.withOpacity(
                                0.1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  CupertinoIcons.leaf_arrow_circlepath,
                                  size: 12,
                                  color: CupertinoColors.systemGreen,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Outdoor',
                                  style: TextStyle(
                                    color: CupertinoColors.systemGreen,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (restaurant.features.hasOutdoorSeating &&
                            restaurant.features.isWheelchairAccessible)
                          const SizedBox(width: 8),
                        if (restaurant.features.isWheelchairAccessible)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemBlue.withOpacity(
                                0.1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  CupertinoIcons.checkmark_circle,
                                  size: 12,
                                  color: CupertinoColors.systemBlue,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Accessible',
                                  style: TextStyle(
                                    color: CupertinoColors.systemBlue,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                CupertinoIcons.chevron_right,
                color: AppSettings.getSecondaryTextColor(context),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getRestaurantEmoji(String cuisine) {
    switch (cuisine.toLowerCase()) {
      case 'italian':
        return '🍝';
      case 'asian':
      case 'sushi':
        return '🍣';
      case 'indian':
        return '🍛';
      case 'steak':
        return '🥩';
      case 'regional':
        return '🏠';
      case 'north_vietnamese':
        return '🍜';
      case 'chinese':
        return '🥢';
      case 'thai':
        return '🌶️';
      case 'mexican':
        return '🌮';
      case 'french':
        return '🥐';
      case 'japanese':
        return '🍱';
      case 'korean':
        return '🍲';
      case 'mediterranean':
        return '🫒';
      case 'american':
        return '🍔';
      case 'vegetarian':
        return '🥗';
      case 'vegan':
        return '🌱';
      default:
        return '🍽️';
    }
  }
}
