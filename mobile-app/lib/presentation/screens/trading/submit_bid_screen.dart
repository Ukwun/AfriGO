import 'package:flutter/material.dart';

class SubmitBidScreen extends StatelessWidget {
  final String rfqId;
  const SubmitBidScreen({Key? key, required this.rfqId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit Bid')),
      body: Center(child: Text('Submit Bid for: $rfqId')),
    );
  }
}
