import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../widgets/animated_button.dart';
import '../../widgets/modern_card.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;
  final String userName;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.userName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _messageController;
  late AnimationController _sendButtonAnimationController;
  final List<Map<String, dynamic>> _messages = [
    {
      'id': '1',
      'sender': 'other',
      'message':
          'Hi, I\'m interested in your cocoa beans. Can you provide more details?',
      'timestamp': '10:30 AM',
    },
    {
      'id': '2',
      'sender': 'me',
      'message':
          'Sure! These are premium quality cocoa beans from Ghana. FOB price is \$2,500 per 500kg.',
      'timestamp': '10:32 AM',
    },
    {
      'id': '3',
      'sender': 'other',
      'message':
          'Great! What about shipping timeline and minimum order quantity?',
      'timestamp': '10:35 AM',
    },
    {
      'id': '4',
      'sender': 'me',
      'message':
          'MOQ is 500kg. Shipping can be arranged within 2-3 weeks after payment.',
      'timestamp': '10:37 AM',
    },
  ];

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _sendButtonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _sendButtonAnimationController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.isEmpty) return;

    // Trigger button animation
    _sendButtonAnimationController.forward().then((_) {
      _sendButtonAnimationController.reverse();
    });

    final now = DateTime.now();
    final timeString = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';

    setState(() {
      _messages.add({
        'id': (_messages.length + 1).toString(),
        'sender': 'me',
        'message': _messageController.text,
        'timestamp': timeString,
      });
      _messageController.clear();
    });

    // Simulate reply after delay with real-time responsiveness
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _messages.add({
            'id': (_messages.length + 1).toString(),
            'sender': 'other',
            'message': 'Thanks for the info! Let me discuss with my team.',
            'timestamp': timeString,
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AfrigoColors.bgLight,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.userName, style: AfrigoTypography.soraHeading6),
            Text(
              'Active now',
              style: AfrigoTypography.bodySmall.copyWith(
                color: AfrigoColors.textSecondary,
              ),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AfrigoSpacing.lg),
            child: Center(
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AfrigoColors.bgLightAlt,
                  borderRadius: BorderRadius.circular(
                    AfriBorderRadius.lg,
                  ),
                ),
                child: IconButton(
                  icon: const Icon(Icons.call_outlined),
                  onPressed: () {},
                  color: AfrigoColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(AfrigoSpacing.lg),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final messageIndex = _messages.length - 1 - index;
                final message = _messages[messageIndex];
                final isMine = message['sender'] == 'me';

                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: AfrigoSpacing.md,
                  ),
                  child: Row(
                    mainAxisAlignment: isMine
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      if (!isMine) ...[
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AfrigoColors.bgLightAlt,
                            borderRadius: BorderRadius.circular(
                              AfriBorderRadius.full,
                            ),
                          ),
                          child: const Center(
                            child: Icon(Icons.person_outline),
                          ),
                        ),
                        const SizedBox(width: AfrigoSpacing.md),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: isMine
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AfrigoSpacing.lg,
                                vertical: AfrigoSpacing.md,
                              ),
                              decoration: BoxDecoration(
                                color: isMine
                                    ? AfrigoColors.primary
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(
                                  AfriBorderRadius.lg,
                                ),
                                border: !isMine
                                    ? Border.all(
                                        color: AfrigoColors.borderLight,
                                      )
                                    : null,
                                boxShadow:
                                    !isMine ? AfrigoElevation.shadow1 : [],
                              ),
                              child: Text(
                                message['message'],
                                style: AfrigoTypography.interBody1.copyWith(
                                  color: isMine
                                      ? Colors.white
                                      : AfrigoColors.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              message['timestamp'],
                              style: AfrigoTypography.caption.copyWith(
                                color: AfrigoColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isMine) ...[
                        const SizedBox(width: AfrigoSpacing.md),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AfrigoColors.primary,
                            borderRadius: BorderRadius.circular(
                              AfriBorderRadius.full,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(AfrigoSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type message...',
                      prefixIcon: const Icon(Icons.emoji_emotions_outlined),
                      suffixIcon: const Icon(Icons.attach_file_outlined),
                      filled: true,
                      fillColor: AfrigoColors.bgLightAlt,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AfriBorderRadius.full,
                        ),
                        borderSide: const BorderSide(
                          color: Colors.transparent,
                        ),
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: AfrigoSpacing.md),
                // Animated Send Button - Real-time responsiveness with 200ms scale animation
                ScaleTransition(
                  scale: Tween(begin: 1.0, end: 0.92).animate(
                    CurvedAnimation(
                      parent: _sendButtonAnimationController,
                      curve: Curves.easeInOutCubic,
                    ),
                  ),
                  child: GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AfrigoColors.primary,
                        borderRadius: BorderRadius.circular(
                          AfriBorderRadius.full,
                        ),
                        boxShadow: AfrigoElevation.shadow2,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.send_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
