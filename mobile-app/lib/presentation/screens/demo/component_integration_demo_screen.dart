import 'package:flutter/material.dart';
import '../../../config/colors.dart';
import '../../widgets/modern_card.dart';
import '../../widgets/animated_button.dart';

/// Comprehensive Component Integration Demo Screen
/// Shows all AfriGo UI components working together in realistic scenarios
class ComponentIntegrationDemoScreen extends StatefulWidget {
  const ComponentIntegrationDemoScreen({super.key});

  @override
  State<ComponentIntegrationDemoScreen> createState() =>
      _ComponentIntegrationDemoScreenState();
}

class _ComponentIntegrationDemoScreenState
    extends State<ComponentIntegrationDemoScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Component Integration Demo'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== BUTTON STYLES SECTION =====
            const SectionTitle('Button Styles'),
            const SizedBox(height: 12),

            // Primary Buttons
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Primary Buttons (Filled)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  AnimatedPrimaryButton(
                    label: 'Normal Button',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Primary button pressed! ✓'),
                          duration: Duration(milliseconds: 1500),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  AnimatedPrimaryButton(
                    label: 'Large Touch Target (56px)',
                    onPressed: () {},
                    isLargeTouchTarget: true,
                  ),
                  const SizedBox(height: 8),
                  AnimatedPrimaryButton(
                    label: 'Loading State',
                    onPressed: () {
                      setState(() => _isLoading = !_isLoading);
                    },
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 8),
                  AnimatedPrimaryButton(
                    label: 'Disabled',
                    onPressed: () {},
                    isEnabled: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Secondary (Outlined) Buttons
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Secondary Buttons (Outlined)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  AnimatedOutlinedButton(
                    label: 'Normal Button',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Secondary button pressed! ✓'),
                          duration: Duration(milliseconds: 1500),
                        ),
                      );
                    },
                    borderColor: AppColors.primaryGreen,
                    textColor: AppColors.primaryGreen,
                  ),
                  const SizedBox(height: 8),
                  AnimatedOutlinedButton(
                    label: 'Large Touch Target (56px)',
                    onPressed: () {},
                    borderColor: AppColors.secondaryGold,
                    textColor: AppColors.secondaryGold,
                    isLargeTouchTarget: true,
                  ),
                  const SizedBox(height: 8),
                  AnimatedOutlinedButton(
                    label: 'Accent Color Variant',
                    onPressed: () {},
                    borderColor: AppColors.accentBlue,
                    textColor: AppColors.accentBlue,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tertiary (Text-only) Buttons
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tertiary Buttons (Text-Only)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  AnimatedTextButton(
                    label: 'Learn More',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Text button pressed! ✓'),
                          duration: Duration(milliseconds: 1500),
                        ),
                      );
                    },
                    textColor: AppColors.primaryGreen,
                  ),
                  const SizedBox(height: 8),
                  AnimatedTextButton(
                    label: 'Large Touch Target (56px)',
                    onPressed: () {},
                    textColor: AppColors.accentBlue,
                    isLargeTouchTarget: true,
                  ),
                  const SizedBox(height: 8),
                  AnimatedTextButton(
                    label: 'Tertiary Action',
                    onPressed: () {},
                    textColor: AppColors.secondaryGold,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ===== CARD STYLES SECTION =====
            const SectionTitle('Card Styles'),
            const SizedBox(height: 12),

            // Modern Card
            ModernCard(
              borderRadius: 16,
              isFloating: true,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Card tapped! (Floats on hover)'),
                    duration: Duration(milliseconds: 1500),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Modern Card with Floating Effect',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      fontFamily: 'Sora',
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Hover over this card to see it float upward with smooth animation. Elevation increases and shadow deepens.',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AnimatedTextButton(
                        label: 'Dismiss',
                        onPressed: () {},
                        textColor: Colors.grey,
                      ),
                      AnimatedTextButton(
                        label: 'View More',
                        onPressed: () {},
                        textColor: AppColors.accentBlue,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Layered Card
            LayeredCard(
              layers: 2,
              layerOffset: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Layered Card - Visual Depth',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      fontFamily: 'Sora',
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Multiple background layers create a premium, elevated appearance. Perfect for featured content.',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Floating Panel
            FloatingPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Floating Panel - Continuous Animation',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      fontFamily: 'Sora',
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Gently floats in place with continuous animation. Great for emphasis and attention-drawing.',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ===== REAL-WORLD INTEGRATION EXAMPLE =====
            const SectionTitle('Real-World Integration Example'),
            const SizedBox(height: 12),

            // Example: Product Card
            ModernCard(
              borderRadius: 16,
              isFloating: true,
              onTap: () {},
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image Placeholder
                  Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(16)),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primaryGreen.withOpacity(0.3),
                          AppColors.secondaryGold.withOpacity(0.2),
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.shopping_bag_outlined,
                        size: 48,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  // Product Details
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Premium Cocoa Beans',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                fontFamily: 'Sora',
                              ),
                            ),
                            Chip(
                              label: Text(
                                '⭐ 4.8',
                                style: TextStyle(fontSize: 11),
                              ),
                              backgroundColor: Colors.amber,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '\$45.00 per bag | 500 bags available',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: AnimatedOutlinedButton(
                                label: 'More Info',
                                onPressed: () {},
                                borderColor: AppColors.primaryGreen,
                                textColor: AppColors.primaryGreen,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: AnimatedPrimaryButton(
                                label: 'Order Now',
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Order initiated! ✓'),
                                      duration: Duration(milliseconds: 1500),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Animation Timing Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '⚡ Animation Specifications',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF1E88E5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Buttons: 200ms smooth scale animation\n'
                    '• Primary: 1.0 → 0.96 scale on press\n'
                    '• Cards: 300ms float effect on hover\n'
                    '• Floating panels: 2000ms continuous gentle float\n'
                    '• All use CurvedAnimation for natural motion\n'
                    '• Real-time responsiveness on all interactions',
                    style: TextStyle(fontSize: 11, height: 1.6),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

/// Section title widget for organizing demo content
class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        fontFamily: 'Sora',
      ),
    );
  }
}
