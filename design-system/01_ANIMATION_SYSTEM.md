# AfriGo Animation System - Specification

> **Philosophy:** "Alive" = Responsive + Fluid + Organic. Not about speed, but about *feeling* connected to real-world events.

---

## 🎬 CORE TIMELINE ANIMATION SYSTEM

### **1. Event Entry (New Activity Appears)**

**Purpose:** New data arriving should feel like it's coming in live

```dart
// Dart/Flutter Implementation
class TimelineEventAnimation {
  static const Duration _eventEntryDuration = Duration(milliseconds: 280);
  static const Curve _eventEntryCurve = Curves.easeOutCubic;
  
  // Animation properties
  static const double _initialTranslateY = 16.0;  // Start 16px below
  static const double _initialScale = 0.96;       // Start slightly small
  static const double _initialOpacity = 0.0;      // Start invisible
}

/// Usage in AnimatedEventCard:
class AnimatedTimelineEvent extends StatefulWidget {
  final TimelineEventModel event;
  
  @override
  State<AnimatedTimelineEvent> createState() => _AnimatedTimelineEventState();
}

class _AnimatedTimelineEventState extends State<AnimatedTimelineEvent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 280),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 16),
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
          child: _buildEventCard(),
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
```

**Timing:**
- Duration: **280ms**
- Curve: **easeOutCubic** (feels smooth, not bouncy)
- Motion: Fade (0→1) + Translate Y (+16px→0) + Scale (0.96→1)

**Why This Works:**
- Fade-in signals **data arriving**
- Upward motion = **from network → to screen**
- Slight scale boost = **emphasis without jarring**
- Feels like a **live feed**, not static rendering

---

### **2. Node Activation (When a Step Completes)**

**Purpose:** Celebration moment when a lot passes QC, payment confirmed, etc.

```dart
class CompletionNodeAnimation {
  static const Duration _nodeActivationDuration = Duration(milliseconds: 220);
  
  /// Sequence of changes:
  /// 1. Circle expands (1.0 → 1.15)
  /// 2. Color transitions (gray/neutral → green)
  /// 3. Icon morphs (dot → checkmark)
  /// 4. Glow pulse added
}

class AnimatedCompletionNode extends StatefulWidget {
  final bool isCompleted;
  final Duration triggerTime;  // When does completion happen?
  
  @override
  State<AnimatedCompletionNode> createState() => _AnimatedCompletionNodeState();
}

class _AnimatedCompletionNodeState extends State<AnimatedCompletionNode>
    with TickerProviderStateMixin {
  late AnimationController _circleController;
  late AnimationController _colorController;
  late AnimationController _glowController;
  
  @override
  void initState() {
    super.initState();
    
    // Circle scale animation: 1.0 → 1.15 → 1.0
    _circleController = AnimationController(
      duration: const Duration(milliseconds: 220),
      vsync: this,
    );
    
    // Color fade to green
    _colorController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    // Glow pulse (soft ring expanding)
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    if (widget.isCompleted) {
      _circleController.forward();
      _colorController.forward();
      _glowController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow pulse (background)
        ScaleTransition(
          scale: Tween<double>(begin: 1.0, end: 2.0).animate(
            CurvedAnimation(parent: _glowController, curve: Curves.easeOut),
          ),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green.withOpacity(
                1.0 - (_glowController.value), // Fade out as it expands
              ),
            ),
          ),
        ),
        
        // Main circle (scales up during completion)
        ScaleTransition(
          scale: Tween<double>(begin: 1.0, end: 1.15).animate(
            CurvedAnimation(parent: _circleController, curve: Curves.elasticOut),
          ),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green, // or gray if not completed
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
    _circleController.dispose();
    _colorController.dispose();
    _glowController.dispose();
    super.dispose();
  }
}
```

**Timing:**
- Circle scale: **220ms**
- Color transition: **200ms**
- Glow pulse: **600ms** (longer, subtle background effect)

**Why This Works:**
- The **scale boost** gives tactile feedback
- **Color change** = status confirmation (green = success)
- **Icon morph** (dot → checkmark) = satisfying visual
- **Glow pulse** mimics a **system heartbeat** (confirms backend acknowledged)

---

### **3. Connecting Line Growth (VERY IMPORTANT)**

**Purpose:** Visual indicator of progress through journey

```dart
class TimelineConnectorLine extends StatefulWidget {
  final int totalSteps;
  final int completedSteps;
  final bool isAnimating; // Should the line animate to new height?

  @override
  State<TimelineConnectorLine> createState() => _TimelineConnectorLineState();
}

class _TimelineConnectorLineState extends State<TimelineConnectorLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _lineController;
  late Animation<double> _lineHeightAnimation;

  @override
  void initState() {
    super.initState();
    _lineController = AnimationController(
      duration: const Duration(milliseconds: 400), // easeInOut
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(TimelineConnectorLine oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // When completed steps increase, animate line growth
    if (widget.completedSteps > oldWidget.completedSteps) {
      _lineController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalHeight = widget.totalSteps * 80.0; // Adjust for your spacing
    final targetHeight = (widget.completedSteps / widget.totalSteps) * totalHeight;
    
    _lineHeightAnimation = Tween<double>(
      begin: 0,
      end: targetHeight,
    ).animate(
      CurvedAnimation(parent: _lineController, curve: Curves.easeInOut),
    );

    return AnimatedBuilder(
      animation: _lineHeightAnimation,
      builder: (context, child) {
        return Container(
          width: 2,
          height: _lineHeightAnimation.value,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF0B6E4F), // Deep green
                const Color(0xFF10B981).withOpacity(0.3), // Fade to light
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

**Timing:**
- Duration: **400ms**
- Curve: **easeInOut** (accelerate, then decelerate)

**Why This Works:**
- **Vertical growth** = progression through journey
- **Gradient fade** = continuity
- **400ms** = not too fast (feels considered), not too slow (feels alive)
- Creates sense of **unstoppable momentum**

---

### **4. Expand / Collapse Timeline**

**Purpose:** Elegant show/hide of timeline details

```dart
class ExpandableTimeline extends StatefulWidget {
  final List<TimelineEvent> events;
  
  @override
  State<ExpandableTimeline> createState() => _ExpandableTimelineState();
}

class _ExpandableTimelineState extends State<ExpandableTimeline>
    with TickerProviderStateMixin {
  late AnimationController _parentController;
  final List<AnimationController> _childControllers = [];
  
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _parentController = AnimationController(
      duration: const Duration(milliseconds: 320), // Expand slower
      vsync: this,
    );
    
    // Create controller for each child
    for (int i = 0; i < widget.events.length; i++) {
      _childControllers.add(
        AnimationController(
          duration: const Duration(milliseconds: 320),
          vsync: this,
        ),
      );
    }
  }

  void _toggleExpand() {
    setState(() => _isExpanded = !_isExpanded);
    
    if (_isExpanded) {
      // Expand: 320ms, stagger children with 40ms delay each
      _parentController.forward();
      for (int i = 0; i < _childControllers.length; i++) {
        Future.delayed(Duration(milliseconds: i * 40), () {
          _childControllers[i].forward();
        });
      }
    } else {
      // Collapse: 200ms (faster, more dismissive)
      _parentController.reverse();
      for (int i = _childControllers.length - 1; i >= 0; i--) {
        _childControllers[i].reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header / Summary
        GestureDetector(
          onTap: _toggleExpand,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Timeline (${widget.events.length} events)'),
                RotationTransition(
                  turns: Tween(begin: 0.0, end: 0.5).animate(_parentController),
                  child: const Icon(Icons.expand_more),
                ),
              ],
            ),
          ),
        ),
        
        // Expandable content
        SizeTransition(
          sizeFactor: CurvedAnimation(
            parent: _parentController,
            curve: Curves.easeInOut,
          ),
          child: Column(
            children: List.generate(
              widget.events.length,
              (index) => FadeTransition(
                opacity: _childControllers[index],
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -0.2),
                    end: Offset.zero,
                  ).animate(_childControllers[index]),
                  child: _buildEventTile(widget.events[index]),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventTile(TimelineEvent event) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF10B981),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(event.title),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _parentController.dispose();
    for (var controller in _childControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
```

**Timing:**
- Expand: **320ms** (exploratory, elegant)
- Collapse: **200ms** (quick, dismissive)
- Stagger: **40ms per child** (cascade effect)

**Why This Works:**
- Expand slower = user chose to explore (respect their intent)
- Collapse faster = user didn't want it (quick dismiss)
- Stagger creates **waterfall effect** (organically "alive")

---

### **5. Real-Time Update Pulse**

**Purpose:** Acknowledge when new backend data arrives

```dart
class RealtimeUpdatePulse extends StatefulWidget {
  final VoidCallback onPulseComplete;
  
  @override
  State<RealtimeUpdatePulse> createState() => _RealtimeUpdatePulseState();
}

class _RealtimeUpdatePulseState extends State<RealtimeUpdatePulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _pulseController.forward().then((_) {
      widget.onPulseComplete();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 1.0, end: 1.3).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
      ),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.3, end: 0.0).animate(
          CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
        ),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF10B981),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }
}
```

**Timing:**
- Duration: **600ms**
- Scale: **1.0 → 1.3**
- Opacity: **0.3 → 0** (fades out as it expands)

**Why This Works:**
- Makes the app feel **connected to reality**
- The **pulse ring** mimics a **notification/heartbeat**
- 600ms = long enough to **feel intentional**, not instant
- Happens **around the node**, not replacing it

---

### **6. Scroll Parallax (Subtle Depth)**

**Purpose:** Make timeline feel less flat, add visual depth

```dart
class TimelineWithParallax extends StatefulWidget {
  final List<TimelineEvent> events;

  @override
  State<TimelineWithParallax> createState() => _TimelineWithParallaxState();
}

class _TimelineWithParallaxState extends State<TimelineWithParallax> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: widget.events.length,
      itemBuilder: (context, index) {
        return _buildParallaxEventTile(widget.events[index], index);
      },
    );
  }

  Widget _buildParallaxEventTile(TimelineEvent event, int index) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // Update parallax offset based on scroll
        // Icons move at 0.9x scroll speed (slower than text)
        return false;
      },
      child: Stack(
        children: [
          // Icon layer (moves slower - 0.9x scroll speed)
          Positioned(
            left: 0,
            child: Container(
              width: 48,
              height: 80,
              alignment: Alignment.center,
              child: const Icon(Icons.circle, size: 20),
            ),
          ),
          
          // Text/content layer (moves at normal scroll speed)
          Padding(
            padding: const EdgeInsets.only(left: 64),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  event.timestamp,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
```

**Effect:**
- Icons move at **0.9x scroll speed** (slower than text)
- Creates subtle **depth illusion**

**Why This Works:**
- Not obvious (doesn't distract)
- Makes UI feel **less flat**
- Adds **sophistication**

---

## ⏱️ MASTER TIMING SYSTEM (FINAL)

```dart
/// Global animation timing constants
class AnimationTimings {
  // Interaction feedbacks
  static const tapFeedback = Duration(milliseconds: 120); // 120–150ms
  static const buttonPress = Duration(milliseconds: 150);
  
  // Event animations
  static const eventEntry = Duration(milliseconds: 280); // 260–300ms
  static const eventEntryFast = Duration(milliseconds: 260);
  
  // Node animations
  static const nodeActivation = Duration(milliseconds: 220); // 200–240ms
  static const nodeActivationFast = Duration(milliseconds: 200);
  
  // Expand / Collapse
  static const expandDuration = Duration(milliseconds: 320); // 300–350ms
  static const collapseDuration = Duration(milliseconds: 200); // 180–220ms
  static const childStagger = Duration(milliseconds: 40);
  
  // Line animations
  static const lineGrowth = Duration(milliseconds: 400); // 350–450ms
  static const lineFast = Duration(milliseconds: 350);
  
  // Pulse highlights
  static const pulseHighlight = Duration(milliseconds: 600); // 500–700ms
  static const pulseFast = Duration(milliseconds: 500);
  static const pulseSlow = Duration(milliseconds: 700);
}
```

| Interaction | Min | Recommended | Max |
|---|---|---|---|
| Tap feedback | 100ms | **120ms** | 150ms |
| Event entry | 260ms | **280ms** | 300ms |
| Node activation | 200ms | **220ms** | 240ms |
| Expand | 300ms | **320ms** | 350ms |
| Collapse | 180ms | **200ms** | 220ms |
| Line growth | 350ms | **400ms** | 450ms |
| Pulse highlight | 500ms | **600ms** | 700ms |

---

## ⚠️ WHAT TO AVOID (Kills the "Alive" Feel)

```dart
/// ❌ BAD: Linear animations (feels mechanical)
CurvedAnimation(parent: controller, curve: Curves.linear)

/// ✅ GOOD: Eased animations (feels organic)
CurvedAnimation(parent: controller, curve: Curves.easeOutCubic)

/// ❌ BAD: Same duration for everything
const Duration(milliseconds: 200) // for all animations

/// ✅ GOOD: Variable timing (reflects real-world)
tap: 150ms, expand: 320ms, line: 400ms, pulse: 600ms

/// ❌ BAD: Instant state changes
setState(() => status = 'complete');

/// ✅ GOOD: Animated transitions
AnimationController.forward() // with duration

/// ❌ BAD: Over-bouncy animations (elastic out)
curve: Curves.elasticOut // feels playful, not enterprise

/// ✅ GOOD: Subtle easing
curve: Curves.easeOutCubic // feels smooth, professional
```

---

## 🧠 FINAL MENTAL MODEL

Your timeline should **feel like:**

✅ A logistics control room  
✅ A live trading feed  
✅ A system that breathes  

Not like:

❌ A checklist  
❌ A static list  
❌ A boring history log  

---

## 🔥 SIMPLE RULE

**If an event happens in real life, the UI should:**

1. **Acknowledge it** (appear on screen)
2. **Animate it** (smooth transition)
3. **Confirm it** (pulse or highlight)

This makes it feel **alive**. Not fast. **Responsive.**

---

## 📋 IMPLEMENTATION CHECKLIST

- [ ] Event entry animation (fade + slide + scale)
- [ ] Node activation (scale + color + glow pulse)
- [ ] Connecting line growth (gradient, easeInOut)
- [ ] Expand/collapse (320ms expand, 200ms collapse, 40ms stagger)
- [ ] Real-time pulse (600ms scale + opacity fade)
- [ ] Scroll parallax (0.9x icon speed)
- [ ] All easing curves (never linear)
- [ ] Variable timing per interaction
- [ ] No instant state changes
- [ ] No over-bouncy animations
- [ ] Test on 60 FPS devices
- [ ] Test on lower-end devices (ensure smooth)

