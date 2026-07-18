// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/services/api_client.dart';
import '../../data/services/auth_service.dart';

/// Auth State Management with Riverpod
/// Manages user authentication state using Backend API

/// User model matching backend response
class AuthUser {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String fullName;
  final List<String> roles;
  final String kycStatus;
  final bool emailVerified;
  final bool phoneVerified;
  final int trustScore;
  final int completedTrades;

  AuthUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.roles,
    required this.kycStatus,
    required this.emailVerified,
    required this.phoneVerified,
    required this.trustScore,
    required this.completedTrades,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      fullName: json['fullName'] ?? '',
      roles: List<String>.from(json['roles'] ?? []),
      kycStatus: json['kycStatus'] ?? 'pending',
      emailVerified: json['emailVerified'] ?? false,
      phoneVerified: json['phoneVerified'] ?? false,
      trustScore: (json['trustScore'] is int)
          ? json['trustScore'] as int
          : (json['trustScore'] as num?)?.toInt() ?? 0,
      completedTrades: (json['completedTrades'] is int)
          ? json['completedTrades'] as int
          : (json['completedTrades'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Auth state (no auth, loading, authenticated, error)
sealed class AuthState {
  const AuthState();
}

class AuthIdle extends AuthState {
  const AuthIdle();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final AuthUser user;
  final String token;

  const AuthAuthenticated({
    required this.user,
    required this.token,
  });
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Auth Notifier - handles auth logic using Backend API
class AuthNotifier extends StateNotifier<AuthState> {
  final apiClient = ApiClient();
  final authService = AuthService();

  AuthNotifier() : super(const AuthLoading()) {
    restoreSession();
  }

  Future<void> restoreSession() async {
    final firebaseUser = authService.currentUser;
    if (firebaseUser == null) {
      state = const AuthUnauthenticated();
      return;
    }
    try {
      await _establishBackendSession(firebaseUser);
    } catch (_) {
      state = const AuthUnauthenticated();
    }
  }

  Future<void> _establishBackendSession(
    dynamic firebaseUser, {
    Map<String, dynamic>? profile,
    bool forceRefresh = false,
  }) async {
    final idToken = await firebaseUser.getIdToken(forceRefresh);
    if (idToken == null) throw Exception('Could not create secure session');
    await apiClient.setToken(idToken);
    final userData = await _firebaseProfile(firebaseUser, profile: profile);
    state =
        AuthAuthenticated(user: AuthUser.fromJson(userData), token: idToken);
    unawaited(_syncBackendSession(idToken, profile));
  }

  Future<void> _syncBackendSession(
    String idToken,
    Map<String, dynamic>? profile,
  ) async {
    try {
      await apiClient.post('/auth/session', body: {
        'idToken': idToken,
        if (profile != null) 'profile': profile,
      }).timeout(const Duration(seconds: 5));
    } catch (_) {
      // Firestore is the available identity source while Functions are offline.
      // Backend synchronization is retried on the next authenticated launch.
    }
  }

  Future<Map<String, dynamic>> _firebaseProfile(
    dynamic firebaseUser, {
    Map<String, dynamic>? profile,
  }) async {
    final reference = FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser.uid as String);
    if (profile != null) {
      final role = _canonicalRole(profile['role']?.toString());
      await reference.set({
        'id': firebaseUser.uid,
        'email': firebaseUser.email ?? profile['email'] ?? '',
        'firstName': profile['firstName'] ?? '',
        'lastName': profile['lastName'] ?? '',
        'fullName':
            '${profile['firstName'] ?? ''} ${profile['lastName'] ?? ''}'.trim(),
        'roles': [role],
        'role': role,
        'accountStatus': 'active',
        'kycStatus': 'pending',
        'emailVerified': firebaseUser.emailVerified == true,
        'phoneVerified': firebaseUser.phoneNumber != null,
        'trustScore': 0,
        'completedTrades': 0,
        'participantIds': [firebaseUser.uid],
        'updatedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
    var snapshot = await reference.get();
    if (!snapshot.exists) {
      if (profile == null) {
        throw Exception(
          'Your account setup is incomplete. Use Create account to select buyer, supplier, or exporter.',
        );
      }
      final names = (firebaseUser.displayName?.toString() ?? '')
          .trim()
          .split(RegExp(r'\s+'));
      final firstName = names.isEmpty ? '' : names.first;
      final lastName = names.length < 2 ? '' : names.skip(1).join(' ');
      await reference.set({
        'id': firebaseUser.uid,
        'email': firebaseUser.email ?? '',
        'firstName': firstName,
        'lastName': lastName,
        'fullName': firebaseUser.displayName ?? '',
        'roles': [_canonicalRole(profile['role']?.toString())],
        'role': _canonicalRole(profile['role']?.toString()),
        'accountStatus': 'active',
        'kycStatus': 'pending',
        'emailVerified': firebaseUser.emailVerified == true,
        'phoneVerified': firebaseUser.phoneNumber != null,
        'trustScore': 0,
        'completedTrades': 0,
        'participantIds': [firebaseUser.uid],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      snapshot = await reference.get();
    }
    final data = snapshot.data()!;
    final storedRole = data['role']?.toString().toLowerCase();
    if (!const {'buyer', 'supplier', 'exporter'}.contains(storedRole)) {
      throw Exception(
          'This account has an invalid role. Contact AfriGO support.');
    }
    if ((data['accountStatus'] ?? 'active').toString().toLowerCase() !=
        'active') {
      throw Exception('This account is not active. Contact AfriGO support.');
    }
    return {
      'id': snapshot.id,
      ...data,
      'role': storedRole,
      'roles': [storedRole],
    };
  }

  String _canonicalRole(String? role) => switch (role?.toLowerCase()) {
        'supplier' || 'seller' || 'farmer' => 'supplier',
        'exporter' => 'exporter',
        _ => 'buyer',
      };

  /// REGISTER with Email & Password
  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String role = 'buyer',
    String? phone,
    String? organizationName,
    String? countryCode,
  }) async {
    state = const AuthLoading();

    try {
      final normalizedEmail = email.trim().toLowerCase();
      print('[AuthNotifier] Registering: $normalizedEmail');

      final firebaseUser = await authService.registerWithEmail(
        email: normalizedEmail,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        organization: organizationName,
        countryCode: countryCode,
      );
      await _establishBackendSession(
        firebaseUser,
        profile: {
          'email': normalizedEmail,
          'firstName': firstName,
          'lastName': lastName,
          'role': role,
          if (phone != null) 'phone': phone,
          if (organizationName != null) 'organization': organizationName,
          if (countryCode != null) 'countryCode': countryCode,
        },
      );
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      state = AuthError(errorMsg);
      print('[AuthNotifier] Registration error: $errorMsg');
    }
  }

  /// LOGIN with Email & Password
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AuthLoading();

    try {
      final normalizedEmail = email.trim().toLowerCase();
      print('[AuthNotifier] Logging in: $normalizedEmail');

      final firebaseUser = await authService.loginWithEmail(
        email: normalizedEmail,
        password: password,
      );
      await _establishBackendSession(firebaseUser);
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      state = AuthError(errorMsg);
      print('[AuthNotifier] Login error: $errorMsg');
    }
  }

  Future<void> loginWithGoogle({String? role}) async {
    state = const AuthLoading();
    try {
      final user = await authService.loginWithGoogle();
      await _establishBackendSession(user,
          profile: role == null ? null : {'role': role});
    } catch (e) {
      state = AuthError(e.toString());
      print('[AuthNotifier] Google login error: $e');
    }
  }

  Future<void> loginWithFacebook({String? role}) async {
    state = const AuthLoading();
    try {
      final user = await authService.loginWithFacebook();
      await _establishBackendSession(user,
          profile: role == null ? null : {'role': role});
    } catch (e) {
      state = AuthError(e.toString());
      print('[AuthNotifier] Facebook login error: $e');
    }
  }

  Future<void> loginWithApple({String? role}) async {
    state = const AuthLoading();
    try {
      final user = await authService.loginWithApple();
      await _establishBackendSession(user,
          profile: role == null ? null : {'role': role});
    } catch (e) {
      state = AuthError(e.toString());
      print('[AuthNotifier] Apple login error: $e');
    }
  }

  /// LOGOUT
  Future<void> logout() async {
    try {
      await authService.logout();
      await apiClient.logout();
      state = const AuthUnauthenticated();
      print('[AuthNotifier] Logged out');
    } catch (e) {
      print('[AuthNotifier] Logout error: $e');
      state = const AuthUnauthenticated();
    }
  }
}

/// Riverpod Providers

/// Auth State Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

/// Convenience provider: Is user authenticated?
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider) is AuthAuthenticated;
});

/// Convenience provider: Get current user
final currentUserProvider = Provider<AuthUser?>((ref) {
  final state = ref.watch(authProvider);
  if (state is AuthAuthenticated) {
    return state.user;
  }
  return null;
});

/// Convenience provider: Get access token
final accessTokenProvider = Provider<String?>((ref) {
  final state = ref.watch(authProvider);
  if (state is AuthAuthenticated) {
    return state.token;
  }
  return null;
});
