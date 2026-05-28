import 'package:flutter/material.dart';

class PaymentScreen extends StatelessWidget {
  final String tradeId;
  const PaymentScreen({Key? key, required this.tradeId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Center(child: Text('Payment Screen: $tradeId')),
    );
  }
}
