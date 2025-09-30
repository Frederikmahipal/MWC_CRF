import 'package:flutter/cupertino.dart';
import '../core/app_settings.dart';
import '../core/onboarding_controller.dart';
import '../navigation/main_navigation.dart';
import 'onboarding/name_input_page.dart';
import 'preferences_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _username = 'Guest User';
  String _avatar = '👤';
  int _reviewCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await OnboardingController.getCurrentUser();
    setState(() {
      _username = userData['name'] ?? 'Guest User';
      _avatar = userData['avatar'] ?? '👤';
    });
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
            // Profile header
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Profile picture with avatar
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
                    const SizedBox(height: 8),
                    Text(
                      '$_reviewCount reviews',
                      style: const TextStyle(color: CupertinoColors.systemGrey),
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
                    _buildStatItem('Favorites', '0'),
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
                  onTap: () {
                    // TODO implement favourites 
                  },
                ),
                _buildMenuItem(
                  icon: CupertinoIcons.star,
                  title: 'My Reviews',
                  onTap: () {
                    // TODO implement user reviews
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
                    // Show about dialog
                  },
                ),
                _buildMenuItem(
                  icon: CupertinoIcons.refresh_circled,
                  title: 'Reset App (Debug)',
                  onTap: () {
                    _showResetDialog();
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

  void _showSignInDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Sign In'),
        content: const Text(
          'Enter your username to personalize your experience.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Sign In'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _showResetDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Reset App'),
        content: const Text(
          'This will clear all app data and restart the onboarding process. This action cannot be undone.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Reset'),
            onPressed: () {
              Navigator.of(context).pop();
              _resetApp();
            },
          ),
        ],
      ),
    );
  }

  void _resetApp() async {
    await OnboardingController.resetOnboarding();

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        CupertinoPageRoute(builder: (context) => const NameInputPage()),
        (route) => false,
      );
    }
  }
}
