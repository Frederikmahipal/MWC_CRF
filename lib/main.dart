import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'core/app_settings.dart';
import 'core/app_state.dart';
import 'core/theme_controller.dart';
import 'core/onboarding_controller.dart';
import 'navigation/main_navigation.dart';
import 'pages/onboarding/name_input_page.dart';
import 'services/firestore_service.dart';

void main() {
  runApp(const CopenhagenRestaurantFinder());
}

class CopenhagenRestaurantFinder extends StatelessWidget {
  const CopenhagenRestaurantFinder({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppState()),
        ChangeNotifierProvider(create: (context) => ThemeController()),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeController, child) {
          return CupertinoApp(
            debugShowCheckedModeBanner: false,
            title: AppSettings.appName,
            theme: CupertinoThemeData(
              primaryColor: AppSettings.primaryColor,
              brightness: themeController.brightness,
            ),
            home: const AppInitializer(),
          );
        },
      ),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isLoading = true;
  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await FirestoreService.initialize();
    } catch (e) {
      print('Firebase initialization error: $e');
    }


    final themeController = Provider.of<ThemeController>(
      context,
      listen: false,
    );
    await themeController.initialize();

    final isCompleted = await OnboardingController.isOnboardingCompleted();

    setState(() {
      _showOnboarding = !isCompleted;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const CupertinoPageScaffold(
        child: Center(child: CupertinoActivityIndicator()),
      );
    }

    return _showOnboarding ? const NameInputPage() : const MainNavigation();
  }
}
