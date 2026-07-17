import 'package:flutter/material.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String tradeId;
  const OrderTrackingScreen({super.key, required this.tradeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Tracking')),
      body: Center(child: Text('Tracking: $tradeId')),
    );
  }
}
