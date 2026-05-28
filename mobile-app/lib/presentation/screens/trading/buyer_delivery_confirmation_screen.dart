import 'package:flutter/material.dart';

class BuyerDeliveryConfirmationScreen extends StatelessWidget {
  final String tradeId;
  const BuyerDeliveryConfirmationScreen({Key? key, required this.tradeId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Delivery Confirmation')),
      body: Center(child: Text('Delivery: $tradeId')),
    );
  }
}
