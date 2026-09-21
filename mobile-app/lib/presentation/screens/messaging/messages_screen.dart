import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text('AfriGoOS'),
        actions: [IconButton(onPressed: () => context.push('/notifications'), icon: const Icon(Icons.notifications_none_rounded))],
      ),
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
                final visible = documents.where((document) {
                  final data = document.data();
                  final names = Map<String, dynamic>.from(data['participantNames'] as Map? ?? const {});
                  return '${names.values.join(' ')} ${data['lastMessage'] ?? ''}'.toLowerCase().contains(_query.toLowerCase().trim());
                }).toList(growable: false);
                if (visible.isEmpty && _query.trim().isEmpty) {
                  return const _MessageState(
                    icon: Icons.forum_outlined,
                    title: 'No conversations yet',
                    message:
                        'Open a marketplace lot and contact its supplier to begin a real conversation.',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
                  itemCount: visible.length + 1,
                  separatorBuilder: (_, index) => SizedBox(height: index == 0 ? 18 : 10),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Messages', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 16),
                        TextField(onChanged: (value) => setState(() => _query = value), decoration: InputDecoration(hintText: 'Search conversations', prefixIcon: const Icon(Icons.search_rounded), filled: true, fillColor: const Color(0xFFF2F8F4), border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none))),
                      ]);
                    }
                    if (visible.isEmpty) return const _MessageState(icon: Icons.search_off_rounded, title: 'No matching conversations', message: 'Try another name or message.');
                    final document = visible[index - 1];
                    final data = document.data();
                    final names = Map<String, dynamic>.from(
                        data['participantNames'] as Map? ?? const {});
                    final otherName = names.entries
                        .where((entry) => entry.key != user.uid)
                        .map((entry) => entry.value.toString())
                        .firstOrNull;
                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFFE1E7E3))),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFE3F2E9),
                          child: Text((otherName?.trim().isNotEmpty == true ? otherName! : 'A').substring(0, 1).toUpperCase(), style: const TextStyle(color: Color(0xFF00533D), fontWeight: FontWeight.w800)),
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
                        trailing: const Icon(Icons.chevron_right_rounded),
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
