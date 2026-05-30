import 'package:flutter/material.dart';
import '../../config/colors.dart';

/// Motion System - Transitions (200-350ms), Microinteractions, and Skeleton Loading
///
/// Professional-grade animations for realistic product experience:
/// - Slide, Fade, Scale transitions (200-350ms)
/// - Shipment tracking with progress lines, status pulses, timeline nodes
/// - Skeleton loading for cards, tables, and data-heavy interfaces

// ============================================================================
// TRANSITIONS: Slide, Fade, Scale (200-350ms)
// ============================================================================

/// SlideInTransition - Smooth horizontal slide enter animation (250ms)
class SlideInTransition extends StatefulWidget {
  final Widget child;
  final Offset begin;
  final Duration duration;
  final Curve curve;

  const SlideInTransition({
    super.key,
    required this.child,
    this.begin = const Offset(1.0, 0.0),
    this.duration = const Duration(milliseconds: 250),
    this.curve = Curves.easeInOutCubic,
  });

  @override
  State<SlideInTransition> createState() => _SlideInTransitionState();
}

class _SlideInTransitionState extends State<SlideInTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: widget.begin,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: widget.child,
    );
  }
}

/// FadeInTransition - Smooth fade enter animation (300ms)
class FadeInTransition extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final double beginOpacity;

  const FadeInTransition({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.beginOpacity = 0.0,
  });

  @override
  State<FadeInTransition> createState() => _FadeInTransitionState();
}

class _FadeInTransitionState extends State<FadeInTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _opacityAnimation = Tween<double>(
      begin: widget.beginOpacity,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: widget.child,
    );
  }
}

/// ScaleInTransition - Smooth scale enter animation (250ms)
class ScaleInTransition extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final double beginScale;

  const ScaleInTransition({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 250),
    this.curve = Curves.easeInOutCubic,
    this.beginScale = 0.8,
  });

  @override
  State<ScaleInTransition> createState() => _ScaleInTransitionState();
}

class _ScaleInTransitionState extends State<ScaleInTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: widget.beginScale,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: widget.child,
    );
  }
}

// ============================================================================
// SHIPMENT TRACKING: Progress Lines, Status Pulses, Timeline Nodes
// ============================================================================

/// ShipmentProgressTimeline - Animated shipment tracking with expanding nodes
class ShipmentProgressTimeline extends StatefulWidget {
  final List<ShipmentStage> stages;
  final int currentStageIndex;
  final bool isAnimating;

  const ShipmentProgressTimeline({
    super.key,
    required this.stages,
    required this.currentStageIndex,
    this.isAnimating = true,
  });

  @override
  State<ShipmentProgressTimeline> createState() =>
      _ShipmentProgressTimelineState();
}

class ShipmentStage {
  final String label;
  final String timestamp;
  final IconData icon;
  final bool isCompleted;

  ShipmentStage({
    required this.label,
    required this.timestamp,
    required this.icon,
    required this.isCompleted,
  });
}

class _ShipmentProgressTimelineState extends State<ShipmentProgressTimeline>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    if (widget.isAnimating) {
      _pulseController.repeat();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: List.generate(widget.stages.length, (index) {
          final stage = widget.stages[index];
          final isCurrent = index == widget.currentStageIndex;
          final isCompleted = index < widget.currentStageIndex;

          return Column(
            children: [
              // Stage Node with Pulse
              _buildTimelineNode(
                stage,
                isCurrent,
                isCompleted,
                index,
              ),
              // Connecting Line to next stage
              if (index < widget.stages.length - 1)
                _buildConnectingLine(isCompleted || isCurrent),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildTimelineNode(
    ShipmentStage stage,
    bool isCurrent,
    bool isCompleted,
    int index,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // Node Circle with Pulse
          Stack(
            alignment: Alignment.center,
            children: [
              // Pulse Animation for current stage
              if (isCurrent)
                ScaleTransition(
                  scale: Tween(begin: 0.8, end: 1.3).animate(
                    CurvedAnimation(
                      parent: _pulseController,
                      curve: Curves.easeInOut,
                    ),
                  ),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withOpacity(0.2),
                    ),
                  ),
                ),
              // Main Node
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted || isCurrent
                      ? AppColors.primary
                      : Colors.grey.shade300,
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                  boxShadow: [
                    if (isCurrent)
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    stage.icon,
                    color: isCompleted || isCurrent
                        ? Colors.white
                        : Colors.grey.shade600,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Stage Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stage.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isCompleted || isCurrent
                        ? Colors.black
                        : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stage.timestamp,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectingLine(bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.only(left: 24),
      child: Container(
        width: 3,
        height: 32,
        color: isCompleted ? AppColors.primary : Colors.grey.shade300,
      ),
    );
  }
}

// ============================================================================
// SKELETON LOADING: Cards, Tables, Maps
// ============================================================================

/// SkeletonCard - Animated skeleton loader for card content
class SkeletonCard extends StatefulWidget {
  final double width;
  final double height;
  final EdgeInsets padding;
  final bool showLines;

  const SkeletonCard({
    super.key,
    this.width = double.infinity,
    this.height = 150,
    this.padding = const EdgeInsets.all(12),
    this.showLines = true,
  });

  @override
  State<SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<SkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _shimmerController.repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          padding: widget.padding,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header shimmer
              _buildShimmerLine(
                width: 100,
                height: 16,
                offset: _shimmerController.value,
              ),
              const SizedBox(height: 12),
              if (widget.showLines) ...[
                _buildShimmerLine(
                  width: double.infinity,
                  height: 12,
                  offset: _shimmerController.value,
                ),
                const SizedBox(height: 8),
                _buildShimmerLine(
                  width: 200,
                  height: 12,
                  offset: _shimmerController.value,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildShimmerLine({
    required double width,
    required double height,
    required double offset,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.grey.shade300,
            Colors.grey.shade100,
            Colors.grey.shade300,
          ],
          stops: [
            offset - 0.3,
            offset,
            offset + 0.3,
          ],
        ),
      ),
    );
  }
}

/// SkeletonTable - Animated skeleton loader for table/list content
class SkeletonTable extends StatefulWidget {
  final int rowCount;
  final int columnCount;

  const SkeletonTable({
    super.key,
    this.rowCount = 3,
    this.columnCount = 4,
  });

  @override
  State<SkeletonTable> createState() => _SkeletonTableState();
}

class _SkeletonTableState extends State<SkeletonTable>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _shimmerController.repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(widget.rowCount, (rowIndex) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: List.generate(widget.columnCount, (colIndex) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: AnimatedBuilder(
                    animation: _shimmerController,
                    builder: (context, child) {
                      return Container(
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.grey.shade300,
                              Colors.grey.shade100,
                              Colors.grey.shade300,
                            ],
                            stops: [
                              _shimmerController.value - 0.3,
                              _shimmerController.value,
                              _shimmerController.value + 0.3,
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}

/// SkeletonMap - Animated skeleton loader for map/location content
class SkeletonMap extends StatefulWidget {
  final double width;
  final double height;

  const SkeletonMap({
    super.key,
    this.width = double.infinity,
    this.height = 200,
  });

  @override
  State<SkeletonMap> createState() => _SkeletonMapState();
}

class _SkeletonMapState extends State<SkeletonMap>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _shimmerController.repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
              stops: [
                _shimmerController.value - 0.3,
                _shimmerController.value,
                _shimmerController.value + 0.3,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Animated location markers
              Positioned(
                left: 30 + (_shimmerController.value * 40),
                top: 40 + (_shimmerController.value * 30),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
              Positioned(
                right: 40 + (_shimmerController.value * 30),
                bottom: 30 + (_shimmerController.value * 40),
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// PageSkeletonLoader - Combines multiple skeleton elements for page loading
class PageSkeletonLoader extends StatelessWidget {
  final List<SkeletonElement> elements;

  const PageSkeletonLoader({
    super.key,
    required this.elements,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(elements.length, (index) {
          final element = elements[index];
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < elements.length - 1 ? 16 : 0,
            ),
            child: _buildElement(element),
          );
        }),
      ),
    );
  }

  Widget _buildElement(SkeletonElement element) {
    switch (element.type) {
      case SkeletonType.card:
        return SkeletonCard(
          height: element.height ?? 150,
          showLines: element.showLines ?? true,
        );
      case SkeletonType.table:
        return SkeletonTable(
          rowCount: element.rowCount ?? 3,
          columnCount: element.columnCount ?? 4,
        );
      case SkeletonType.map:
        return SkeletonMap(height: element.height ?? 200);
    }
  }
}

enum SkeletonType { card, table, map }

class SkeletonElement {
  final SkeletonType type;
  final double? height;
  final bool? showLines;
  final int? rowCount;
  final int? columnCount;

  SkeletonElement({
    required this.type,
    this.height,
    this.showLines,
    this.rowCount,
    this.columnCount,
  });
}
