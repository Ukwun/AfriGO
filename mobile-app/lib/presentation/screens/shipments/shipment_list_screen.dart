import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:afrigo_app/models/shipment_model.dart';
import '../providers/shipment_provider.dart';

class ShipmentListScreen extends ConsumerStatefulWidget {
  const ShipmentListScreen({super.key});

  @override
  ConsumerState<ShipmentListScreen> createState() => _ShipmentListScreenState();
}

class _ShipmentListScreenState extends ConsumerState<ShipmentListScreen> {
  late ShipmentFilters filters;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    filters = ShipmentFilters();
  }

  @override
  Widget build(BuildContext context) {
    final shipmentsAsync = ref.watch(shipmentsProvider(filters));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shipments'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter tabs
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: filters.status == null,
                    onSelected: (selected) {
                      setState(() {
                        filters = filters.copyWith(status: null, offset: 0);
                        currentPage = 0;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Pending'),
                    selected: filters.status == 'PENDING',
                    onSelected: (selected) {
                      setState(() {
                        filters = filters.copyWith(
                          status: selected ? 'PENDING' : null,
                          offset: 0,
                        );
                        currentPage = 0;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('In Transit'),
                    selected: filters.status == 'IN_TRANSIT',
                    onSelected: (selected) {
                      setState(() {
                        filters = filters.copyWith(
                          status: selected ? 'IN_TRANSIT' : null,
                          offset: 0,
                        );
                        currentPage = 0;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Delivered'),
                    selected: filters.status == 'DELIVERED',
                    onSelected: (selected) {
                      setState(() {
                        filters = filters.copyWith(
                          status: selected ? 'DELIVERED' : null,
                          offset: 0,
                        );
                        currentPage = 0;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Failed'),
                    selected: filters.status == 'FAILED_DELIVERY',
                    onSelected: (selected) {
                      setState(() {
                        filters = filters.copyWith(
                          status: selected ? 'FAILED_DELIVERY' : null,
                          offset: 0,
                        );
                        currentPage = 0;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          // Shipments list
          Expanded(
            child: shipmentsAsync.when(
              data: (shipmentList) {
                if (shipmentList.data.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_shipping_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No shipments found',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create your first shipment from a contract',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: shipmentList.data.length,
                  itemBuilder: (context, index) {
                    final shipment = shipmentList.data[index];
                    return ShipmentCard(
                      shipment: shipment,
                      onTap: () {
                        context.go('/shipments/${shipment.id}');
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red.shade400,
                    ),
                    const SizedBox(height: 16),
                    const Text('Error loading shipments'),
                    const SizedBox(height: 8),
                    Text(error.toString()),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ======================== SHIPMENT CARD WIDGET ========================

class ShipmentCard extends StatelessWidget {
  final ShipmentModel shipment;
  final VoidCallback onTap;

  const ShipmentCard({
    super.key,
    required this.shipment,
    required this.onTap,
  });

  Color _statusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.grey;
      case 'SCHEDULED':
        return Colors.blue;
      case 'IN_TRANSIT':
        return Colors.orange;
      case 'ARRIVED_DESTINATION':
        return Colors.cyan;
      case 'DELIVERED':
        return Colors.green;
      case 'FAILED_DELIVERY':
        return Colors.red;
      case 'CANCELLED':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'PENDING':
        return Icons.pending_actions;
      case 'SCHEDULED':
        return Icons.calendar_today;
      case 'IN_TRANSIT':
        return Icons.local_shipping;
      case 'ARRIVED_DESTINATION':
        return Icons.location_on;
      case 'DELIVERED':
        return Icons.check_circle;
      case 'FAILED_DELIVERY':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  String _daysUntilDelivery() {
    final now = DateTime.now();
    final days = shipment.expectedDeliveryDate.difference(now).inDays;
    if (days < 0) {
      return '${days.abs()} days overdue';
    } else if (days == 0) {
      return 'Due today';
    } else {
      return '$days days left';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Reference & Status Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shipment.shipmentReference,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                _statusColor(shipment.status).withOpacity(0.1),
                            border: Border.all(
                              color: _statusColor(shipment.status),
                              width: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _statusIcon(shipment.status),
                                size: 12,
                                color: _statusColor(shipment.status),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                shipment.status.replaceAll('_', ' '),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _statusColor(shipment.status),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (shipment.isDelayed == true)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(
                        Icons.warning_amber,
                        color: Colors.red.shade700,
                        size: 20,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // Locations
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'From',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        Text(
                          shipment.pickupLocationName,
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward, color: Colors.grey.shade400),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'To',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        Text(
                          shipment.deliveryLocationName,
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Stats Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Delivery Timeline',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      Text(
                        _daysUntilDelivery(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  if (shipment.deliveryProofCount != null &&
                      shipment.deliveryProofCount! > 0)
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${shipment.deliveryProofCount} proof${shipment.deliveryProofCount! > 1 ? 's' : ''}',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Colors.green,
                                  ),
                        ),
                      ],
                    ),
                  if (shipment.driver != null)
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          shipment.driver!.name,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
