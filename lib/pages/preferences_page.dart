import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../core/app_settings.dart';
import '../core/theme_controller.dart';
import '../services/pin_auth_service.dart';
import '../services/auth_service.dart';

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key});

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  bool _isFaceIDEnabled = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFaceIDStatus();
  }

  Future<void> _loadFaceIDStatus() async {
    final isEnabled = await PinAuthService.isBiometricEnabled();
    if (mounted) {
      setState(() {
        _isFaceIDEnabled = isEnabled;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Preferences'),
        backgroundColor: AppSettings.getBackgroundColor(context),
      ),
      child: SafeArea(
        child: Container(
          color: AppSettings.getBackgroundColor(context),
          child: ListView(
            children: [
              Container(
                margin: const EdgeInsets.all(16),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: const Text(
                        'Appearance',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    Consumer<ThemeController>(
                      builder: (context, themeController, child) {
                        return CupertinoListTile(
                          title: const Text('Theme'),
                          subtitle: Text(themeController.themeModeName),
                          trailing: const Icon(CupertinoIcons.chevron_right),
                          onTap: () {
                            _showThemeSelector(context, themeController);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Security Section
              Container(
                margin: const EdgeInsets.all(16),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: const Text(
                        'Security',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    CupertinoListTile(
                      title: const Text('Face ID Login'),
                      subtitle: Text(
                        _isFaceIDEnabled
                            ? 'Use Face ID for quick access'
                            : 'Enter PIN manually to sign in',
                      ),
                      trailing: _isLoading
                          ? const CupertinoActivityIndicator()
                          : CupertinoSwitch(
                              value: _isFaceIDEnabled,
                              onChanged: _isLoading
                                  ? null
                                  : (value) {
                                      if (value) {
                                        _enableFaceID();
                                      } else {
                                        _disableFaceID();
                                      }
                                    },
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showThemeSelector(
    BuildContext context,
    ThemeController themeController,
  ) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Choose Theme'),
        actions: [
          CupertinoActionSheetAction(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Light'),
                if (themeController.themeMode == AppThemeMode.light)
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(CupertinoIcons.checkmark, size: 16),
                  ),
              ],
            ),
            onPressed: () {
              themeController.setThemeMode(AppThemeMode.light);
              Navigator.of(context).pop();
            },
          ),
          CupertinoActionSheetAction(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Dark'),
                if (themeController.themeMode == AppThemeMode.dark)
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(CupertinoIcons.checkmark, size: 16),
                  ),
              ],
            ),
            onPressed: () {
              themeController.setThemeMode(AppThemeMode.dark);
              Navigator.of(context).pop();
            },
          ),
          CupertinoActionSheetAction(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('System'),
                if (themeController.themeMode == AppThemeMode.system)
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(CupertinoIcons.checkmark, size: 16),
                  ),
              ],
            ),
            onPressed: () {
              themeController.setThemeMode(AppThemeMode.system);
              Navigator.of(context).pop();
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  void _enableFaceID() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authSuccess =
          await PinAuthService.authenticateWithBiometricForSetup();

      if (authSuccess) {
        final success = await PinAuthService.enableBiometric();

        if (success) {
          setState(() {
            _isFaceIDEnabled = true;
          });
        } else {
          _showError('Failed to enable Face ID. Please try again.');
        }
      } else {
        _showError('Face ID authentication failed. Please try again.');
      }
    } catch (e) {
      _showError('Error enabling Face ID: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _disableFaceID() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await PinAuthService.disableBiometric();

      if (success) {
        setState(() {
          _isFaceIDEnabled = false;
        });
      } else {
        _showError('Failed to disable Face ID. Please try again.');
      }
    } catch (e) {
      _showError('Error disabling Face ID: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
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
