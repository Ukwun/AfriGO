import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/colors.dart';
import '../../widgets/motion_system.dart';

class ShipmentDetailScreen extends ConsumerStatefulWidget {
  final String shipmentId;

  const ShipmentDetailScreen({
    super.key,
    required this.shipmentId,
  });

  @override
  ConsumerState<ShipmentDetailScreen> createState() =>
      _ShipmentDetailScreenState();
}

class _ShipmentDetailScreenState extends ConsumerState<ShipmentDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shipment ${widget.shipmentId}'),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: FadeTransition(
        opacity: _animationController,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Overview
                ScaleInTransition(
                  child: _buildStatusCard(),
                ),
                const SizedBox(height: 24),

                // Tracking Timeline
                ScaleInTransition(
                  child: _buildSectionHeader('Live Route & Timeline'),
                ),
                const SizedBox(height: 12),
                ScaleInTransition(
                  child: _buildTrackingTimeline(),
                ),
                const SizedBox(height: 24),

                // Temperature Telemetry
                ScaleInTransition(
                  child: _buildSectionHeader('Temperature Monitoring'),
                ),
                const SizedBox(height: 12),
                ScaleInTransition(
                  child: _buildTelemetryCard(),
                ),
                const SizedBox(height: 24),

                // Milestones
                ScaleInTransition(
                  child: _buildSectionHeader('Key Milestones'),
                ),
                const SizedBox(height: 12),
                ..._buildMilestones(),
                const SizedBox(height: 24),

                // Actions
                ScaleInTransition(
                  child: _buildActionsRow(),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.withOpacity(0.1), Colors.cyan.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('In Transit',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  SizedBox(height: 4),
                  Text(
                    'Lagos → Accra',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.local_shipping,
                    color: Colors.amber, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusInfo('ETA', '2 days 4 hours'),
              _buildStatusInfo('Distance', '245 km'),
              _buildStatusInfo('Speed', '92 km/h'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildTrackingTimeline() {
    final milestones = [
      ('Started', 'Port of Lagos', '2 days ago', true),
      ('In Transit', 'Approaching Accra', 'Now', true),
      ('Arrival', 'Port of Accra', '2 days', false),
      ('Clearance', 'Customs', 'TBD', false),
    ];

    return Column(
      children: List.generate(milestones.length, (index) {
        final (label, location, time, completed) = milestones[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: completed ? Colors.green : Colors.grey[300],
                      border: Border.all(
                        color: completed ? Colors.green : Colors.grey,
                        width: 2,
                      ),
                    ),
                    child: completed
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                  if (index < milestones.length - 1)
                    Container(
                      width: 2,
                      height: 40,
                      color: completed ? Colors.green : Colors.grey[300],
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      location,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    Text(
                      time,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTelemetryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTelemetryItem('🌡️', '18°C', 'Current'),
          _buildTelemetryItem('📈', '22°C', 'Max'),
          _buildTelemetryItem('📉', '16°C', 'Min'),
          _buildTelemetryItem('💧', '65%', 'Humidity'),
        ],
      ),
    );
  }

  Widget _buildTelemetryItem(String icon, String value, String label) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  List<Widget> _buildMilestones() {
    final milestones = [
      ('Departure', 'Started from warehouse', '18 hours ago', Icons.home),
      (
        'Customs',
        'Export declaration approved',
        '12 hours ago',
        Icons.verified
      ),
      (
        'Loading',
        'Container loaded onto vessel',
        '6 hours ago',
        Icons.local_shipping
      ),
      ('At Sea', 'Currently in transit', '2 hours ago', Icons.waves),
    ];

    return List.generate(milestones.length, (index) {
      final (title, description, time, icon) = milestones[index];
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: ScaleInTransition(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accentBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, color: AppColors.accentBlue, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(description,
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                ),
                Text(time,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildActionsRow() {
    return Row(
      children: [
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('📍 Opening live map...'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map, size: 20),
                    SizedBox(width: 8),
                    Text('View Map',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('📞 Contact initiated...'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.accentBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.phone, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Contact Driver',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
