import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/api_client.dart';

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
      trustScore: json['trustScore'] ?? 0,
      completedTrades: json['completedTrades'] ?? 0,
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

  AuthNotifier() : super(const AuthIdle());

  /// REGISTER with Email & Password
  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
    String? organizationName,
    String? countryCode,
  }) async {
    state = const AuthLoading();

    try {
      print('[AuthNotifier] Registering: $email');

      final response = await apiClient.post(
        '/auth/register',
        body: {
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
          if (phone != null) 'phone': phone,
          if (organizationName != null) 'organization': organizationName,
          if (countryCode != null) 'countryCode': countryCode,
        },
      );

      if (!response['success']) {
        throw Exception(response['message'] ?? 'Registration failed');
      }

      final token = response['token'] as String;
      final userData = response['user'] as Map<String, dynamic>;

      apiClient.setToken(token);

      final authUser = AuthUser.fromJson(userData);
      state = AuthAuthenticated(user: authUser, token: token);

      print('[AuthNotifier] Registration successful: ${authUser.id}');
    } catch (e) {
      state = AuthError(e.toString());
      print('[AuthNotifier] Registration error: $e');
    }
  }

  /// LOGIN with Email & Password
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AuthLoading();

    try {
      print('[AuthNotifier] Logging in: $email');

      final response = await apiClient.post(
        '/auth/login',
        body: {
          'email': email,
          'password': password,
        },
      );

      if (!response['success']) {
        throw Exception(response['message'] ?? 'Login failed');
      }

      final token = response['token'] as String;
      final userData = response['user'] as Map<String, dynamic>;

      apiClient.setToken(token);

      final authUser = AuthUser.fromJson(userData);
      state = AuthAuthenticated(user: authUser, token: token);

      print('[AuthNotifier] Login successful: ${authUser.id}');
    } catch (e) {
      state = AuthError(e.toString());
      print('[AuthNotifier] Login error: $e');
    }
  }

  /// LOGIN with Google (stub for now)
  Future<void> loginWithGoogle() async {
    state = const AuthLoading();
    try {
      // TODO: Implement actual Google Sign-In
      print('[AuthNotifier] Google login requested');
      state = const AuthUnauthenticated();
    } catch (e) {
      state = AuthError(e.toString());
      print('[AuthNotifier] Google login error: $e');
    }
  }

  /// LOGIN with Facebook (stub for now)
  Future<void> loginWithFacebook() async {
    state = const AuthLoading();
    try {
      // TODO: Implement actual Facebook Sign-In
      print('[AuthNotifier] Facebook login requested');
      state = const AuthUnauthenticated();
    } catch (e) {
      state = AuthError(e.toString());
      print('[AuthNotifier] Facebook login error: $e');
    }
  }

  /// LOGIN with Apple (stub for now)
  Future<void> loginWithApple() async {
    state = const AuthLoading();
    try {
      // TODO: Implement actual Apple Sign-In
      print('[AuthNotifier] Apple login requested');
      state = const AuthUnauthenticated();
    } catch (e) {
      state = AuthError(e.toString());
      print('[AuthNotifier] Apple login error: $e');
    }
  }

  /// LOGOUT
  Future<void> logout() async {
    try {
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
