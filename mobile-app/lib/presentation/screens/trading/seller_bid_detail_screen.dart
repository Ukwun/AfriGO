import 'package:flutter/material.dart';

class SellerBidDetailScreen extends StatelessWidget {
  final String bidId;
  const SellerBidDetailScreen({Key? key, required this.bidId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bid Detail')),
      body: Center(child: Text('Bid Detail: $bidId')),
    );
  }
}
