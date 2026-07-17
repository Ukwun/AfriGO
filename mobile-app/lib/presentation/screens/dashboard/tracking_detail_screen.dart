import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/colors.dart';
import '../../widgets/motion_system.dart';

class TrackingDetailScreen extends ConsumerStatefulWidget {
  final String trackingId;

  const TrackingDetailScreen({
    super.key,
    required this.trackingId,
  });

  @override
  ConsumerState<TrackingDetailScreen> createState() =>
      _TrackingDetailScreenState();
}

class _TrackingDetailScreenState extends ConsumerState<TrackingDetailScreen>
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
        title: Text('Tracking ${widget.trackingId}'),
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
                // Current Status
                ScaleInTransition(
                  child: _buildStatusCard(),
                ),
                const SizedBox(height: 24),

                // Granular Events
                ScaleInTransition(
                  child: _buildSectionHeader('Recent Events'),
                ),
                const SizedBox(height: 12),
                ..._buildEventsList(),
                const SizedBox(height: 24),

                // Checkpoints
                ScaleInTransition(
                  child: _buildSectionHeader('Journey Checkpoints'),
                ),
                const SizedBox(height: 12),
                ScaleInTransition(
                  child: _buildCheckpointsTimeline(),
                ),
                const SizedBox(height: 24),

                // ETA Projection
                ScaleInTransition(
                  child: _buildSectionHeader('Estimated Delivery'),
                ),
                const SizedBox(height: 12),
                ScaleInTransition(
                  child: _buildETACard(),
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
                  Text('Current Status',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  SizedBox(height: 4),
                  Text('In Transit - Ocean',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  SizedBox(height: 4),
                  Text('Container TRK-2024-1847',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.directions_boat,
                    color: Colors.blue, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildETAItem('Position', '05°N 02°W'),
              _buildETAItem('Speed', '18 knots'),
              _buildETAItem('Progress', '65%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildETAItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }

  List<Widget> _buildEventsList() {
    final events = [
      ('Vessel Departed', 'Lagos Port', '2 hours ago', Icons.directions_boat),
      ('Customs Cleared', 'Port Authority', '8 hours ago', Icons.verified),
      ('Loaded on Vessel', 'Terminal 4', '1 day ago', Icons.local_shipping),
      ('Quality Passed', 'Inspection Zone', '2 days ago', Icons.check_circle),
      ('Picked up', 'Supplier Warehouse', '3 days ago', Icons.warehouse),
    ];

    return List.generate(events.length, (index) {
      final (event, location, time, icon) = events[index];
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
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
                  child: Icon(icon, color: AppColors.accentBlue, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(location,
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

  Widget _buildCheckpointsTimeline() {
    final checkpoints = [
      ('Departure', 'Lagos', '✅ Completed', true),
      ('Sea Transit', 'Gulf of Guinea', '✅ In Progress', true),
      ('Port Arrival', 'Rotterdam', '⏳ Scheduled', false),
      ('Customs Clear', 'Rotterdam', '⏳ Pending', false),
      ('Final Delivery', 'Hamburg', '⏳ Planned', false),
    ];

    return Column(
      children: List.generate(checkpoints.length, (index) {
        final (checkpoint, location, status, completed) = checkpoints[index];
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
                  if (index < checkpoints.length - 1)
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
                    Text(checkpoint,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(location,
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[600])),
                    Text(status,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildETACard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Expected Arrival',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('September 8, 2024 · 4:30 PM',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.green)),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: 0.65,
            minHeight: 6,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
          ),
          const SizedBox(height: 8),
          const Text('65% of journey completed',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }
}
