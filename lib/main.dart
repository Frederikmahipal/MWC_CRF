import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'core/app_settings.dart';
import 'core/app_state.dart';
import 'core/theme_controller.dart';
import 'navigation/main_navigation.dart';
import 'pages/onboarding/welcome_page.dart';
import 'services/user_detection_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

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
              scaffoldBackgroundColor: AppSettings.getBackgroundColor(context),
              barBackgroundColor: AppSettings.getSurfaceColor(context),
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
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CupertinoPageScaffold(
            child: Center(child: CupertinoActivityIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const OnboardingWrapper();
        } else {
          return const WelcomePage();
        }
      },
    );
  }
}

class OnboardingWrapper extends StatelessWidget {
  const OnboardingWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkUserStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CupertinoPageScaffold(
            child: Center(child: CupertinoActivityIndicator()),
          );
        }

        if (snapshot.data == true) {
          return const MainNavigation();
        } else {
          return const WelcomePage();
        }
      },
    );
  }

  Future<bool> _checkUserStatus() async {
    final userExists = await UserDetectionService.isUserInFirestore();
    return userExists;
  }
}
