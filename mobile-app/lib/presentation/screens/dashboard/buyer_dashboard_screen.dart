import 'package:flutter/material.dart';
import '../../config/theme.dart';

class BuyerDashboardScreen extends StatefulWidget {
  const BuyerDashboardScreen({Key? key}) : super(key: key);

  @override
  State<BuyerDashboardScreen> createState() => _BuyerDashboardScreenState();
}

class _BuyerDashboardScreenState extends State<BuyerDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buyer Dashboard'),
        elevation: 0,
      ),
      body: _buildPage(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Browse'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome, Buyer!',
                style: AfrigoTypography.headingLarge,
              ),
              const SizedBox(height: AfrigoSpacing.md),
              Text(
                'Browse available lots and RFQs',
                style: AfrigoTypography.bodyMedium.copyWith(
                  color: AfrigoColors.gray600,
                ),
              ),
            ],
          ),
        );
      case 1:
        return Center(
          child: Text('Browse Lots'),
        );
      case 2:
        return Center(
          child: Text('Shopping Cart'),
        );
      case 3:
        return Center(
          child: Text('Your Profile'),
        );
      default:
        return const SizedBox();
    }
  }
}
