import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/message_model.dart';
import '../../services/api_service.dart';

// Get messages in conversation provider
final messageProvider =
    FutureProvider.family.autoDispose<List<MessageModel>, String>(
  (ref, otherUserId) async {
    final apiService = ref.watch(apiServiceProvider);
    return apiService.getConversationMessages(otherUserId);
  },
);

// Unread count provider
final unreadCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getUnreadMessageCount();
});

class ChatScreen extends ConsumerStatefulWidget {
  final String otherUserId;
  final String otherUserName;
  final String? otherUserAvatar;

  const ChatScreen({
    Key? key,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserAvatar,
  }) : super(key: key);

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  late TextEditingController _messageController;
  late ScrollController _scrollController;
  bool _isSending = false;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _scrollController = ScrollController();
    _markConversationAsRead();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _markConversationAsRead() async {
    final apiService = ref.read(apiServiceProvider);
    try {
      await apiService.markConversationAsRead(widget.otherUserId);
      // Refresh unread count
      ref.refresh(unreadCountProvider);
    } catch (e) {
      print('Error marking as read: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(messageProvider(widget.otherUserId));

    return WillPopScope(
      onWillPop: () async {
        _markConversationAsRead();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.otherUserName),
              const SizedBox(height: 2),
              Text(
                'Online',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
          elevation: 1,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          actions: [
            IconButton(
              onPressed: () {
                // Call/video feature
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Call feature coming soon')),
                );
              },
              icon: const Icon(Icons.phone),
            ),
            PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'info',
                  child: Text('View Info'),
                ),
                const PopupMenuItem(
                  value: 'block',
                  child: Text('Block User'),
                ),
                const PopupMenuItem(
                  value: 'report',
                  child: Text('Report'),
                ),
              ],
              onSelected: (value) {
                if (value == 'info') {
                  // Show user info
                }
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Messages list
            Expanded(
              child: messagesAsync.when(
                data: (messages) => _buildMessagesList(messages),
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stack) => Center(
                  child: Text('Error: ${error.toString()}'),
                ),
              ),
            ),
            // Input area
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList(List<MessageModel> messages) {
    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No messages yet. Start the conversation!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    // Scroll to bottom after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isOwn =
            message.senderId == 'current-user-id'; // TODO: Get from auth

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildMessageBubble(message, isOwn),
        );
      },
    );
  }

  Widget _buildMessageBubble(MessageModel message, bool isOwn) {
    return Align(
      alignment: isOwn ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isOwn ? Colors.green[500] : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment:
              isOwn ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: isOwn ? Colors.white : Colors.black,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message.createdAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: isOwn ? Colors.white70 : Colors.grey[600],
                  ),
                ),
                if (isOwn) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead ? Icons.done_all : Icons.done,
                    size: 14,
                    color: Colors.white70,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        12,
        8,
        12,
        8 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Row(
        children: [
          // Attachment button
          IconButton(
            onPressed: () {
              // Open file picker
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Attachment feature coming soon')),
              );
            },
            icon: const Icon(Icons.attach_file),
            color: Colors.grey[600],
          ),
          // Message input
          Expanded(
            child: TextField(
              controller: _messageController,
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              onChanged: (value) {
                // Show typing indicator (TODO: implement with WebSocket)
                setState(() => _isTyping = value.isNotEmpty);
              },
            ),
          ),
          const SizedBox(width: 8),
          // Send button
          FloatingActionButton(
            onPressed: _messageController.text.isEmpty || _isSending
                ? null
                : () => _sendMessage(),
            mini: true,
            backgroundColor: _messageController.text.isEmpty
                ? Colors.grey[400]
                : Colors.green,
            child: const Icon(Icons.send, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty) return;

    setState(() => _isSending = true);

    try {
      final content = _messageController.text;
      _messageController.clear();

      final apiService = ref.read(apiServiceProvider);
      await apiService.sendMessage(
        recipientId: widget.otherUserId,
        content: content,
      );

      // Refresh messages
      ref.refresh(messageProvider(widget.otherUserId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending message: $e')),
        );
        _messageController.text = _messageController.text;
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
    );

    if (messageDate == today) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${dateTime.month}/${dateTime.day}';
    }
  }
}
