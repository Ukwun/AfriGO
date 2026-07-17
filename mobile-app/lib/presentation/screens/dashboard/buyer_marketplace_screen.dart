import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BuyerMarketplaceScreen extends ConsumerWidget {
  const BuyerMarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final products = <Map<String, dynamic>>[
      {'name': 'Premium Coffee', 'price': '\$8.50/kg', 'rating': 4.8},
      {'name': 'Organic Cocoa', 'price': '\$10.20/kg', 'rating': 4.6},
      {'name': 'Spices Mix', 'price': '\$15.00/kg', 'rating': 4.9},
      {'name': 'Premium Rice', 'price': '\$2.20/kg', 'rating': 4.7},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Marketplace'), elevation: 0),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) => Card(
          child: InkWell(
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Added ${products[index]['name']} to cart'))),
            child: Column(
              children: [
                Container(
                    height: 100,
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    child: Icon(Icons.shopping_bag,
                        color: theme.colorScheme.primary, size: 40)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(products[index]['name'] as String,
                            style: theme.textTheme.labelSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        const Spacer(),
                        Text(products[index]['price'] as String,
                            style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.w700)),
                        Row(children: [
                          const Icon(Icons.star, size: 12, color: Colors.amber),
                          Text((products[index]['rating'] as double).toString(),
                              style: theme.textTheme.labelSmall)
                        ]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
