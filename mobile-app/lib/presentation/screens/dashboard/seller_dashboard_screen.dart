import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/theme.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({Key? key}) : super(key: key);

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Dashboard'),
        elevation: 0,
      ),
      body: _buildPage(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.analytics), label: 'Analytics'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Lots'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag), label: 'Orders'),
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
                'Your Analytics',
                style: AfrigoTypography.headingLarge,
              ),
              const SizedBox(height: AfrigoSpacing.md),
              Text(
                'Track lots, orders, and revenue',
                style: AfrigoTypography.bodyMedium.copyWith(
                  color: AfrigoColors.gray600,
                ),
              ),
            ],
          ),
        );
      case 1:
        return Center(
          child: Text('Your Lots'),
        );
      case 2:
        return Center(
          child: Text('Orders Received'),
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
