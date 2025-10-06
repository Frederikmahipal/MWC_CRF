import 'package:flutter/cupertino.dart';
import '../../core/app_settings.dart';

class ChatInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSend;

  const ChatInputWidget({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppSettings.getSurfaceColor(context),
        border: Border(
          top: BorderSide(color: AppSettings.getBorderColor(context), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: CupertinoTextField(
              controller: controller,
              placeholder: 'Ask about restaurants...',
              decoration: BoxDecoration(
                color: AppSettings.getBackgroundColor(context),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppSettings.getBorderColor(context),
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 8),
          CupertinoButton.filled(
            onPressed: isLoading ? null : onSend,
            child: const Icon(CupertinoIcons.paperplane_fill),
          ),
        ],
      ),
    );
  }
}
