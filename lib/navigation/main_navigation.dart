import 'package:flutter/cupertino.dart';
import '../pages/restaurants/feed_page.dart';
import '../pages/search_page.dart';
import '../pages/notifications_page.dart';
import '../pages/profile/profile_page.dart';
import '../core/app_settings.dart';
import '../services/auth_service.dart';

class MainNavigation extends StatelessWidget {
  const MainNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: AppSettings.getSurfaceColor(context),
        activeColor: AppSettings.primaryColor,
        inactiveColor: AppSettings.getSecondaryTextColor(context),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.bell),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person),
            label: 'Profile',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return const FeedPage();
          case 1:
            return const SearchPage();
          case 2:
            return const NotificationsPage();
          case 3:
            return const ProfilePage();
          default:
            return const FeedPage();
        }
      },
    );
  }
}
