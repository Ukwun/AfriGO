import 'package:afrigo_app/presentation/providers/auth_provider.dart';
import 'package:afrigo_app/presentation/screens/user/profile_settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

AuthUser userFor(String role) => AuthUser(
      id: '$role-user',
      email: '$role@afrigo.test',
      firstName: 'Test',
      lastName: role,
      fullName: 'Test $role',
      roles: [role],
      kycStatus: 'pending',
      emailVerified: true,
      phoneVerified: false,
      trustScore: 0,
      completedTrades: 0,
    );

Widget profile(String role) => ProviderScope(
      overrides: [
        currentUserProvider.overrideWithValue(userFor(role)),
      ],
      child: const MaterialApp(home: ProfileSettingsScreen()),
    );

void main() {
  testWidgets('supplier profile shows supply operations', (tester) async {
    await tester.pumpWidget(profile('supplier'));
    await tester.pump();
    expect(find.text('Supplier profile'), findsOneWidget);
    expect(find.text('Monthly capacity (kg)'), findsOneWidget);
    expect(find.text('Primary pickup location'), findsOneWidget);
    expect(find.text('Export licence number'), findsNothing);
  });

  testWidgets('buyer profile shows procurement preferences', (tester) async {
    await tester.pumpWidget(profile('buyer'));
    await tester.pump();
    expect(find.text('Buyer profile'), findsOneWidget);
    expect(find.text('Procurement categories'), findsOneWidget);
    expect(find.text('Annual procurement volume'), findsOneWidget);
    expect(find.text('Monthly capacity (kg)'), findsNothing);
  });

  testWidgets('exporter profile shows compliance operations', (tester) async {
    await tester.pumpWidget(profile('exporter'));
    await tester.pump();
    expect(find.text('Exporter profile'), findsOneWidget);
    expect(find.text('Export licence number'), findsOneWidget);
    expect(find.text('Customs registration number'), findsOneWidget);
    expect(find.text('Procurement categories'), findsNothing);
  });
}
