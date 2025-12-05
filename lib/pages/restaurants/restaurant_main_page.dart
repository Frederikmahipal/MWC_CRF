import 'package:flutter/cupertino.dart';
import '../../models/restaurant.dart';
import '../../widgets/restaurant/restaurant_header_widget.dart';
import '../../widgets/restaurant/restaurant_info_widget.dart';
import '../../widgets/restaurant/restaurant_features_widget.dart';
import '../../widgets/restaurant/restaurant_contact_widget.dart';
import '../../widgets/restaurant/restaurant_map_widget.dart';

class RestaurantMainPage extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantMainPage({super.key, required this.restaurant});

  @override
  State<RestaurantMainPage> createState() => _RestaurantMainPageState();
}

class _RestaurantMainPageState extends State<RestaurantMainPage> {
  @override
  void initState() {
    super.initState();
    print(
      '🏪 RestaurantMainPage initState: ${widget.restaurant.id} (${widget.restaurant.name})',
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.restaurant.name, overflow: TextOverflow.ellipsis),
        backgroundColor: CupertinoColors.systemGroupedBackground,
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: RestaurantHeaderWidget(
                key: ValueKey(widget.restaurant.id),
                restaurant: widget.restaurant,
              ),
            ),
            SliverToBoxAdapter(
              child: RestaurantInfoWidget(
                openingHours: widget.restaurant.openingHours,
                restaurant: widget.restaurant,
              ),
            ),
            SliverToBoxAdapter(
              child: RestaurantFeaturesWidget(restaurant: widget.restaurant),
            ),
            SliverToBoxAdapter(
              child: RestaurantContactWidget(restaurant: widget.restaurant),
            ),
            SliverToBoxAdapter(
              child: RestaurantMapWidget(restaurant: widget.restaurant),
            ),
          ],
        ),
      ),
    );
  }
}
