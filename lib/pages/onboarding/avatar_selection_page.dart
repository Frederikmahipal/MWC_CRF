import 'package:flutter/cupertino.dart';
import '../../core/onboarding_controller.dart';
import '../../navigation/main_navigation.dart';

class AvatarSelectionPage extends StatefulWidget {
  final String firstName;
  final String lastName;

  const AvatarSelectionPage({
    super.key,
    required this.firstName,
    required this.lastName,
  });

  @override
  State<AvatarSelectionPage> createState() => _AvatarSelectionPageState();
}

class _AvatarSelectionPageState extends State<AvatarSelectionPage> {
  String? _selectedAvatar;

  // Food-related emoji options
  static const List<String> _avatarOptions = [
    '🍕',
    '🍔',
    '🍜',
    '🍝',
    '🍣',
    '🍱',
    '🌮',
    '🌯',
    '🥗',
    '🍲',
    '🥘',
    '🍛',
    '🍤',
    '🍙',
    '🍚',
    '🍞',
    '🥐',
    '🥖',
    '🧀',
    '🥞',
    '🧇',
    '🍳',
    '🥓',
    '🍖',
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Choose Avatar'),
        backgroundColor: CupertinoColors.systemBackground,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Welcome text
              Text(
                'Hi ${widget.firstName}! 👋',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Choose an avatar that represents you',
                style: TextStyle(
                  fontSize: 18,
                  color: CupertinoColors.systemGrey,
                ),
              ),

              const SizedBox(height: 40),

              // Avatar grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _avatarOptions.length,
                  itemBuilder: (context, index) {
                    final emoji = _avatarOptions[index];
                    final isSelected = _selectedAvatar == emoji;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedAvatar = emoji;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? CupertinoColors.systemBlue.withOpacity(0.1)
                              : CupertinoColors.systemGrey6,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? CupertinoColors.systemBlue
                                : CupertinoColors.systemGrey4,
                            width: isSelected ? 3 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 32),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Complete button
              SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  color: _selectedAvatar != null
                      ? CupertinoColors.systemBlue
                      : CupertinoColors.systemGrey3,
                  borderRadius: BorderRadius.circular(12),
                  onPressed: _selectedAvatar != null ? _complete : null,
                  child: const Text(
                    'Complete Setup',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _complete() async {
    // Generate user ID and save onboarding data
    final userId = OnboardingController.generateUserId();

    await OnboardingController.completeOnboarding(
      userId: userId,
      firstName: widget.firstName,
      lastName: widget.lastName,
      avatarEmoji: _selectedAvatar!,
    );

    // Show success message and navigate to main app
    if (mounted) {
      showCupertinoDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Welcome!'),
          content: Text(
            'Hi ${widget.firstName} ${widget.lastName} ${_selectedAvatar}!\n\nYour profile has been created successfully.',
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('Get Started'),
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to main app
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
}
