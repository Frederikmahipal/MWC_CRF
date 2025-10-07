import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../core/app_settings.dart';
import '../controllers/chat_controller.dart';
import '../models/restaurant.dart';
import '../widgets/chat/chat_message_widget.dart';
import '../widgets/chat/chat_input_widget.dart';
import '../widgets/chat/loading_message_widget.dart';
import 'restaurants/restaurant_main_page.dart';

class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late ChatController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ChatController();
    _controller.addListener(_onControllerUpdate);
  }

  void _onControllerUpdate() {
    _scrollToBottom();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _messageController.clear();
    _controller.sendMessage(message);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _navigateToRestaurant(Restaurant restaurant) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => RestaurantMainPage(restaurant: restaurant),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ChatController>.value(
      value: _controller,
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Text('Restaurant Finder'),
          backgroundColor: AppSettings.getBackgroundColor(context),
        ),
        child: SafeArea(
          child: Consumer<ChatController>(
            builder: (context, controller, child) {
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount:
                          controller.messages.length +
                          (controller.isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == controller.messages.length &&
                            controller.isLoading) {
                          return const LoadingMessageWidget();
                        }
                        return ChatMessageWidget(
                          message: controller.messages[index],
                          onRestaurantTap: () {
                            final message = controller.messages[index];
                            if (message.recommendedRestaurants != null &&
                                message.recommendedRestaurants!.isNotEmpty) {
                              _navigateToRestaurant(
                                message.recommendedRestaurants!.first,
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
                  ChatInputWidget(
                    controller: _messageController,
                    isLoading: controller.isLoading,
                    onSend: _sendMessage,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
