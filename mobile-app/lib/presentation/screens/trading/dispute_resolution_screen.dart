import 'package:flutter/material.dart';

class DisputeResolutionScreen extends StatelessWidget {
  final String tradeId;
  const DisputeResolutionScreen({super.key, required this.tradeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dispute Resolution')),
      body: Center(child: Text('Dispute: $tradeId')),
    );
  }
}
