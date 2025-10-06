import 'package:flutter/cupertino.dart';
import '../models/insights.dart';
import '../services/insights_service.dart';
import '../services/restaurant_service.dart';
import '../widgets/insights/monthly_insight_card_widget.dart';
import '../widgets/insights/insights_empty_state_widget.dart';
import 'restaurants/restaurant_main_page.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<MonthlyInsights> _insights = [];
  bool _isLoading = true;
  final RestaurantService _restaurantService = RestaurantService();

  @override
  void initState() {
    super.initState();
    _loadInsights();
  }

  Future<void> _loadInsights() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final insights = await InsightsService.getMonthlyInsights(monthsBack: 24);
      if (mounted) {
        setState(() {
          _insights = insights;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading insights: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showError('Failed to load insights. Please try again.');
      }
    }
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
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final insight = _insights[index];
            return MonthlyInsightCardWidget(
              insight: insight,
              onRestaurantTap: _navigateToRestaurant,
            );
          }, childCount: _insights.length),
        ),
      ],
    );
  }
}
