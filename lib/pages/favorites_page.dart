import 'package:flutter/cupertino.dart';
import '../core/app_settings.dart';
import '../models/restaurant.dart';
import '../services/favorites_service.dart';
import '../services/restaurant_service.dart';
import 'restaurant_main_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final RestaurantService _restaurantService = RestaurantService();

  List<Restaurant> _favoriteRestaurants = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final favoriteIds = await FavoritesService.getUserFavorites();

      if (!mounted) return;
      if (favoriteIds.isEmpty) {
        setState(() {
          _favoriteRestaurants = [];
          _isLoading = false;
        });
        return;
      }

      List<Restaurant> allRestaurants = [];
      try {
        allRestaurants = await _restaurantService.getAllRestaurants().timeout(
          const Duration(seconds: 10),
        );
      } catch (e) {
        print('Failed to load restaurants: $e');
        if (!mounted) return;
        setState(() {
          _error =
              'Unable to load restaurant data. Please check your internet connection and try again.';
          _isLoading = false;
        });
        return;
      }

      final favoriteRestaurants = allRestaurants
          .where((restaurant) => favoriteIds.contains(restaurant.id))
          .toList();

      if (!mounted) return;
      setState(() {
        _favoriteRestaurants = favoriteRestaurants;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load favorites: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _removeFavorite(Restaurant restaurant) async {
    try {
      final success = await FavoritesService.removeFromFavorites(restaurant.id);
      if (success && mounted) {
        setState(() {
          _favoriteRestaurants.removeWhere((r) => r.id == restaurant.id);
        });

        if (mounted) {
          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text('Removed from Favorites'),
              content: Text(
                '${restaurant.name} has been removed from your favorites.',
              ),
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
      print('Error removing favorite: $e');
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: const Text('Failed to remove favorite. Please try again.'),
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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('My Favorites'),
        backgroundColor: CupertinoColors.systemGroupedBackground,
      ),
      child: SafeArea(child: _buildContent()),
    );
  }

  Widget _buildContent() {
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
              size: 48,
              color: CupertinoColors.systemRed,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: CupertinoColors.systemGrey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            CupertinoButton.filled(
              onPressed: _loadFavorites,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_favoriteRestaurants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.heart,
              size: 64,
              color: CupertinoColors.systemGrey,
            ),
            const SizedBox(height: 16),
            Text(
              'No favorites yet',
              style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap the heart icon on restaurants to add them to your favorites',
              style: TextStyle(color: CupertinoColors.systemGrey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final restaurant = _favoriteRestaurants[index];
            return _buildRestaurantCard(restaurant);
          }, childCount: _favoriteRestaurants.length),
        ),
      ],
    );
  }

  Widget _buildRestaurantCard(Restaurant restaurant) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSettings.defaultPadding,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppSettings.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(AppSettings.defaultBorderRadius),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: CupertinoListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey5,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            CupertinoIcons.building_2_fill,
            color: CupertinoColors.systemGrey,
          ),
        ),
        title: Text(
          restaurant.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (restaurant.cuisines.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                restaurant.cuisines.join(' • '),
                style: const TextStyle(
                  color: CupertinoColors.systemBlue,
                  fontSize: 12,
                ),
              ),
            ],
            if (restaurant.neighborhood != null) ...[
              const SizedBox(height: 2),
              Text(
                restaurant.neighborhood!,
                style: const TextStyle(
                  color: CupertinoColors.systemGrey,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => _removeFavorite(restaurant),
              child: const Icon(
                CupertinoIcons.heart_fill,
                color: CupertinoColors.systemRed,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              CupertinoIcons.chevron_right,
              color: CupertinoColors.systemGrey,
              size: 16,
            ),
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
