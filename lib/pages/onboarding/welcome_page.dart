import 'package:flutter/cupertino.dart';
import 'phone_input_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);

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

              const SizedBox(height: 60),
              CupertinoButton.filled(
                onPressed: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (context) => const PhoneInputPage(),
                    ),
                  );
                },
                child: const Text('Get Started'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
