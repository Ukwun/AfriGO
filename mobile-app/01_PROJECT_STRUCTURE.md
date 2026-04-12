# Flutter Project Structure - Clean Architecture

> **Pattern:** Clean Architecture (Presentation → Use Cases → Entities → Repository)  
> **State Management:** Riverpod (simple, reactive, testable)  
> **Navigation:** Go Router (declarative, type-safe)

---

## 📁 PROJECT FOLDER STRUCTURE

```
mobile_app/
├── lib/
│   ├── main.dart                                    # App entry point
│   │
│   ├── config/
│   │   ├── routes/
│   │   │   ├── app_routes.dart                      # All routes defined
│   │   │   └── route_guards.dart                    # Auth checks
│   │   │
│   │   ├── theme/
│   │   │   ├── app_theme.dart                       # ThemeData
│   │   │   ├── colors.dart                          # All color constants
│   │   │   ├── typography.dart                      # TextStyles
│   │   │   └── spacing.dart                         # Padding constants
│   │   │
│   │   └── constants/
│   │       ├── app_constants.dart
│   │       └── api_constants.dart
│   │
│   ├── data/
│   │   ├── datasources/
│   │   │   ├── remote/
│   │   │   │   ├── api_client.dart                  # HTTP client (Dio)
│   │   │   │   ├── auth_remote_datasource.dart
│   │   │   ├── lot_remote_datasource.dart
│   │   │   │   ├── marketplace_remote_datasource.dart
│   │   │   │   └── ... (one per service)
│   │   │   │
│   │   │   └── local/
│   │   │       ├── hive_local_datasource.dart       # Local caching
│   │   │       ├── shared_preferences_helper.dart
│   │   │       └── database_helper.dart
│   │   │
│   │   ├── models/
│   │   │   ├── user_model.dart
│   │   │   ├── lot_model.dart
│   │   │   ├── timeline_event_model.dart
│   │   │   ├── contract_model.dart
│   │   │   ├── shipment_model.dart
│   │   │   ├── payment_model.dart
│   │   │   └── ... (one per entity)
│   │   │
│   │   └── repositories/
│   │       ├── auth_repository.dart
│   │       ├── lot_repository.dart
│   │       ├── marketplace_repository.dart
│   │       ├── contract_repository.dart
│   │       ├── logistics_repository.dart
│   │       ├── payment_repository.dart
│   │       └── documents_repository.dart
│   │
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── user.dart
│   │   │   ├── lot.dart
│   │   │   ├── timeline_event.dart
│   │   │   ├── contract.dart
│   │   │   └── ... (pure domain objects)
│   │   │
│   │   ├── repositories/
│   │   │   ├── i_auth_repository.dart               # Interfaces
│   │   │   ├── i_lot_repository.dart
│   │   │   └── ... (one interface per service)
│   │   │
│   │   └── usecases/
│   │       ├── auth/
│   │       │   ├── register_usecase.dart
│   │       │   ├── login_usecase.dart
│   │       │   ├── logout_usecase.dart
│   │       │   └── verify_kyc_usecase.dart
│   │       │
│   │       ├── lots/
│   │       │   ├── create_lot_usecase.dart
│   │       │   ├── get_lot_details_usecase.dart
│   │       │   ├── get_lot_timeline_usecase.dart
│   │       │   ├── add_lot_event_usecase.dart
│   │       │   └── search_lots_usecase.dart
│   │       │
│   │       ├── marketplace/
│   │       │   ├── post_rfq_usecase.dart
│   │       │   ├── submit_bid_usecase.dart
│   │       │   └── get_rfq_comparison_usecase.dart
│   │       │
│   │       └── ... (one folder per service)
│   │
│   ├── presentation/
│   │   ├── providers/
│   │   │   ├── app_state_provider.dart              # Global state (Riverpod)
│   │   │   ├── auth_provider.dart
│   │   │   ├── lot_provider.dart
│   │   │   ├── marketplace_provider.dart
│   │   │   ├── contract_provider.dart
│   │   │   ├── logistics_provider.dart
│   │   │   ├── payment_provider.dart
│   │   │   └── notification_provider.dart
│   │   │
│   │   ├── screens/
│   │   │   ├── splash/
│   │   │   │   ├── splash_screen.dart
│   │   │   │   └── splash_provider.dart
│   │   │   │
│   │   │   ├── onboarding/
│   │   │   │   ├── onboarding_screen.dart
│   │   │   │   └── onboarding_pages/
│   │   │   │       └── page_*.dart
│   │   │   │
│   │   │   ├── auth/
│   │   │   │   ├── login_screen.dart
│   │   │   │   ├── register_screen.dart
│   │   │   │   ├── otp_verification_screen.dart
│   │   │   │   ├── kyc_upload_screen.dart
│   │   │   │   └── auth_provider.dart
│   │   │   │
│   │   │   ├── dashboard/
│   │   │   │   ├── dashboard_screen.dart            # Role-based
│   │   │   │   ├── supplier_dashboard.dart
│   │   │   │   ├── buyer_dashboard.dart
│   │   │   │   ├── widgets/
│   │   │   │   │   ├── dashboard_card.dart
│   │   │   │   │   ├── kpi_widget.dart
│   │   │   │   │   └── activity_feed_widget.dart
│   │   │   │   └── dashboard_provider.dart
│   │   │   │
│   │   │   ├── lots/
│   │   │   │   ├── lots_list_screen.dart
│   │   │   │   ├── lot_details_screen.dart
│   │   │   │   ├── lot_creation_screen.dart
│   │   │   │   ├── timeline/
│   │   │   │   │   ├── timeline_screen.dart
│   │   │   │   │   ├── timeline_widget.dart
│   │   │   │   │   ├── animated_timeline_event.dart  # Animation
│   │   │   │   │   └── timeline_animations.dart
│   │   │   │   └── lots_provider.dart
│   │   │   │
│   │   │   ├── marketplace/
│   │   │   │   ├── rfq_list_screen.dart
│   │   │   │   ├── rfq_details_screen.dart
│   │   │   │   ├── rfq_creation_screen.dart
│   │   │   │   ├── bid_submission_screen.dart
│   │   │   │   ├── bid_comparison_screen.dart
│   │   │   │   └── marketplace_provider.dart
│   │   │   │
│   │   │   ├── contracts/
│   │   │   │   ├── contracts_list_screen.dart
│   │   │   │   ├── contract_viewer_screen.dart
│   │   │   │   ├── signature_screen.dart
│   │   │   │   └── contracts_provider.dart
│   │   │   │
│   │   │   ├── logistics/
│   │   │   │   ├── shipments_list_screen.dart
│   │   │   │   ├── shipment_tracker_screen.dart
│   │   │   │   ├── tracking_map_widget.dart
│   │   │   │   └── logistics_provider.dart
│   │   │   │
│   │   │   ├── payments/
│   │   │   │   ├── payment_summary_screen.dart
│   │   │   │   ├── payment_status_screen.dart
│   │   │   │   └── payments_provider.dart
│   │   │   │
│   │   │   └── common/
│   │   │       ├── bottom_nav_screen.dart
│   │   │       ├── notification_center_screen.dart
│   │   │       └── settings_screen.dart
│   │   │
│   │   └── widgets/
│   │       ├── common/
│   │       │   ├── app_bar.dart
│   │       │   ├── bottom_sheet.dart
│   │       │   ├── loading_skeleton.dart
│   │       │   ├── error_widget.dart
│   │       │   └── empty_state_widget.dart
│   │       │
│   │       ├── buttons/
│   │       │   ├── primary_button.dart
│   │       │   ├── secondary_button.dart
│   │       │   ├── ghost_button.dart
│   │       │   └── destructive_button.dart
│   │       │
│   │       ├── forms/
│   │       │   ├── text_input_field.dart
│   │       │   ├── dropdown_field.dart
│   │       │   ├── date_picker_field.dart
│   │       │   └── multi_select_field.dart
│   │       │
│   │       ├── cards/
│   │       │   ├── event_card.dart
│   │       │   ├── lot_card.dart
│   │       │   ├── contract_card.dart
│   │       │   └── shipment_card.dart
│   │       │
│   │       └── status/
│   │           ├── status_badge.dart
│   │           ├── status_timeline.dart
│   │           └── progress_indicator.dart
│   │
│   ├── utils/
│   │   ├── firebase_service.dart
│   │   ├── notification_service.dart
│   │   ├── connectivity_service.dart            # Offline support
│   │   ├── date_formatter.dart
│   │   ├── currency_formatter.dart
│   │   ├── validation_utils.dart
│   │   └── logger_utils.dart
│   │
│   └── app.dart                                # Main app widget
│
├── test/
│   ├── unit/
│   │   ├── entities/
│   │   ├── usecases/
│   │   └── repositories/
│   │
│   ├── widget/
│   │   ├── screens/
│   │   └── widgets/
│   │
│   └── integration/
│       └── app_flow_test.dart
│
├── pubspec.yaml
├── pubspec.lock
├── analysis_options.yaml
├── .env.example
└── README.md
```

---

## 🏗️ KEY DEPENDENCIES (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management & Dependency Injection
  riverpod: ^2.4.0
  flutter_riverpod: ^2.4.0
  riverpod_generator: ^2.3.0

  # Navigation
  go_router: ^12.0.0

  # HTTP Client
  dio: ^5.3.0
  pretty_dio_logger: ^1.3.0

  # Firebase
  firebase_core: ^2.24.0
  firebase_auth: ^4.16.0
  firebase_database: ^10.4.0
  firebase_messaging: ^14.6.0

  # Local Storage
  hive: ^2.2.0
  hive_flutter: ^1.1.0
  shared_preferences: ^2.2.0

  # UI & Animations
  flutter_animate: ^4.1.0
  animations: ^2.0.0
  shimmer: ^3.0.0

  # Forms & Validation
  formz: ^0.6.0

  # JSON Serialization
  json_serializable: ^6.7.0

  # Utils
  intl: ^0.18.0
  uuid: ^4.0.0
  logger: ^2.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  build_runner: ^2.4.0
  riverpod_generator: ^2.3.0
  mockito: ^5.4.0
  integration_test:
    sdk: flutter
```

---

## 🎬 ANIMATION WIDGETS (From Design System)

```dart
// lib/presentation/widgets/animations/timeline_animations.dart

import 'package:flutter/material.dart';

/// 1. Event Entry Animation (Fade + Slide + Scale)
class AnimatedEventEntry extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const AnimatedEventEntry({
    required this.child,
    this.duration = const Duration(milliseconds: 280),
  });

  @override
  State<AnimatedEventEntry> createState() => _AnimatedEventEntryState();
}

class _AnimatedEventEntryState extends State<AnimatedEventEntry>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _scaleAnimation = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: widget.child,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// 2. Node Completion Animation (Scale + Color + Pulse)
class AnimatedCompletionNode extends StatefulWidget {
  final bool isCompleted;
  final Duration completionDuration;

  const AnimatedCompletionNode({
    required this.isCompleted,
    this.completionDuration = const Duration(milliseconds: 220),
  });

  @override
  State<AnimatedCompletionNode> createState() => _AnimatedCompletionNodeState();
}

class _AnimatedCompletionNodeState extends State<AnimatedCompletionNode>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _colorController;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: widget.completionDuration,
      vsync: this,
    );
    _colorController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    if (widget.isCompleted) {
      Future.microtask(() {
        _scaleController.forward();
        _colorController.forward();
        _glowController.forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow pulse
        ScaleTransition(
          scale: Tween<double>(begin: 1.0, end: 2.0).animate(
            CurvedAnimation(parent: _glowController, curve: Curves.easeOut),
          ),
          child: Opacity(
            opacity: 1.0 - _glowController.value,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF10B981),
              ),
            ),
          ),
        ),
        // Node circle
        ScaleTransition(
          scale: Tween<double>(begin: 1.0, end: 1.15).animate(
            CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
          ),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.isCompleted
                  ? const Color(0xFF22C55E)
                  : Colors.grey[300],
            ),
            child: Icon(
              widget.isCompleted ? Icons.check : Icons.circle,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _colorController.dispose();
    _glowController.dispose();
    super.dispose();
  }
}

/// 3. Timeline Connector Line Growth
class TimelineConnectorLine extends StatefulWidget {
  final int totalSteps;
  final int completedSteps;

  const TimelineConnectorLine({
    required this.totalSteps,
    required this.completedSteps,
  });

  @override
  State<TimelineConnectorLine> createState() => _TimelineConnectorLineState();
}

class _TimelineConnectorLineState extends State<TimelineConnectorLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _lineController;

  @override
  void initState() {
    super.initState();
    _lineController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(TimelineConnectorLine oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.completedSteps > oldWidget.completedSteps) {
      _lineController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalHeight = widget.totalSteps * 80.0;
    final targetHeight = (widget.completedSteps / widget.totalSteps) * totalHeight;

    return AnimatedBuilder(
      animation: _lineController,
      builder: (context, child) {
        final currentHeight =
            targetHeight * _lineController.value;
        return Container(
          width: 2,
          height: currentHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF0B6E4F),
                const Color(0xFF10B981).withOpacity(0.3),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _lineController.dispose();
    super.dispose();
  }
}
```

---

## 📝 Example: Lot Details Screen (Riverpod)

```dart
// lib/presentation/screens/lots/lot_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LotDetailsScreen extends ConsumerWidget {
  final String lotId;

  const LotDetailsScreen({required this.lotId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lotAsync = ref.watch(getLotDetailsProvider(lotId));
    final timelineAsync = ref.watch(getLotTimelineProvider(lotId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lot Details'),
        elevation: 0,
      ),
      body: lotAsync.when(
        data: (lot) => SingleChildScrollView(
          child: Column(
            children: [
              // Lot header card
              LotHeaderCard(lot: lot),
              
              // Timeline section
              timelineAsync.when(
                data: (events) => TimelineWidget(events: events),
                loading: () => const SizedBox(
                  height: 300,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, st) => ErrorWidget(error: e.toString()),
              ),
              
              // Actions
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () => context.push('/lots/$lotId/add-event'),
                  child: const Text('Add Event'),
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => ErrorWidget(error: e.toString()),
      ),
    );
  }
}

// Provider for lot details
final getLotDetailsProvider = FutureProvider.family<Lot, String>((ref, lotId) async {
  final lotRepository = ref.watch(lotRepositoryProvider);
  return lotRepository.getLotDetails(lotId);
});

// Provider for timeline events
final getLotTimelineProvider = FutureProvider.family<List<TimelineEvent>, String>(
  (ref, lotId) async {
    final lotRepository = ref.watch(lotRepositoryProvider);
    return lotRepository.getLotTimeline(lotId);
  },
);
```

---

## ✅ FLUTTER PROJECT CHECKLIST

- [ ] Project structure created
- [ ] Dependencies installed (pubspec.yaml)
- [ ] Theme system configured (colors, typography)
- [ ] Riverpod providers set up
- [ ] Go Router navigation configured
- [ ] Firebase Auth integrated
- [ ] HTTP client (Dio) configured
- [ ] Local storage (Hive) set up
- [ ] All animation widgets created
- [ ] Reusable components created
- [ ] Error handling implemented
- [ ] Offline support framework
- [ ] Tests written (unit + widget + integration)

