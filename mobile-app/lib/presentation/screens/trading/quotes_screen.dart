import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/quote_model.dart';
import '../services/api_service.dart';

final receivedQuotesProvider = FutureProvider.autoDispose<List<QuoteModel>>(
  (ref) async {
    final apiService = ref.watch(apiServiceProvider);
    final response = await apiService.getReceivedQuotes({});
    return response.quotes;
  },
);

final sentQuotesProvider = FutureProvider.autoDispose<List<QuoteModel>>(
  (ref) async {
    final apiService = ref.watch(apiServiceProvider);
    final response = await apiService.getSentQuotes({});
    return response.quotes;
  },
);

class QuotesScreen extends ConsumerWidget {
  const QuotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quotes'),
          elevation: 0,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Received'),
              Tab(text: 'Sent'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Received Quotes Tab
            _buildReceivedQuotesTab(context, ref),

            // Sent Quotes Tab
            _buildSentQuotesTab(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildReceivedQuotesTab(BuildContext context, WidgetRef ref) {
    final quotesAsync = ref.watch(receivedQuotesProvider);

    return quotesAsync.when(
      data: (quotes) {
        if (quotes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mail_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No quotes yet',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sellers will send you quotes for your orders',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.refresh(receivedQuotesProvider);
          },
          child: ListView.builder(
            itemCount: quotes.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final quote = quotes[index];
              return QuoteCard(quote: quote, isReceived: true);
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64),
            const SizedBox(height: 16),
            Text('Failed to load quotes: $error'),
          ],
        ),
      ),
    );
  }

  Widget _buildSentQuotesTab(BuildContext context, WidgetRef ref) {
    final quotesAsync = ref.watch(sentQuotesProvider);

    return quotesAsync.when(
      data: (quotes) {
        if (quotes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.send_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No quotes sent',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Send quotes to buyers for their orders',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.refresh(sentQuotesProvider);
          },
          child: ListView.builder(
            itemCount: quotes.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final quote = quotes[index];
              return QuoteCard(quote: quote, isReceived: false);
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64),
            const SizedBox(height: 16),
            Text('Failed to load quotes: $error'),
          ],
        ),
      ),
    );
  }
}

class QuoteCard extends ConsumerWidget {
  final QuoteModel quote;
  final bool isReceived;

  const QuoteCard({
    required this.quote,
    required this.isReceived,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = _getStatusColor(quote.status);
    final isExpiring = quote.expiresAt.difference(DateTime.now()).inHours < 24;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('/quotes/${quote.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isReceived ? 'From: ' : 'To: ',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey,
                              ),
                        ),
                        Text(
                          isReceived
                              ? quote.fromUser?.fullName ?? 'Unknown'
                              : quote.toUser?.fullName ?? 'Unknown',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatusLabel(quote.status),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Quote details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quantity',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                      Text(
                        '${quote.quotedQuantity.toStringAsFixed(2)} ${quote.quantityUnit}',
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Price per Unit',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                      Text(
                        '${quote.quotedPrice.toStringAsFixed(2)} NGN',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    '${(quote.quotedPrice * quote.quotedQuantity).toStringAsFixed(2)} NGN',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Expiration info
              if (isExpiring)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.timer, size: 16, color: Colors.deepOrange),
                      const SizedBox(width: 8),
                      Text(
                        'Expires in ${quote.expiresAt.difference(DateTime.now()).inHours} hours',
                        style: const TextStyle(
                          color: Colors.deepOrange,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 12),

              // Action buttons
              if (isReceived && quote.status == 'pending')
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // Reject quote
                        },
                        child: const Text('Reject'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          // Accept quote
                        },
                        child: const Text('Accept'),
                      ),
                    ),
                  ],
                )
              else if (isReceived && quote.status == 'pending')
                FilledButton.icon(
                  onPressed: () {
                    // Create counter quote
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Send Counter Offer'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'expired':
        return Colors.grey;
      case 'countered':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
      case 'expired':
        return 'Expired';
      case 'countered':
        return 'Countered';
      default:
        return status;
    }
  }
}
