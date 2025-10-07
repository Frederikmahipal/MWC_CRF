import 'package:flutter/cupertino.dart';
import '../../core/app_settings.dart';

class LoadingMessageWidget extends StatelessWidget {
  const LoadingMessageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppSettings.getPrimaryColor(context),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              CupertinoIcons.chat_bubble_2,
              color: CupertinoColors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppSettings.getSurfaceColor(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppSettings.getBorderColor(context),
                width: 1,
              ),
            ),
            child: const CupertinoActivityIndicator(),
          ),
        ],
      ),
    );
  }
}
