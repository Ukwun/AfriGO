import 'package:flutter/material.dart';

class TradeDetailScreen extends StatelessWidget {
  final String tradeId;
  const TradeDetailScreen({super.key, required this.tradeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trade Detail')),
      body: Center(child: Text('Trade Detail: $tradeId')),
    );
  }
}
