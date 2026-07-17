import 'package:flutter/material.dart';

class ShippingInstructionsScreen extends StatelessWidget {
  final String bidId;
  const ShippingInstructionsScreen({super.key, required this.bidId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shipping Instructions')),
      body: Center(child: Text('Shipping: $bidId')),
    );
  }
}
