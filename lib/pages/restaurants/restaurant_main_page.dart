import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../models/restaurant.dart';
import '../../controllers/restaurant_controller.dart';
import '../../widgets/restaurant/restaurant_header_widget.dart';
import '../../widgets/restaurant/restaurant_info_widget.dart';
import '../../widgets/restaurant/restaurant_features_widget.dart';
import '../../widgets/restaurant/restaurant_reviews_widget.dart';
import '../../widgets/restaurant/restaurant_contact_widget.dart';
import '../../widgets/restaurant/restaurant_map_widget.dart';

class RestaurantMainPage extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantMainPage({super.key, required this.restaurant});

  @override
  State<RestaurantMainPage> createState() => _RestaurantMainPageState();
}

class _RestaurantMainPageState extends State<RestaurantMainPage> {
  late RestaurantController _controller;

  @override
  void initState() {
    super.initState();
    print('🏪 RestaurantMainPage initState: ${widget.restaurant.id} (${widget.restaurant.name})');
    _controller = RestaurantController();
    _controller.loadRestaurantDetails(
      widget.restaurant.id,
      restaurant: widget.restaurant,
    );
  }

  @override
  void didUpdateWidget(RestaurantMainPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.restaurant.id != widget.restaurant.id) {
      print('🔄 RestaurantMainPage restaurant changed: ${oldWidget.restaurant.id} -> ${widget.restaurant.id}');
      _controller.loadRestaurantDetails(
        widget.restaurant.id,
        restaurant: widget.restaurant,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RestaurantController>.value(
      value: _controller,
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(widget.restaurant.name, overflow: TextOverflow.ellipsis),
          backgroundColor: CupertinoColors.systemGroupedBackground,
        ),
        child: SafeArea(
          child: Consumer<RestaurantController>(
            builder: (context, controller, child) {
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: RestaurantHeaderWidget(
                      key: ValueKey(widget.restaurant.id),
                      restaurant: widget.restaurant,
                      controller: controller,
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: RestaurantInfoWidget(
                      openingHours: widget.restaurant.openingHours,
                      controller: controller,
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: RestaurantFeaturesWidget(
                      restaurant: widget.restaurant,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: RestaurantContactWidget(
                      restaurant: widget.restaurant,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: RestaurantMapWidget(restaurant: widget.restaurant),
                  ),
                  SliverToBoxAdapter(
                    child: RestaurantReviewsWidget(
                      restaurantId: widget.restaurant.id,
                      restaurantName: widget.restaurant.name,
                      controller: controller,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
