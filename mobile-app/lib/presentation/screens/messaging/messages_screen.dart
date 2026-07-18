import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: user == null
          ? const Center(child: Text('Sign in to view conversations.'))
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('conversations')
                  .where('participantIds', arrayContains: user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const _MessageState(
                    icon: Icons.cloud_off_outlined,
                    title: 'Messages could not be loaded',
                    message: 'Check your connection and try again.',
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final documents = snapshot.data!.docs.toList()
                  ..sort((a, b) => _time(b.data()['updatedAt'])
                      .compareTo(_time(a.data()['updatedAt'])));
                if (documents.isEmpty) {
                  return const _MessageState(
                    icon: Icons.forum_outlined,
                    title: 'No conversations yet',
                    message:
                        'Open a marketplace lot and contact its supplier to begin a real conversation.',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: documents.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final document = documents[index];
                    final data = document.data();
                    final names = Map<String, dynamic>.from(
                        data['participantNames'] as Map? ?? const {});
                    final otherName = names.entries
                        .where((entry) => entry.key != user.uid)
                        .map((entry) => entry.value.toString())
                        .firstOrNull;
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.person_outline),
                        ),
                        title: Text(otherName?.trim().isNotEmpty == true
                            ? otherName!
                            : 'AfriGO participant'),
                        subtitle: Text(
                          (data['lastMessage'] ?? 'Conversation started')
                              .toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/messages/${document.id}'),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  static int _time(dynamic value) =>
      value is Timestamp ? value.millisecondsSinceEpoch : 0;
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 52),
              const SizedBox(height: 14),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
}
