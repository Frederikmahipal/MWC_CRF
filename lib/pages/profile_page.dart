import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:crf/services/user_detection_service.dart';
import '../core/app_settings.dart';
import '../core/onboarding_controller.dart';
import '../services/favorites_service.dart';
import '../services/review_service.dart';
import 'onboarding/welcome_page.dart';
import 'preferences_page.dart';
import 'favorites_page.dart';
import 'my_reviews_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with RouteAware {
  String _username = 'Guest User';
  String _avatar = '👤';
  int _reviewCount = 0;
  int _favoriteCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void didPopNext() {
    super.didPopNext();
    _loadFavoriteCount();
    _loadReviewCount();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ModalRoute.of(context)?.isCurrent == true) {
      _loadFavoriteCount();
      _loadReviewCount();
    }
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await UserDetectionService.getUserData();
      if (userData != null) {
        setState(() {
          _username = '${userData['firstName']} ${userData['lastName']}';
          _avatar = userData['avatarEmoji'] ?? '👤';
        });
      } else {
        final localData = await OnboardingController.getCurrentUser();
        setState(() {
          _username = localData['name'] ?? 'Guest User';
          _avatar = localData['avatar'] ?? '👤';
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      final localData = await OnboardingController.getCurrentUser();
      setState(() {
        _username = localData['name'] ?? 'Guest User';
        _avatar = localData['avatar'] ?? '👤';
      });
    }
    _loadFavoriteCount();
    _loadReviewCount();
  }

  Future<void> _loadFavoriteCount() async {
    try {
      final favorites = await FavoritesService.getUserFavorites();
      if (mounted) {
        setState(() {
          _favoriteCount = favorites.length;
        });
      }
    } catch (e) {
      print('Error loading favorite count: $e');
    }
  }

  Future<void> _loadReviewCount() async {
    try {
      final reviews = await ReviewService.getUserReviews();
      if (mounted) {
        setState(() {
          _reviewCount = reviews.length;
        });
        print('📊 Updated review count: $_reviewCount');
      }
    } catch (e) {
      print('Error loading review count: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Profile'),
        backgroundColor: CupertinoColors.systemGroupedBackground,
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey5,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          _avatar,
                          style: const TextStyle(fontSize: 40),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _username,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppSettings.getSurfaceColor(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Reviews', _reviewCount.toString()),
                    _buildStatItem('Favorites', _favoriteCount.toString()),
                    _buildStatItem('Visited', '0'),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            SliverList(
              delegate: SliverChildListDelegate([
                _buildMenuItem(
                  icon: CupertinoIcons.heart,
                  title: 'My Favorites',
                  onTap: () async {
                    await Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => const FavoritesPage(),
                      ),
                    );
                    _loadFavoriteCount();
                  },
                ),
                _buildMenuItem(
                  icon: CupertinoIcons.star,
                  title: 'My Reviews',
                  onTap: () async {
                    await Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => const MyReviewsPage(),
                      ),
                    );
                    _loadReviewCount();
                  },
                ),
                _buildMenuItem(
                  icon: CupertinoIcons.settings,
                  title: 'Preferences',
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => const PreferencesPage(),
                      ),
                    );
                  },
                ),
                _buildMenuItem(
                  icon: CupertinoIcons.info_circle,
                  title: 'About',
                  onTap: () {
                  },
                ),
                _buildMenuItem(
                  icon: CupertinoIcons.square_arrow_right,
                  title: 'Logout',
                  onTap: () {
                    _showLogoutDialog();
                  },
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: CupertinoColors.systemGrey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppSettings.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: CupertinoListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(CupertinoIcons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _showLogoutDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Logout'),
        content: const Text(
          'Are you sure you want to logout? You will need to sign in again to access your account.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Logout'),
            onPressed: () {
              Navigator.of(context).pop();
              _logout();
            },
          ),
        ],
      ),
    );
  }

  void _logout() async {
    try {
      await FirebaseAuth.instance.signOut();

      await OnboardingController.resetOnboarding();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          CupertinoPageRoute(builder: (context) => const WelcomePage()),
          (route) => false,
        );
      }
    } catch (e) {
      print('Error during logout: $e');
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          CupertinoPageRoute(builder: (context) => const WelcomePage()),
          (route) => false,
        );
      }
    }
  }
}
