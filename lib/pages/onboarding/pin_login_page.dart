import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/app_settings.dart';
import '../../core/app_state.dart';
import '../../services/pin_auth_service.dart';
import '../../services/auth_service.dart';
import '../../repositories/remote/firestore_service.dart';
import '../../navigation/main_navigation.dart';

class PinLoginPage extends StatefulWidget {
  final bool isAppReopen;

  const PinLoginPage({super.key, this.isAppReopen = false});

  @override
  State<PinLoginPage> createState() => _PinLoginPageState();
}

class _PinLoginPageState extends State<PinLoginPage> {
  String _pin = '';
  bool _isLoading = false;
  String? _error;
  int _remainingAttempts = 5;

  @override
  void initState() {
    super.initState();
    _checkBiometricAndAttempts();
  }

  Future<void> _checkBiometricAndAttempts() async {
    final remainingAttempts = await PinAuthService.getRemainingAttempts();
    setState(() {
      _remainingAttempts = remainingAttempts;
    });

    if (widget.isAppReopen) {
      final biometricEnabled = await PinAuthService.isBiometricEnabled();
      if (biometricEnabled) {
        await _tryBiometricAuth();
      }
    }
  }

  Future<void> _tryBiometricAuth() async {
    final success = await PinAuthService.authenticateWithBiometric();
    if (success && mounted) {
      _navigateToMainApp();
    }
  }

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
                'Enter Your PIN',
                style: CupertinoTheme.of(context).textTheme.navTitleTextStyle
                    .copyWith(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                Platform.isIOS 
                    ? 'Use your PIN or Face ID to access your account'
                    : 'Use your PIN or Biometric to access your account',
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

              if (_remainingAttempts < 5)
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppSettings.warningColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Remaining attempts: $_remainingAttempts',
                    style: TextStyle(
                      color: AppSettings.warningColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
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
                      return widget.isAppReopen
                          ? _buildBiometricButton()
                          : _buildNumberButton('9');
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

              CupertinoButton(
                onPressed: _showForgotPinDialog,
                child: Text(
                  'Forgot PIN?',
                  style: TextStyle(
                    color: AppSettings.getSecondaryTextColor(context),
                    fontSize: 16,
                  ),
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
      onPressed: _isLoading ? null : () => _addDigit(number),
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

  Widget _buildBiometricButton() {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: _isLoading ? null : _tryBiometricAuth,
      child: Container(
        decoration: BoxDecoration(
          color: AppSettings.getSurfaceColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppSettings.getBorderColor(context),
            width: 1,
          ),
        ),
        child: const Center(
          child: Icon(CupertinoIcons.person_circle, size: 24),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: _isLoading ? null : _deleteDigit,
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

      if (_pin.length >= 4) {
        _validatePin();
      }
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

  Future<void> _validatePin() async {
    if (_pin.length < 4) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final success = await PinAuthService.validatePin(_pin);

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
        appState.setAuthenticated(true);

        _navigateToMainApp();
      } else {
        final remainingAttempts = await PinAuthService.getRemainingAttempts();
        setState(() {
          _error = 'Incorrect PIN. Please try again.';
          _pin = '';
          _remainingAttempts = remainingAttempts;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'An error occurred. Please try again.';
        _pin = '';
        _isLoading = false;
      });
    }
  }

  void _navigateToMainApp() {
    Navigator.of(context).pushAndRemoveUntil(
      CupertinoPageRoute(builder: (context) => const MainNavigation()),
      (route) => false,
    );
  }

  void _showForgotPinDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Forgot PIN?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text(Platform.isIOS ? 'Try Face ID' : 'Try Biometric'),
            onPressed: () {
              Navigator.of(context).pop();
              _tryBiometricAuth();
            },
          ),
        ],
      ),
    );
  }
}
