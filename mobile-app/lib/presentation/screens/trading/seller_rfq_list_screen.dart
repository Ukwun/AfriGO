import 'package:flutter/material.dart';

class SellerRFQListScreen extends StatelessWidget {
  const SellerRFQListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Available RFQs')),
      body: const Center(child: Text('RFQ List')),
    );
  }
}
