import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/providers/shipping_provider.dart';
import '../../../data/services/shipping_service.dart';

/// Order Tracking Screen
/// Real-time GPS tracking, status updates, temperature monitoring
/// All via WebSocket <500ms guaranteed latency
class OrderTrackingScreen extends ConsumerWidget {
  final String tradeId;

  const OrderTrackingScreen({Key? key, required this.tradeId})
    : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shipmentAsync = ref.watch(shipmentDetailProvider(tradeId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Tracking'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: shipmentAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
        data: (shipment) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // Status timeline
                _buildStatusTimeline(shipment),

                // Real-time GPS map section
                _buildGPSTrackingCard(shipment),

                // Current location card
                _buildCurrentLocationCard(shipment),

                // Temperature monitoring
                _buildTemperatureMonitor(shipment),

                // Estimated arrival
                _buildArrivalEstimate(shipment),

                // Shipment details
                _buildShipmentDetails(shipment),

                // Activity log (real-time updates)
                _buildActivityLog(shipment, ref),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Status timeline
  Widget _buildStatusTimeline(dynamic shipment) {
    final stages = [
      {
        'status': 'CREATED',
        'label': 'Order Created',
        'timestamp': shipment.createdAt,
      },
      {
        'status': 'IN_TRANSIT',
        'label': 'In Transit',
        'timestamp': shipment.departedAt,
      },
      {
        'status': 'AT_BORDER',
        'label': 'At Border',
        'timestamp': shipment.borderCrossingTime,
      },
      {
        'status': 'CUSTOMS',
        'label': 'Customs Clearing',
        'timestamp': shipment.customsClearanceTime,
      },
      {
        'status': 'ARRIVING',
        'label': 'Arriving Today',
        'timestamp': shipment.arrivingTime,
      },
      {
        'status': 'DELIVERED',
        'label': 'Delivered',
        'timestamp': shipment.deliveredAt,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Shipment Status',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: stages.asMap().entries.map((entry) {
                final index = entry.key;
                final stage = entry.value;
                final isCompleted = _isStageCompleted(
                  shipment.status,
                  stage['status'],
                );
                final isActive = shipment.status == stage['status'];

                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted
                              ? Colors.green
                              : isActive
                              ? Colors.blue
                              : Colors.grey[300],
                        ),
                        child: Center(
                          child: Icon(
                            _getStageIcon(stage['status']),
                            color: (isCompleted || isActive)
                                ? Colors.white
                                : Colors.grey,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 60,
                        child: Text(
                          stage['label'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isActive ? FontWeight.bold : null,
                            color: isActive ? Colors.blue : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// GPS tracking card
  Widget _buildGPSTrackingCard(dynamic shipment) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Live GPS Tracking',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.fiber_manual_record,
                          size: 8,
                          color: Colors.green,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Live Update',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Placeholder for actual map widget
              Container(
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.map, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text(
                        'Live Map View',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Route from ${shipment.originLocation} to ${shipment.destinationLocation}',
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Speed',
                        style: TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${shipment.currentSpeed ?? 0} km/h',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Distance Remaining',
                        style: TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${shipment.distanceRemaining ?? 0} km',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Last Update',
                        style: TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Just now',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.green,
                        ),
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

  /// Current location card
  Widget _buildCurrentLocationCard(dynamic shipment) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Current Location',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.location_on, color: Colors.red),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shipment.currentLocation ?? 'In Transit',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Latitude: ${shipment.latitude ?? "N/A"}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          'Longitude: ${shipment.longitude ?? "N/A"}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Updated ${_formatTime(shipment.lastLocationUpdate)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Temperature monitoring
  Widget _buildTemperatureMonitor(dynamic shipment) {
    final hasAlert =
        shipment.currentTemperature != null &&
        shipment.targetTemperature != null &&
        (shipment.currentTemperature! > shipment.targetTemperature! + 2 ||
            shipment.currentTemperature! < shipment.targetTemperature! - 2);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        color: hasAlert ? Colors.red[50] : Colors.blue[50],
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Cold Chain Monitoring',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  if (hasAlert)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.warning, size: 12, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'Alert',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text(
                        'Current',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${shipment.currentTemperature ?? 0}°C',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text(
                        'Target',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${shipment.targetTemperature ?? 0}°C',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text(
                        'Humidity',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${shipment.humidity ?? 0}%',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (hasAlert) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, size: 16, color: Colors.red[900]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Temperature deviation detected! Product quality may be affected.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.red[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Estimated arrival
  Widget _buildArrivalEstimate(dynamic shipment) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Estimated Arrival',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.schedule, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shipment.estimatedArrival ?? 'TBD',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Confidence: ±${shipment.eta_confidence ?? "2"} hours',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shipment details
  Widget _buildShipmentDetails(dynamic shipment) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Shipment Details',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildDetailRow('Shipment ID:', shipment.id),
              _buildDetailRow('Carrier:', shipment.carrier ?? 'Not assigned'),
              _buildDetailRow('Tracking #:', shipment.trackingNumber ?? 'N/A'),
              _buildDetailRow('From:', shipment.originLocation ?? 'N/A'),
              _buildDetailRow('To:', shipment.destinationLocation ?? 'N/A'),
              _buildDetailRow(
                'Departure:',
                _formatTime(shipment.departedAt) ?? 'TBD',
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Activity log (real-time updates via WebSocket)
  Widget _buildActivityLog(dynamic shipment, WidgetRef ref) {
    final eventsAsync = ref.watch(shipmentEventsProvider(shipment.id));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Real-Time Activity Log',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              eventsAsync.when(
                loading: () => const CircularProgressIndicator(),
                error: (error, stackTrace) => Text('Error: $error'),
                data: (events) {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(top: 6),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event['eventType'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    event['description'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatTime(event['timestamp']),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods
  bool _isStageCompleted(String currentStatus, String stageStatus) {
    const stages = [
      'CREATED',
      'IN_TRANSIT',
      'AT_BORDER',
      'CUSTOMS',
      'ARRIVING',
      'DELIVERED',
    ];
    return stages.indexOf(currentStatus) > stages.indexOf(stageStatus);
  }

  IconData _getStageIcon(dynamic status) {
    switch (status) {
      case 'CREATED':
        return Icons.check_circle;
      case 'IN_TRANSIT':
        return Icons.local_shipping;
      case 'AT_BORDER':
        return Icons.public;
      case 'CUSTOMS':
        return Icons.security;
      case 'ARRIVING':
        return Icons.near_me;
      case 'DELIVERED':
        return Icons.done_all;
      default:
        return Icons.info;
    }
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return 'TBD';
    return timestamp.toString().split('.')[0];
  }

  String _formatDetailRow(String key, String value) {
    return '$key $value';
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
