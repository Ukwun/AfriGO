import 'package:flutter/material.dart';
import '../../../config/colors.dart';
import '../../widgets/motion_system.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final _messages = [
    _ConversationPreview(
      name: 'Global Traders Ltd',
      lastMessage: 'Can you deliver by May 15th?',
      timestamp: '2 hours ago',
      unread: 3,
      avatar: '🏢',
    ),
    _ConversationPreview(
      name: 'Premium Cocoa Co',
      lastMessage: 'Shipment is confirmed for departure',
      timestamp: '5 hours ago',
      unread: 0,
      avatar: '🌳',
    ),
    _ConversationPreview(
      name: 'Logistics Partner',
      lastMessage: 'Tracking updated - package in transit',
      timestamp: 'Yesterday',
      unread: 0,
      avatar: '🚚',
    ),
    _ConversationPreview(
      name: 'Payment Department',
      lastMessage: 'Invoice INV-2026-001 processed',
      timestamp: 'Yesterday',
      unread: 0,
      avatar: '💳',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final msg = _messages[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: SlideInTransition(
              child: _buildConversationTile(msg),
            ),
          );
        },
      ),
    );
  }

  Widget _buildConversationTile(_ConversationPreview conversation) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.borderDefault),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primaryGreenLighter,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              conversation.avatar,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        title: Text(
          conversation.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          conversation.lastMessage,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              conversation.timestamp,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            if (conversation.unread > 0)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  conversation.unread.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Opening chat with ${conversation.name}')),
          );
        },
      ),
    );
  }
}

class _ConversationPreview {
  final String name;
  final String lastMessage;
  final String timestamp;
  final int unread;
  final String avatar;

  _ConversationPreview({
    required this.name,
    required this.lastMessage,
    required this.timestamp,
    required this.unread,
    required this.avatar,
  });
}
