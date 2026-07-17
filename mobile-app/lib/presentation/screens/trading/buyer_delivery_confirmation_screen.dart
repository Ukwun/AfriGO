import 'package:flutter/material.dart';

class BuyerDeliveryConfirmationScreen extends StatelessWidget {
  final String tradeId;
  const BuyerDeliveryConfirmationScreen({super.key, required this.tradeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Delivery Confirmation')),
      body: Center(child: Text('Delivery: $tradeId')),
    );
  }
}
