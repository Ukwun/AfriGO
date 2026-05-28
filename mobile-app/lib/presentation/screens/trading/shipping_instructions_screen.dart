import 'package:flutter/material.dart';

class ShippingInstructionsScreen extends StatelessWidget {
  final String bidId;
  const ShippingInstructionsScreen({Key? key, required this.bidId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shipping Instructions')),
      body: Center(child: Text('Shipping: $bidId')),
    );
  }
}
