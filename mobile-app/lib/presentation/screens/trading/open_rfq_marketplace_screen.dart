import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OpenRfqMarketplaceScreen extends StatelessWidget {
  const OpenRfqMarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final query = FirebaseFirestore.instance
        .collection('rfqs')
        .where('status', isEqualTo: 'open')
        .limit(100);
    return Scaffold(
      appBar: AppBar(title: const Text('Open buyer RFQs')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Open RFQs could not be refreshed from Firebase.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final records = snapshot.data?.docs ?? const [];
          if (records.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.request_quote_outlined, size: 52),
                  SizedBox(height: 14),
                  Text(
                    'No open buyer RFQs',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'New verified purchasing requests will appear here in real time.',
                    textAlign: TextAlign.center,
                  ),
                ]),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final document = records[index];
              final rfq = document.data();
              return Card(
                child: ListTile(
                  onTap: () =>
                      context.push('/rfqs/detail/${document.id}'),
                  leading: const Icon(Icons.request_quote_outlined),
                  title: Text(
                    (rfq['productCategory'] ??
                            rfq['commodity'] ??
                            'Request for quote')
                        .toString(),
                  ),
                  subtitle: Text(
                    '${rfq['quantity'] ?? 0} ${rfq['quantityUnit'] ?? rfq['unit'] ?? ''} · ${rfq['destination'] ?? 'Destination not specified'}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    tooltip: 'Submit offer',
                    onPressed: () => context.push(
                      '/trading/submit-bid/${document.id}',
                    ),
                    icon: const Icon(Icons.send_outlined),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
