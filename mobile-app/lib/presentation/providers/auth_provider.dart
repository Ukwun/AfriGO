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

  static String _normalizeRole(String? input) {
    final value = (input ?? '').trim().toLowerCase();
    if (value.isEmpty) return 'buyer';
    switch (value) {
      case 'supplier':
      case 'seller':
      case 'farmer':
      case 'producer':
        return 'supplier';
      case 'exporter':
      case 'export':
      case 'member':
        return 'exporter';
      case 'buyer':
      case 'wholesale_buyer':
      case 'wholesale buyer':
      case 'importer':
      case 'procurement':
        return 'buyer';
      default:
        return 'buyer';
    }
  }

  static String _canonicalRoleFromCandidates(Iterable<String> candidates) {
    const orderedPriority = ['supplier', 'exporter', 'buyer'];
    for (final role in orderedPriority) {
      if (candidates.any((candidate) => _normalizeRole(candidate) == role)) {
        return role;
      }
    }
    return 'buyer';
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final rawRoles = <String>[];
    final rawRoleValue = json['role'];
    if (rawRoleValue != null) rawRoles.add(rawRoleValue.toString());
    final profileRole = json['profile'];
    if (profileRole is Map && profileRole['role'] != null) {
      rawRoles.add(profileRole['role'].toString());
    }
    final rolesValue = json['roles'];
    if (rolesValue is Iterable) {
      rawRoles.addAll(rolesValue.map((entry) => entry?.toString() ?? ''));
    }
    final canonicalRole = _canonicalRoleFromCandidates(rawRoles);

    return AuthUser(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      fullName: json['fullName'] ?? '',
      roles: [canonicalRole],
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
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _profileSub;
  // Keep an explicit onboarding selection authoritative until Firestore has
  // emitted the updated profile snapshot.
  String? _pendingRole;

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
      await _establishBackendSession(firebaseUser, forceRefresh: true).timeout(
        const Duration(seconds: 8),
        onTimeout: () =>
            throw TimeoutException('Session restoration timed out'),
      );
    } catch (error) {
      // Firebase already has a valid session. Keep the user in the app while
      // Firestore/API profile data catches up instead of redirecting to login.
      state = AuthAuthenticated(
        user: AuthUser(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          firstName: _displayNameParts(firebaseUser.displayName).$1,
          lastName: _displayNameParts(firebaseUser.displayName).$2,
          fullName: firebaseUser.displayName ?? '',
          roles: const ['buyer'],
          kycStatus: 'pending',
          emailVerified: firebaseUser.emailVerified,
          phoneVerified: firebaseUser.phoneNumber != null,
          trustScore: 0,
          completedTrades: 0,
        ),
        token: '',
      );
      print('[AuthNotifier] Session profile deferred: $error');
    }
  }

  (String, String) _displayNameParts(String? displayName) {
    final parts = (displayName ?? '').trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return ('', '');
    return (parts.first, parts.length > 1 ? parts.skip(1).join(' ') : '');
  }

  Future<void> _establishBackendSession(
    dynamic firebaseUser, {
    Map<String, dynamic>? profile,
    bool forceRefresh = false,
  }) async {
    final idToken = await firebaseUser
        .getIdToken(forceRefresh)
        .timeout(const Duration(seconds: 5));
    if (idToken == null) throw Exception('Could not create secure session');
    await apiClient.setToken(idToken);
    final userData = await _firebaseProfile(firebaseUser, profile: profile);
    state =
        AuthAuthenticated(user: AuthUser.fromJson(userData), token: idToken);
    _watchProfile(firebaseUser.uid as String, idToken);
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
    var snapshot = await _readProfile(reference);
    if (!snapshot.exists) {
      // Firebase Auth can outlive a failed profile write (for example after
      // the app is backgrounded during signup). Recover that account instead
      // of turning every launch into an auth redirect loop.
      final recoveryProfile =
          profile ?? const <String, dynamic>{'role': 'buyer'};
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
        'roles': [_canonicalRole(recoveryProfile['role']?.toString())],
        'role': _canonicalRole(recoveryProfile['role']?.toString()),
        'roleSelectionPending': true,
        'accountStatus': 'active',
        'kycStatus': 'pending',
        'emailVerified': firebaseUser.emailVerified == true,
        'phoneVerified': firebaseUser.phoneNumber != null,
        'trustScore': 0,
        'completedTrades': 0,
        'participantIds': [firebaseUser.uid],
        if (recoveryProfile['phone'] != null &&
            recoveryProfile['phone'].toString().trim().isNotEmpty)
          'phone': recoveryProfile['phone'].toString().trim(),
        if (recoveryProfile['organization'] != null &&
            recoveryProfile['organization'].toString().trim().isNotEmpty)
          'organization': recoveryProfile['organization'].toString().trim(),
        if (recoveryProfile['countryCode'] != null &&
            recoveryProfile['countryCode'].toString().trim().isNotEmpty)
          'countryCode': recoveryProfile['countryCode'].toString().trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      snapshot = await _readProfile(reference);
    }
    final data = snapshot.data()!;
    final storedRole = _storedRole(data);
    if (storedRole == null) {
      throw Exception(
          'This account has an invalid role. Contact AfriGO support.');
    }
    if (!_isActiveAccount(data)) {
      throw Exception('This account is not active. Contact AfriGO support.');
    }
    return {
      'id': snapshot.id,
      ...data,
      'role': storedRole,
      'roles': [storedRole],
    };
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _readProfile(
    DocumentReference<Map<String, dynamic>> reference,
  ) async {
    try {
      return await reference
          .get(const GetOptions(source: Source.serverAndCache))
          .timeout(const Duration(seconds: 5));
    } on TimeoutException {
      return reference.get(const GetOptions(source: Source.cache));
    } on FirebaseException {
      return reference.get(const GetOptions(source: Source.cache));
    }
  }

  void _watchProfile(String userId, String token) {
    _profileSub?.cancel();
    _profileSub = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return;
      try {
        final data = snapshot.data()!;
        final role = _storedRole(data);
        if (role == null) return;
        if (_pendingRole != null && role != _pendingRole) return;
        if (_pendingRole == role) _pendingRole = null;
        if (!_isActiveAccount(data)) {
          state = const AuthError(
            'This account is not active. Contact AfriGO support.',
          );
          return;
        }
        state = AuthAuthenticated(
          user: AuthUser.fromJson({
            'id': snapshot.id,
            ...data,
            'role': role,
            'roles': [role],
          }),
          token: token,
        );
      } catch (_) {
        // Keep the last verified session visible if a non-critical profile
        // field written by another client is malformed.
      }
    });
  }

  String? _storedRole(Map<String, dynamic> data) {
    final nestedProfile = data['profile'];
    final candidates = <Object?>[
      data['role'],
      data['primaryRole'],
      data['userRole'],
      data['userType'],
      data['accountType'],
      if (nestedProfile is Map) nestedProfile['role'],
      if (nestedProfile is Map) nestedProfile['userType'],
    ];
    final roles = data['roles'];
    if (roles is Iterable) candidates.addAll(roles);
    final normalized = <String>[];
    for (final candidate in candidates) {
      final value = candidate?.toString();
      if (value == null || value.trim().isEmpty) continue;
      normalized.add(value);
    }
    if (normalized.isEmpty) return null;

    const orderedPriority = ['supplier', 'exporter', 'buyer'];
    for (final role in orderedPriority) {
      if (normalized
          .any((candidate) => _canonicalStoredRole(candidate) == role)) {
        return role;
      }
    }
    return _canonicalStoredRole(normalized.first);
  }

  String? _canonicalStoredRole(String? value) {
    return switch (value?.trim().toLowerCase()) {
      'buyer' ||
      'wholesale_buyer' ||
      'wholesale buyer' ||
      'importer' ||
      'procurement' =>
        'buyer',
      'supplier' || 'seller' || 'farmer' || 'producer' => 'supplier',
      'exporter' || 'export' || 'member' => 'exporter',
      _ => null,
    };
  }

  bool _isActiveAccount(Map<String, dynamic> data) {
    final status = (data['accountStatus'] ?? data['status'] ?? 'active')
        .toString()
        .trim()
        .toLowerCase();
    if (data['isActive'] == false || data['disabled'] == true) return false;
    return !const {'disabled', 'suspended', 'inactive', 'blocked', 'deleted'}
        .contains(status);
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
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedRole = _canonicalRole(role);

    try {
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
          'role': normalizedRole,
          if (phone != null) 'phone': phone,
          if (organizationName != null) 'organization': organizationName,
          if (countryCode != null) 'countryCode': countryCode,
        },
      );
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      final firebaseUser = authService.currentUser;
      if (firebaseUser != null) {
        try {
          state = AuthAuthenticated(
            user: AuthUser(
              id: firebaseUser.uid,
              email: normalizedEmail,
              firstName: firstName,
              lastName: lastName,
              fullName: '$firstName $lastName'.trim(),
              roles: [normalizedRole],
              kycStatus: 'pending',
              emailVerified: firebaseUser.emailVerified,
              phoneVerified: firebaseUser.phoneNumber != null,
              trustScore: 0,
              completedTrades: 0,
            ),
            token: '',
          );
          print('[AuthNotifier] Registration profile sync deferred: $errorMsg');
          return;
        } catch (recoveryError) {
          print('[AuthNotifier] Registration recovery failed: $recoveryError');
        }
      }
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
    final normalizedEmail = email.trim().toLowerCase();

    try {
      print('[AuthNotifier] Logging in: $normalizedEmail');

      final firebaseUser = await authService.loginWithEmail(
        email: normalizedEmail,
        password: password,
      );
      await _establishBackendSession(firebaseUser);
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      final firebaseUser = authService.currentUser;
      if (firebaseUser != null) {
        state = AuthAuthenticated(
          user: AuthUser(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? normalizedEmail,
            firstName: _displayNameParts(firebaseUser.displayName).$1,
            lastName: _displayNameParts(firebaseUser.displayName).$2,
            fullName: firebaseUser.displayName ?? '',
            roles: const ['buyer'],
            kycStatus: 'pending',
            emailVerified: firebaseUser.emailVerified,
            phoneVerified: firebaseUser.phoneNumber != null,
            trustScore: 0,
            completedTrades: 0,
          ),
          token: '',
        );
        print('[AuthNotifier] Login profile deferred: $errorMsg');
        return;
      }
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

  Future<void> updateRole(String role) async {
    final currentState = state;
    if (currentState is! AuthAuthenticated) return;

    final normalizedRole = _canonicalRole(role);
    _pendingRole = normalizedRole;
    final user = authService.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'role': normalizedRole,
          'roles': [normalizedRole],
          'roleSelectionPending': false,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } on FirebaseException catch (error) {
        print('[AuthNotifier] Role persistence deferred: ${error.code}');
      } catch (error) {
        print('[AuthNotifier] Role persistence deferred: $error');
      }
    }

    state = AuthAuthenticated(
      user: AuthUser(
        id: currentState.user.id,
        email: currentState.user.email,
        firstName: currentState.user.firstName,
        lastName: currentState.user.lastName,
        fullName: currentState.user.fullName,
        roles: [normalizedRole],
        kycStatus: currentState.user.kycStatus,
        emailVerified: currentState.user.emailVerified,
        phoneVerified: currentState.user.phoneVerified,
        trustScore: currentState.user.trustScore,
        completedTrades: currentState.user.completedTrades,
      ),
      token: currentState.token,
    );
  }

  /// Sends Firebase's password-reset email without changing the active
  /// session. This is intentionally kept separate from login state so the
  /// sign-in form remains usable when a reset request fails.
  Future<void> sendPasswordResetEmail(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty) {
      throw AuthException('Enter your email address first.');
    }
    await authService.sendPasswordResetEmail(normalizedEmail);
  }

  /// LOGOUT
  Future<void> logout() async {
    try {
      await _profileSub?.cancel();
      _profileSub = null;
      _pendingRole = null;
      await authService.logout();
      await apiClient.logout();
      state = const AuthUnauthenticated();
      print('[AuthNotifier] Logged out');
    } catch (e) {
      print('[AuthNotifier] Logout error: $e');
      state = const AuthUnauthenticated();
    }
  }

  @override
  void dispose() {
    _profileSub?.cancel();
    super.dispose();
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
