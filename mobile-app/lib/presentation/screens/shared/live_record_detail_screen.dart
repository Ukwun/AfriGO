import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LiveRecordDetailScreen extends StatelessWidget {
  const LiveRecordDetailScreen({
    super.key,
    required this.resource,
    required this.recordId,
    required this.title,
  });

  final String resource;
  final String recordId;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection(resource)
            .doc(recordId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text('This record could not be refreshed from Firebase.'),
            );
          }
          final record = snapshot.data?.data();
          if (record == null) {
            return const Center(child: Text('Record not found.'));
          }
          final hidden = {
            'participantIds',
            'ownerId',
            'buyerId',
            'supplierId',
            'exporterId',
          };
          final entries = record.entries
              .where((entry) =>
                  !hidden.contains(entry.key) &&
                  entry.value != null &&
                  entry.value is! List &&
                  entry.value is! Map)
              .toList();
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final entry = entries[index];
              return Card(
                child: ListTile(
                  title: Text(_label(entry.key)),
                  subtitle: Text(_value(entry.value)),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _label(String input) => input
      .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
      .replaceAll('_', ' ')
      .trim()
      .split(' ')
      .map((part) =>
          part.isEmpty ? part : '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');

  String _value(dynamic value) {
    if (value is Timestamp) {
      final date = value.toDate().toLocal();
      return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    if (value is bool) return value ? 'Yes' : 'No';
    return value.toString();
  }
}
