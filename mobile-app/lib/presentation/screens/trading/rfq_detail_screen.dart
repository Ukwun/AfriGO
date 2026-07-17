import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RfqDetailScreen extends StatelessWidget {
  const RfqDetailScreen({super.key, required this.rfqId});
  final String rfqId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RFQ details')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('rfqs')
            .doc(rfqId)
            .snapshots(),
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
                  'This RFQ could not be refreshed from Firebase.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final record = snapshot.data?.data();
          if (record == null) {
            return const Center(child: Text('RFQ not found.'));
          }
          final status = (record['status'] ?? 'draft').toString();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (record['productCategory'] ??
                                record['commodity'] ??
                                'Request for quote')
                            .toString(),
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 10),
                      Chip(label: Text(status.toUpperCase())),
                    ],
                  ),
                ),
              ),
              _detail(context, 'Specification',
                  record['productDescription'] ?? record['description']),
              _detail(context, 'Quantity',
                  '${record['quantity'] ?? 0} ${record['quantityUnit'] ?? record['unit'] ?? ''}'),
              _detail(context, 'Destination', record['destination']),
              _detail(context, 'Target budget', record['targetBudget']),
              _detail(
                context,
                'Offers received',
                (record['submittedBids'] as List?)?.length ??
                    record['offerCount'] ??
                    0,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _detail(BuildContext context, String label, dynamic value) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 6),
              Text(value?.toString().trim().isNotEmpty == true
                  ? value.toString()
                  : 'Not specified'),
            ],
          ),
        ),
      );
}
