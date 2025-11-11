import 'dart:async';
import 'package:flutter/cupertino.dart';
import '../models/insights.dart';
import '../services/insights_service.dart';
import '../services/restaurant_service.dart';
import '../widgets/insights/monthly_insight_card_widget.dart';
import '../widgets/insights/insights_empty_state_widget.dart';
import '../widgets/insights/insight_skeleton_widget.dart';
import 'restaurants/restaurant_main_page.dart';
import '../core/insights_refresh_notifier.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<MonthlyInsights?> _insights = [];
  List<Map<String, int>> _availableMonths = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _loadedCount = 0;
  final int _initialLoadCount = 4; // Load first 4 months
  final int _loadMoreCount = 3; // Load 3 more when scrolling
  final RestaurantService _restaurantService = RestaurantService();
  late StreamSubscription<void> _refreshSubscription;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadInitialInsights();

    // Listen for refresh events
    _refreshSubscription = InsightsRefreshNotifier().refreshStream.listen((
      changeType,
    ) {
      _refreshInsights(changeType);
    });

    // Listen for scroll events for lazy loading
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _refreshSubscription.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialInsights() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final availableMonths = await InsightsService.getAvailableMonths(
        monthsBack: 36,
      );

      if (mounted) {
        setState(() {
          _availableMonths = availableMonths;
          _insights = List.filled(availableMonths.length, null);
          _isLoading = false;
        });

        // Load initial batch
        _loadedCount = 0;
        await _loadMoreInsights();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showError('Failed to load insights. Please try again.');
      }
    }
  }

  Future<void> _loadMoreInsights() async {
    if (_isLoadingMore || _loadedCount >= _availableMonths.length) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final loadCount = _loadedCount == 0 ? _initialLoadCount : _loadMoreCount;
      final endIndex = (_loadedCount + loadCount).clamp(
        0,
        _availableMonths.length,
      );

      // Load insights for the specific months we need
      final monthsToLoad = <Map<String, int>>[];
      for (int i = _loadedCount; i < endIndex; i++) {
        monthsToLoad.add(_availableMonths[i]);
      }

      // Load insights for these specific months
      final insights = await InsightsService.getInsightsForMonths(monthsToLoad);

      // Map the loaded insights to our list
      for (int i = 0; i < insights.length; i++) {
        final index = _loadedCount + i;
        final insight = insights[i];

        if (mounted) {
          setState(() {
            _insights[index] = insight;
          });
        }
      }

      if (mounted) {
        setState(() {
          _loadedCount = endIndex;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  void _onScroll() {
    final position = _scrollController.position;
    final maxScrollExtent = position.maxScrollExtent;
    final currentPixels = position.pixels;

    // Calculate which month we're currently viewing
    final itemHeight = 400.0; 
    final currentIndex = (currentPixels / itemHeight).floor();

    if (currentIndex >= _loadedCount - 1 &&
        _loadedCount < _availableMonths.length) {
      _loadMoreInsights();
    }
    //  load more when bottom is near
    else if (currentPixels >= maxScrollExtent - 200) {
      _loadMoreInsights();
    }
  }

  Future<void> _refreshInsights([DataChangeType? changeType]) async {
    await InsightsService.clearCache();
    await _loadInitialInsights();
  }

  void _showError(String message) {
    if (mounted) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _navigateToRestaurant(String restaurantId) async {
    try {
      final restaurants = await _restaurantService.getAllRestaurants();
      final restaurant = restaurants.firstWhere(
        (r) => r.id == restaurantId,
        orElse: () => throw Exception('Restaurant not found'),
      );

      if (mounted) {
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => RestaurantMainPage(restaurant: restaurant),
          ),
        );
      }
    } catch (e) {
      _showError('Could not find restaurant: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Insights'),
        backgroundColor: CupertinoColors.systemGroupedBackground,
      ),
      child: SafeArea(
        child: _isLoading
            ? const Center(child: CupertinoActivityIndicator())
            : _insights.isEmpty
            ? const InsightsEmptyStateWidget()
            : _buildInsightsList(),
      ),
    );
  }

  Widget _buildInsightsList() {
    return CustomScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        CupertinoSliverRefreshControl(onRefresh: _refreshInsights),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final insight = _insights[index];

            if (insight == null) {
              return const InsightSkeletonWidget();
            }

            return MonthlyInsightCardWidget(
              insight: insight,
              onRestaurantTap: _navigateToRestaurant,
            );
          }, childCount: _insights.length),
        ),

        if (_isLoadingMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CupertinoActivityIndicator()),
            ),
          ),
      ],
    );
  }
}
