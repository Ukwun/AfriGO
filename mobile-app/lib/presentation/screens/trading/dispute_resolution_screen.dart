import 'package:flutter/material.dart';

class DisputeResolutionScreen extends StatelessWidget {
  final String tradeId;
  const DisputeResolutionScreen({Key? key, required this.tradeId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dispute Resolution')),
      body: Center(child: Text('Dispute: $tradeId')),
    );
  }
}
