import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../config/theme.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.userName,
  });

  final String conversationId;
  final String userName;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  bool _sending = false;

  CollectionReference<Map<String, dynamic>> get _messages =>
      FirebaseFirestore.instance
          .collection('conversations')
          .doc(widget.conversationId)
          .collection('messages');

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final user = FirebaseAuth.instance.currentUser;
    final text = _messageController.text.trim();
    if (user == null || text.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await FirebaseFirestore.instance
          .collection('conversations')
          .doc(widget.conversationId)
          .set({
        'participantIds': FieldValue.arrayUnion([user.uid]),
        'lastMessage': text,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      await _messages.add({
        'conversationId': widget.conversationId,
        'senderId': user.uid,
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
      });
      _messageController.clear();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Message was not sent: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      backgroundColor: AfrigoColors.bgLight,
      appBar: AppBar(title: Text(widget.userName)),
      body: Column(children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _messages
                .orderBy('createdAt', descending: true)
                .limit(100)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                    child: Text('Could not load messages: ${snapshot.error}'));
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) {
                return const Center(
                    child: Text('No messages yet. Start the conversation.'));
              }
              return ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data();
                  final mine = data['senderId'] == userId;
                  final timestamp = data['createdAt'];
                  final time = timestamp is Timestamp
                      ? TimeOfDay.fromDateTime(timestamp.toDate())
                          .format(context)
                      : 'Sending…';
                  return Align(
                    alignment:
                        mine ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 520),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 11),
                      decoration: BoxDecoration(
                        color: mine ? AfrigoColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${data['text'] ?? ''}',
                                style: TextStyle(
                                    color: mine
                                        ? Colors.white
                                        : AfrigoColors.textPrimary)),
                            const SizedBox(height: 4),
                            Text(time,
                                style: TextStyle(
                                    fontSize: 10,
                                    color: mine
                                        ? Colors.white70
                                        : AfrigoColors.textTertiary)),
                          ]),
                    ),
                  );
                },
              );
            },
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Expanded(
                  child: TextField(
                controller: _messageController,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _sendMessage(),
                decoration: const InputDecoration(hintText: 'Type a message…'),
              )),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _sending ? null : _sendMessage,
                icon: _sending
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.send_rounded),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}
