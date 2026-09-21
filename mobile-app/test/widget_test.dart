import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:afrigo_app/presentation/screens/onboarding/splash_screen_modern.dart';

void main() {
  testWidgets('Splash screen presents the AfriGO brand',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreenModern()));

    expect(find.text('AfriGo'), findsOneWidget);
  });
}
