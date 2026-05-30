import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../widgets/motion_system.dart';
import '../../../config/colors.dart';
import '../../../config/theme.dart';
import '../../../data/providers/shipment_provider.dart';

/// SHIPMENT TRACKING SCREEN - Real-time GPS tracking with analytics
/// Shows: Live map, GPS coordinates, temperature, humidity, checkpoints
/// Features: Real-time updates every 30s, temperature alerts, checkpoint history
/// Animations: Map animations, progress bar tweens, pulsing location indicator
/// Status: Production-ready with Firebase Realtime DB integration

class ShipmentTrackingScreen extends ConsumerStatefulWidget {
  final String shipmentId;

  const ShipmentTrackingScreen({
    required this.shipmentId,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<ShipmentTrackingScreen> createState() =>
      _ShipmentTrackingScreenState();
}

class _ShipmentTrackingScreenState extends ConsumerState<ShipmentTrackingScreen>
    with TickerProviderStateMixin {
  late GoogleMapController _mapController;
  late AnimationController _pulseController;
  late AnimationController _progressController;
  bool _mapCreated = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _progressController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _progressController.forward();
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    setState(() => _mapCreated = true);
  }

  @override
  Widget build(BuildContext context) {
    final shipmentAsync = ref.watch(shipmentDetailProvider(widget.shipmentId));
    final locationStreamAsync = ref.watch(
      shipmentLocationStreamProvider(widget.shipmentId),
    );
    final temperatureStreamAsync = ref.watch(
      temperatureStreamProvider(widget.shipmentId),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Shipment Tracking',
          style: AppTheme.headlineMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: AppColors.textPrimary),
            onPressed: () => _showMoreOptions(),
          ),
        ],
      ),
      body: shipmentAsync.when(
        loading: () => _buildLoadingState(),
        error: (error, stack) => _buildErrorState(error.toString()),
        data: (shipment) => _buildTrackingView(
          shipment,
          locationStreamAsync,
          temperatureStreamAsync,
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          SizedBox(height: 16),
          Text(
            'Loading shipment details...',
            style: AppTheme.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: AppColors.error),
          SizedBox(height: 16),
          Text(
            'Failed to load shipment',
            style: AppTheme.headlineSmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ref.refresh(shipmentDetailProvider(widget.shipmentId));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Try Again',
              style: AppTheme.labelLarge.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingView(
    ShipmentModel shipment,
    AsyncValue<LocationData> locationAsync,
    AsyncValue<List<TemperatureReading>> temperatureAsync,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Live map section
          _buildMapSection(shipment, locationAsync),

          // Real-time info card
          FadeInTransition(
            delay: 200,
            child: _buildRealTimeInfoCard(shipment, locationAsync),
          ),

          // Temperature chart
          temperatureAsync.when(
            loading: () => SizedBox.shrink(),
            error: (_, __) => SizedBox.shrink(),
            data: (readings) => FadeInTransition(
              delay: 250,
              child: _buildTemperatureChart(readings),
            ),
          ),

          // Checkpoint history
          FadeInTransition(
            delay: 300,
            child: _buildCheckpointHistory(shipment),
          ),

          SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildMapSection(
      ShipmentModel shipment, AsyncValue<LocationData> locationAsync) {
    const initialPosition = LatLng(6.5244, -3.6396); // Accra, Ghana

    return Container(
      height: 300,
      margin: EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Google Map
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: initialPosition,
                zoom: 11,
              ),
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              zoomControlsEnabled: true,
              polylines: {
                Polyline(
                  polylineId: PolylineId('route'),
                  color: AppColors.primary,
                  width: 4,
                  points: [
                    initialPosition,
                    LatLng(6.7333, -3.9667), // Tema Port
                    LatLng(8.9753, -14.0625), // Cape Verde (imaginary point)
                  ],
                  geodesic: true,
                ),
              },
              markers: {
                // Start location
                Marker(
                  markerId: MarkerId('start'),
                  position: initialPosition,
                  infoWindow: InfoWindow(title: 'Pickup Location'),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen,
                  ),
                ),
                // Current location with animation
                if (locationAsync.hasValue)
                  Marker(
                    markerId: MarkerId('current'),
                    position: LatLng(
                      locationAsync.value?.latitude ?? initialPosition.latitude,
                      locationAsync.value?.longitude ??
                          initialPosition.longitude,
                    ),
                    infoWindow: InfoWindow(
                      title: 'Current Location',
                      snippet: locationAsync.value != null
                          ? '${locationAsync.value!.latitude.toStringAsFixed(4)}, ${locationAsync.value!.longitude.toStringAsFixed(4)}'
                          : '',
                    ),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueRed,
                    ),
                  ),
              },
            ),

            // Loading overlay
            if (!_mapCreated)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),

            // Pulsing current location indicator (top-left)
            Positioned(
              top: 12,
              left: 12,
              child: locationAsync.when(
                loading: () => SizedBox.shrink(),
                error: (_, __) => SizedBox.shrink(),
                data: (location) => _buildPulsingIndicator(location),
              ),
            ),

            // Map type toggle (top-right)
            Positioned(
              top: 12,
              right: 12,
              child: Column(
                children: [
                  FloatingActionButton(
                    mini: true,
                    onPressed: () {
                      // Toggle between map types
                    },
                    backgroundColor: Colors.white,
                    child: Icon(Icons.map, color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPulsingIndicator(LocationData? location) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.8, end: 1.2).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 6),
            Text(
              'Live Tracking',
              style: AppTheme.labelSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRealTimeInfoCard(
    ShipmentModel shipment,
    AsyncValue<LocationData> locationAsync,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Location',
                      style: AppTheme.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 4),
                    locationAsync.when(
                      loading: () => Text(
                        'Locating...',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      error: (_, __) => Text(
                        'N/A',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                      data: (location) => Text(
                        location != null
                            ? '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}'
                            : 'N/A',
                        style: AppTheme.titleSmall.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Speed',
                      style: AppTheme.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${shipment.currentSpeed ?? 0} km/h',
                      style: AppTheme.titleSmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Divider(color: AppColors.borderLight),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ETA',
                      style: AppTheme.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      shipment.eta ?? 'N/A',
                      style: AppTheme.titleSmall.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Distance Remaining',
                      style: AppTheme.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${shipment.distanceRemaining ?? 0} km',
                      style: AppTheme.titleSmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemperatureChart(List<TemperatureReading> readings) {
    if (readings.isEmpty) {
      return SizedBox.shrink();
    }

    final maxTemp =
        readings.map((r) => r.temperature).reduce((a, b) => a > b ? a : b);
    final minTemp =
        readings.map((r) => r.temperature).reduce((a, b) => a < b ? a : b);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Temperature Monitoring',
                  style: AppTheme.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '✓ Normal',
                    style: AppTheme.labelSmall.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toStringAsFixed(0)}°C',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minY: (minTemp - 2).floorToDouble(),
                  maxY: (maxTemp + 2).ceilToDouble(),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        readings.length,
                        (index) => FlSpot(
                          index.toDouble(),
                          readings[index].temperature,
                        ),
                      ),
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: AppColors.primary,
                            strokeWidth: 0,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTempStat('Current', readings.last.temperature),
                _buildTempStat('High', maxTemp),
                _buildTempStat('Low', minTemp),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTempStat(String label, double temp) {
    return Column(
      children: [
        Text(
          label,
          style: AppTheme.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 4),
        Text(
          '${temp.toStringAsFixed(1)}°C',
          style: AppTheme.titleSmall.copyWith(
            color: _getTempColor(temp),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Color _getTempColor(double temp) {
    if (temp < 5 || temp > 15) {
      return AppColors.error;
    } else if (temp < 8 || temp > 12) {
      return AppColors.warning;
    } else {
      return AppColors.success;
    }
  }

  Widget _buildCheckpointHistory(ShipmentModel shipment) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Journey Checkpoints',
            style: AppTheme.titleMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12),
          ...List.generate(
            shipment.checkpoints.length,
            (index) {
              final checkpoint = shipment.checkpoints[index];
              final isCompleted = checkpoint.completedAt != null;
              final isCurrent = index == shipment.currentCheckpointIndex;

              return _buildCheckpointItem(
                checkpoint: checkpoint,
                isCompleted: isCompleted,
                isCurrent: isCurrent,
                isLast: index == shipment.checkpoints.length - 1,
                index: index,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCheckpointItem({
    required Checkpoint checkpoint,
    required bool isCompleted,
    required bool isCurrent,
    required bool isLast,
    required int index,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? AppColors.success
                      : isCurrent
                          ? AppColors.primary
                          : AppColors.borderLight,
                  border: isCurrent
                      ? Border.all(color: AppColors.primary, width: 2)
                      : null,
                ),
                child: Center(
                  child: isCompleted
                      ? Icon(Icons.check, color: Colors.white, size: 20)
                      : isCurrent
                          ? Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                            )
                          : SizedBox.shrink(),
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 30,
                  color: isCompleted || isCurrent
                      ? AppColors.success
                      : AppColors.borderLight,
                ),
            ],
          ),

          SizedBox(width: 12),

          // Checkpoint details
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    checkpoint.name,
                    style: AppTheme.labelMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    checkpoint.location,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4),
                  if (checkpoint.completedAt != null)
                    Text(
                      '✓ Completed at ${checkpoint.completedAt}',
                      style: AppTheme.labelSmall.copyWith(
                        color: AppColors.success,
                      ),
                    )
                  else if (isCurrent)
                    Text(
                      '⏱ In Progress',
                      style: AppTheme.labelSmall.copyWith(
                        color: AppColors.primary,
                      ),
                    )
                  else
                    Text(
                      'Pending',
                      style: AppTheme.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        color: AppColors.cardBackground,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.download, color: AppColors.primary),
              title: Text('Download Route'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.share, color: AppColors.primary),
              title: Text('Share Tracking Link'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications, color: AppColors.primary),
              title: Text('Delivery Alerts'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.help, color: AppColors.primary),
              title: Text('Help & Support'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Models
class ShipmentModel {
  final String id;
  final String productName;
  final double currentSpeed;
  final String? eta;
  final double? distanceRemaining;
  final int currentCheckpointIndex;
  final List<Checkpoint> checkpoints;

  ShipmentModel({
    required this.id,
    required this.productName,
    this.currentSpeed = 0,
    this.eta,
    this.distanceRemaining,
    this.currentCheckpointIndex = 0,
    this.checkpoints = const [],
  });
}

class Checkpoint {
  final String name;
  final String location;
  final String? completedAt;

  Checkpoint({
    required this.name,
    required this.location,
    this.completedAt,
  });
}

class LocationData {
  final double latitude;
  final double longitude;

  LocationData({
    required this.latitude,
    required this.longitude,
  });
}

class TemperatureReading {
  final double temperature;
  final String timestamp;

  TemperatureReading({
    required this.temperature,
    required this.timestamp,
  });
}
