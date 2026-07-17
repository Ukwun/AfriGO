import 'package:flutter/material.dart';

class TradingScreen extends StatelessWidget {
  const TradingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trading')),
      body: const Center(child: Text('Trading Screen')),
    );
  }
}
