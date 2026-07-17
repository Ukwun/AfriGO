import 'package:flutter/material.dart';

class SubmitBidScreen extends StatelessWidget {
  final String rfqId;
  const SubmitBidScreen({super.key, required this.rfqId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit Bid')),
      body: Center(child: Text('Submit Bid for: $rfqId')),
    );
  }
}
