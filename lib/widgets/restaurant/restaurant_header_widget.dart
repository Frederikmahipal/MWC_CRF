import 'package:flutter/cupertino.dart';
import '../../models/restaurant.dart';
import '../../core/app_settings.dart';
import '../../controllers/restaurant_controller.dart';
import '../../services/visited_restaurants_service.dart';
import '../../core/insights_refresh_notifier.dart';
import '../../services/insights_service.dart';

class RestaurantHeaderWidget extends StatefulWidget {
  final Restaurant restaurant;
  final RestaurantController controller;
  final VoidCallback? onVisitedChanged;

  const RestaurantHeaderWidget({
    super.key,
    required this.restaurant,
    required this.controller,
    this.onVisitedChanged,
  });

  @override
  State<RestaurantHeaderWidget> createState() => _RestaurantHeaderWidgetState();
}

class _RestaurantHeaderWidgetState extends State<RestaurantHeaderWidget> {
  bool _isVisited = false;
  bool _isLoadingVisited = false;
  int _totalVisits = 0;
  int _totalLikes = 0;
  bool _isLoadingTotals = false;

  @override
  void initState() {
    super.initState();
    _loadVisitedStatus();
    _loadTotals();

    // Listen for favorite changes to refresh totals
    widget.controller.addListener(_onControllerChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChange);
    super.dispose();
  }

  void _onControllerChange() {
    // Refresh totals when favorite status changes
    _loadTotals();
  }

  Future<void> _loadVisitedStatus() async {
    final visited = await VisitedRestaurantsService.hasVisited(
      widget.restaurant.id,
    );
    if (mounted) {
      setState(() {
        _isVisited = visited;
      });
    }
  }

  Future<void> _loadTotals() async {
    setState(() {
      _isLoadingTotals = true;
    });

    try {
      final totals = await InsightsService.getRestaurantTotals(
        widget.restaurant.id,
      );
      if (mounted) {
        setState(() {
          _totalVisits = totals['visits'] ?? 0;
          _totalLikes = totals['likes'] ?? 0;
          _isLoadingTotals = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingTotals = false;
        });
      }
    }
  }

  Future<void> _toggleVisited() async {
    if (_isLoadingVisited) return;

    setState(() {
      _isLoadingVisited = true;
    });

    try {
      if (_isVisited) {
        await VisitedRestaurantsService.removeFromVisited(widget.restaurant.id);
      } else {
        await VisitedRestaurantsService.markAsVisited(widget.restaurant.id);
      }

      if (mounted) {
        setState(() {
          _isVisited = !_isVisited;
        });

        // Notify parent widget that visited status changed
        widget.onVisitedChanged?.call();
        // Notify insights page to refresh (visits changed)
        InsightsRefreshNotifier().notifyRefresh(DataChangeType.visits);
        // Refresh totals to show updated visit count
        await _loadTotals();
      }
    } catch (e) {
      print('Error toggling visited status: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingVisited = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSettings.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.restaurant.name,
                  style: CupertinoTheme.of(context).textTheme.navTitleTextStyle
                      .copyWith(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              _buildVisitedButton(context),
              const SizedBox(width: 8),
              _buildFavoriteButton(context),
            ],
          ),
          const SizedBox(height: 8),
          if (widget.restaurant.cuisines.isNotEmpty) ...[
            Text(
              widget.restaurant.cuisines.join(' • '),
              style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                fontSize: 16,
                color: CupertinoColors.systemBlue,
              ),
            ),
            const SizedBox(height: 4),
          ],
          if (widget.restaurant.neighborhood != null) ...[
            Text(
              widget.restaurant.neighborhood!,
              style: CupertinoTheme.of(
                context,
              ).textTheme.textStyle.copyWith(color: CupertinoColors.systemGrey),
            ),
            const SizedBox(height: 8),
          ],
          _buildServiceIcons(context),
          const SizedBox(height: 12),
          _buildRatingDisplay(),
          const SizedBox(height: 12),
          _buildTotalsDisplay(),
        ],
      ),
    );
  }

  Widget _buildVisitedButton(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: _isLoadingVisited ? null : _toggleVisited,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _isVisited
              ? CupertinoColors.systemOrange.withOpacity(0.1)
              : AppSettings.getSecondaryTextColor(context).withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isVisited
                ? CupertinoColors.systemOrange.withOpacity(0.3)
                : AppSettings.getSecondaryTextColor(context).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: _isLoadingVisited
            ? const CupertinoActivityIndicator(radius: 8)
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isVisited ? CupertinoIcons.pin_fill : CupertinoIcons.pin,
                    color: _isVisited
                        ? CupertinoColors.systemOrange
                        : AppSettings.getSecondaryTextColor(context),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Been here',
                    style: TextStyle(
                      color: _isVisited
                          ? CupertinoColors.systemOrange
                          : AppSettings.getSecondaryTextColor(context),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildFavoriteButton(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: widget.controller.isLoadingFavorite
          ? null
          : () => widget.controller.toggleFavorite(widget.restaurant.id),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: widget.controller.isFavorited
              ? AppSettings.primaryColor.withOpacity(0.1)
              : AppSettings.getSecondaryTextColor(context).withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.controller.isFavorited
                ? AppSettings.primaryColor.withOpacity(0.3)
                : AppSettings.getSecondaryTextColor(context).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: widget.controller.isLoadingFavorite
            ? const CupertinoActivityIndicator(radius: 8)
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.controller.isFavorited
                        ? CupertinoIcons.heart_fill
                        : CupertinoIcons.heart,
                    color: widget.controller.isFavorited
                        ? AppSettings.primaryColor
                        : AppSettings.getSecondaryTextColor(context),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Like',
                    style: TextStyle(
                      color: widget.controller.isFavorited
                          ? AppSettings.primaryColor
                          : AppSettings.getSecondaryTextColor(context),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildRatingDisplay() {
    if (widget.controller.isLoadingRating) {
      return const Row(
        children: [
          CupertinoActivityIndicator(radius: 8),
          SizedBox(width: 8),
          Text(
            'Loading rating...',
            style: TextStyle(color: CupertinoColors.systemGrey),
          ),
        ],
      );
    }



    return Row(
      children: [
        Row(
          children: List.generate(5, (index) {
            final starRating = index + 1;
            final isFilled =
                starRating <= widget.controller.averageRating.round();
            final isHalfFilled =
                starRating - 0.5 <= widget.controller.averageRating &&
                widget.controller.averageRating < starRating;

            return Text(
              isFilled ? '⭐' : (isHalfFilled ? '⭐' : '☆'),
              style: const TextStyle(fontSize: 16),
            );
          }),
        ),
        const SizedBox(width: 8),
        Text(
          '${widget.controller.averageRating.toStringAsFixed(1)} (${widget.controller.totalReviews} review${widget.controller.totalReviews == 1 ? '' : 's'})',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: CupertinoColors.systemBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildServiceIcons(BuildContext context) {
    final List<Widget> serviceIcons = [];

    if (widget.restaurant.features.hasDelivery) {
      serviceIcons.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: CupertinoColors.systemGreen.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.car,
                size: 14,
                color: CupertinoColors.systemGreen,
              ),
              const SizedBox(width: 4),
              Text(
                'Delivery',
                style: TextStyle(
                  color: CupertinoColors.systemGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (widget.restaurant.features.hasTakeaway) {
      serviceIcons.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: CupertinoColors.systemOrange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: CupertinoColors.systemOrange.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.bag,
                size: 14,
                color: CupertinoColors.systemOrange,
              ),
              const SizedBox(width: 4),
              Text(
                'Takeaway',
                style: TextStyle(
                  color: CupertinoColors.systemOrange,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (serviceIcons.isEmpty) return const SizedBox.shrink();

    return Wrap(spacing: 8, runSpacing: 4, children: serviceIcons);
  }

  Widget _buildTotalsDisplay() {
    if (_isLoadingTotals) {
      return const Row(
        children: [
          CupertinoActivityIndicator(radius: 8),
          SizedBox(width: 8),
          Text(
            'Loading stats...',
            style: TextStyle(color: CupertinoColors.systemGrey),
          ),
        ],
      );
    }

    return Row(
      children: [
        _buildStatItem(
          icon: CupertinoIcons.pin_fill,
          count: _totalVisits,
          label: 'Visits',
          color: CupertinoColors.systemOrange,
        ),
        const SizedBox(width: 16),
        _buildStatItem(
          icon: CupertinoIcons.heart_fill,
          count: _totalLikes,
          label: 'Likes',
          color: CupertinoColors.systemPink,
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required int count,
    required String label,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          '$count',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 16,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: TextStyle(color: CupertinoColors.systemGrey, fontSize: 14),
        ),
      ],
    );
  }
}
