import 'package:flutter/material.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String tradeId;
  const OrderTrackingScreen({Key? key, required this.tradeId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Tracking')),
      body: Center(child: Text('Tracking: $tradeId')),
    );
  }
}
