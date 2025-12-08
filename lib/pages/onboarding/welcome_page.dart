import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crf/pages/onboarding/name_input_page.dart';
import 'package:crf/pages/onboarding/pin_setup_page.dart';
import 'package:crf/pages/onboarding/pin_login_page.dart';
import '../../services/pin_auth_service.dart';
import '../../services/auth_service.dart';
import '../../models/user.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final TextEditingController _countryCodeController = TextEditingController(
    text: '+45',
  );
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _countryCodeController.dispose();
    super.dispose();
  }

  void _continue() {
    final phoneNumber = _countryCodeController.text + _phoneController.text;

    if (phoneNumber.length < 8) {
      _showError('Please enter a valid phone number');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    _checkUserExists(phoneNumber);
  }

  Future<void> _checkUserExists(String phoneNumber) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      if (mounted) {
        if (querySnapshot.docs.isNotEmpty) {
          final userDoc = querySnapshot.docs.first;
          final userId = userDoc.id;
          final userData = userDoc.data();
          final user = User.fromMap(userData, userId);
          await AuthService.loadUserForLogin(user);
          final pinLoaded = await PinAuthService.loadPinFromFirestore(userId);
          if (!pinLoaded) {
            Navigator.of(context).pushAndRemoveUntil(
              CupertinoPageRoute(builder: (context) => const PinSetupPage()),
              (route) => false,
            );
          } else {
            Navigator.of(context).pushAndRemoveUntil(
              CupertinoPageRoute(
                builder: (context) => const PinLoginPage(isAppReopen: false),
              ),
              (route) => false,
            );
          }
        } else {
          Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (context) => NameInputPage(phoneNumber: phoneNumber),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showError('Error checking user: $e');
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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                CupertinoIcons.house,
                size: 80,
                color: CupertinoColors.systemBlue,
              ),

              const SizedBox(height: 40),
              Text(
                'Welcome to CRF',
                style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),
              Text(
                'Discover amazing restaurants in Copenhagen',
                style: CupertinoTheme.of(context).textTheme.textStyle,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),
              Text(
                'Enter your phone number',
                style: CupertinoTheme.of(
                  context,
                ).textTheme.navTitleTextStyle.copyWith(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'We\'ll check if you already have an account',
                style: CupertinoTheme.of(context).textTheme.textStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: CupertinoTextField(
                      controller: _countryCodeController,
                      keyboardType: TextInputType.phone,
                      decoration: BoxDecoration(
                        border: Border.all(color: CupertinoColors.systemGrey4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CupertinoTextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      placeholder: 'Phone number',
                      decoration: BoxDecoration(
                        border: Border.all(color: CupertinoColors.systemGrey4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              CupertinoButton.filled(
                onPressed: _isLoading ? null : _continue,
                child: _isLoading
                    ? const CupertinoActivityIndicator()
                    : const Text('Get Started'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
