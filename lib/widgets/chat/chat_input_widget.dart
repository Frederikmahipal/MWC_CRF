import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/app_settings.dart';

class ChatInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSend;
  final Function(File)? onImageSelected;

  const ChatInputWidget({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.onSend,
    this.onImageSelected,
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
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: isLoading ? null : () => _showImagePicker(context),
            child: Icon(
              CupertinoIcons.camera,
              color: isLoading
                  ? AppSettings.getSecondaryTextColor(context)
                  : AppSettings.getPrimaryColor(context),
            ),
          ),
          const SizedBox(width: 8),
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

  Future<void> _showImagePicker(BuildContext context) async {
    final source = await showCupertinoModalPopup<ImageSource>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            child: const Text('Take Photo'),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            child: const Text('Choose from Gallery'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );

    if (source == null || onImageSelected == null) return;

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);
      if (image != null) {
        onImageSelected!(File(image.path));
      }
    } catch (e) {
      // Error handled by parent
    }
  }
}
