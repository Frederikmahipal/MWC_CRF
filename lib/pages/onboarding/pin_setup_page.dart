import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_settings.dart';
import '../../core/app_state.dart';
import '../../services/pin_auth_service.dart';
import '../../services/auth_service.dart';
import '../../repositories/remote/firestore_service.dart';
import '../../navigation/main_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PinSetupPage extends StatefulWidget {
  const PinSetupPage({super.key});

  @override
  State<PinSetupPage> createState() => _PinSetupPageState();
}

class _PinSetupPageState extends State<PinSetupPage> {
  String _pin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  bool _isLoading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppSettings.getBackgroundColor(context),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSettings.defaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isConfirming ? 'Confirm Your PIN' : 'Create Your PIN',
                style: CupertinoTheme.of(context).textTheme.navTitleTextStyle
                    .copyWith(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                _isConfirming
                    ? 'Enter your PIN again to confirm'
                    : 'Choose a 4-6 digit PIN for quick access',
                style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                  color: AppSettings.getSecondaryTextColor(context),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: AppSettings.getSurfaceColor(context),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppSettings.getBorderColor(context),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (index) {
                    final isFilled = index < _pin.length;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: isFilled
                            ? AppSettings.getPrimaryColor(context)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isFilled
                              ? AppSettings.getPrimaryColor(context)
                              : AppSettings.getSecondaryTextColor(context),
                          width: 2,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 32),
              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: AppSettings.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppSettings.errorColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: AppSettings.errorColor,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: List.generate(12, (index) {
                    if (index == 9) {
                      return const SizedBox.shrink();
                    } else if (index == 10) {
                      return _buildNumberButton('0');
                    } else if (index == 11) {
                      return _buildDeleteButton();
                    } else {
                      return _buildNumberButton('${index + 1}');
                    }
                  }),
                ),
              ),

              const SizedBox(height: 32),

              if (_pin.length >= 4)
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton.filled(
                    onPressed: _isLoading ? null : _handleContinue,
                    child: _isLoading
                        ? const CupertinoActivityIndicator()
                        : Text(_isConfirming ? 'Confirm PIN' : 'Continue'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberButton(String number) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => _addDigit(number),
      child: Container(
        decoration: BoxDecoration(
          color: AppSettings.getSurfaceColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppSettings.getBorderColor(context),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            number,
            style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: _deleteDigit,
      child: Container(
        decoration: BoxDecoration(
          color: AppSettings.getSurfaceColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppSettings.getBorderColor(context),
            width: 1,
          ),
        ),
        child: const Center(child: Icon(CupertinoIcons.delete_left, size: 24)),
      ),
    );
  }

  void _addDigit(String digit) {
    if (_pin.length < 6) {
      setState(() {
        _pin += digit;
        _error = null;
      });
    }
  }

  void _deleteDigit() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
        _error = null;
      });
    }
  }

  void _handleContinue() async {
    if (_pin.length < 4) return;

    if (!_isConfirming) {
      setState(() {
        _isConfirming = true;
        _confirmPin = _pin;
        _pin = '';
      });
    } else {
      if (_pin == _confirmPin) {
        await _setupPin();
      } else {
        setState(() {
          _error = 'PINs do not match. Please try again.';
          _isConfirming = false;
          _pin = '';
          _confirmPin = '';
        });
      }
    }
  }

  Future<void> _setupPin() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final success = await PinAuthService.setupPin(_pin);

      if (success) {
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getString('current_user_id');

        if (userId != null) {
          final userData = await FirestoreService.getUser(userId);
          if (userData != null) {
            await AuthService.setCurrentUser(userData);
          }
        }

        final appState = Provider.of<AppState>(context, listen: false);
        appState.setPinSetup(true);
        appState.setAuthenticated(true);
        if (mounted) {
          await _askAboutFaceID();
        }
      } else {
        setState(() {
          _error = 'Failed to setup PIN. Please try again.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'An error occurred. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _askAboutFaceID() async {
    final isBiometricAvailable = await PinAuthService.isBiometricAvailable();

    if (!isBiometricAvailable) {
      Navigator.of(context).pushAndRemoveUntil(
        CupertinoPageRoute(builder: (context) => const MainNavigation()),
        (route) => false,
      );
      return;
    }

    final hasPermission = await PinAuthService.isBiometricEnabled();

    if (hasPermission) {
      Navigator.of(context).pushAndRemoveUntil(
        CupertinoPageRoute(builder: (context) => const MainNavigation()),
        (route) => false,
      );
      return;
    }
    final biometricName = Platform.isIOS ? 'Face ID' : 'Biometric';
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CupertinoAlertDialog(
        title: Text('Enable $biometricName?'),
        content: Text(
          'You can use $biometricName for faster access to your account. You can always change this in settings.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Skip'),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushAndRemoveUntil(
                CupertinoPageRoute(
                  builder: (context) => const MainNavigation(),
                ),
                (route) => false,
              );
            },
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Enable'),
            onPressed: () async {
              Navigator.of(context).pop();
              await _enableFaceID();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _enableFaceID() async {
    try {
      final authSuccess =
          await PinAuthService.authenticateWithBiometricForSetup();
      if (authSuccess) {
        final success = await PinAuthService.enableBiometric();
        if (mounted) {
          if (success) {
            Navigator.of(context).pushAndRemoveUntil(
              CupertinoPageRoute(builder: (context) => const MainNavigation()),
              (route) => false,
            );
          } else {
            final biometricName = Platform.isIOS ? 'Face ID' : 'Biometric';
            showCupertinoDialog(
              context: context,
              builder: (context) => CupertinoAlertDialog(
                title: Text('$biometricName Setup Failed'),
                actions: [
                  CupertinoDialogAction(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushAndRemoveUntil(
                        CupertinoPageRoute(
                          builder: (context) => const MainNavigation(),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            );
          }
        }
      } else {
        if (mounted) {
          final biometricName = Platform.isIOS ? 'Face ID' : 'Biometric';
          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: Text('$biometricName Authentication Failed'),
              content: Text(
                '$biometricName authentication is required to enable this feature. You can still use your PIN.',
              ),
              actions: [
                CupertinoDialogAction(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushAndRemoveUntil(
                      CupertinoPageRoute(
                        builder: (context) => const MainNavigation(),
                      ),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          CupertinoPageRoute(builder: (context) => const MainNavigation()),
          (route) => false,
        );
      }
    }
  }
}
