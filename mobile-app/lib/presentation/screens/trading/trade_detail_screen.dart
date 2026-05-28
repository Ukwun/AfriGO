import 'package:flutter/material.dart';

class TradeDetailScreen extends StatelessWidget {
  final String tradeId;
  const TradeDetailScreen({Key? key, required this.tradeId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trade Detail')),
      body: Center(child: Text('Trade Detail: $tradeId')),
    );
  }
}
