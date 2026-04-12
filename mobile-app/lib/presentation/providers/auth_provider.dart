import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../../config/theme.dart';

/// Auth State Management with Riverpod
/// Manages user authentication state and API communication

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
  final String accessToken;
  final String refreshToken;

  const AuthAuthenticated({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Auth Notifier - handles auth logic
class AuthNotifier extends StateNotifier<AuthState> {
  final Dio dio;

  AuthNotifier(this.dio) : super(const AuthIdle());

  /// REGISTER: Create new account
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
      final response = await dio.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
          'phone': phone,
          'organizationName': organizationName,
          'countryCode': countryCode,
        },
      );

      final user = AuthUser.fromJson(response.data['user']);
      final accessToken = response.data['accessToken'];
      final refreshToken = response.data['refreshToken'];

      state = AuthAuthenticated(
        user: user,
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    } catch (e) {
      state = AuthError(_extractErrorMessage(e));
    }
  }

  /// LOGIN: Authenticate with email & password
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AuthLoading();

    try {
      final response = await dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final user = AuthUser.fromJson(response.data['user']);
      final accessToken = response.data['accessToken'];
      final refreshToken = response.data['refreshToken'];

      state = AuthAuthenticated(
        user: user,
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    } catch (e) {
      state = AuthError(_extractErrorMessage(e));
    }
  }

  /// LOGOUT: Sign out current user
  Future<void> logout() async {
    try {
      if (state is AuthAuthenticated) {
        final authState = state as AuthAuthenticated;
        dio.options.headers['Authorization'] =
            'Bearer ${authState.accessToken}';

        await dio.post('/auth/logout');
      }
    } catch (e) {
      // Log error but still logout
      print('Logout error: $e');
    } finally {
      state = const AuthUnauthenticated();
    }
  }

  /// REFRESH TOKEN: Get new access token
  Future<bool> refreshToken(String currentRefreshToken) async {
    try {
      final response = await dio.post(
        '/auth/refresh',
        data: {
          'refreshToken': currentRefreshToken,
        },
      );

      if (state is AuthAuthenticated) {
        final authState = state as AuthAuthenticated;
        state = AuthAuthenticated(
          user: authState.user,
          accessToken: response.data['accessToken'],
          refreshToken: response.data['refreshToken'],
        );
        return true;
      }
    } catch (e) {
      print('Token refresh failed: $e');
    }
    return false;
  }

  /// VERIFY EMAIL: Verify email with token from link
  Future<void> verifyEmail(String token) async {
    try {
      await dio.post(
        '/auth/verify-email',
        data: {
          'token': token,
          'type': 'email_verification',
        },
      );

      // Update user's emailVerified status
      if (state is AuthAuthenticated) {
        final authState = state as AuthAuthenticated;
        final updatedUser = AuthUser(
          id: authState.user.id,
          email: authState.user.email,
          firstName: authState.user.firstName,
          lastName: authState.user.lastName,
          fullName: authState.user.fullName,
          roles: authState.user.roles,
          kycStatus: authState.user.kycStatus,
          emailVerified: true, // Updated
          phoneVerified: authState.user.phoneVerified,
          trustScore: authState.user.trustScore,
          completedTrades: authState.user.completedTrades,
        );

        state = AuthAuthenticated(
          user: updatedUser,
          accessToken: authState.accessToken,
          refreshToken: authState.refreshToken,
        );
      }
    } catch (e) {
      state = AuthError(_extractErrorMessage(e));
    }
  }

  /// REQUEST PASSWORD RESET: Send reset email
  Future<void> requestPasswordReset(String email) async {
    state = const AuthLoading();

    try {
      await dio.post(
        '/auth/forgot-password',
        data: {'email': email},
      );

      state = const AuthUnauthenticated();
    } catch (e) {
      state = AuthError(_extractErrorMessage(e));
    }
  }

  /// RESET PASSWORD: Reset with token from email
  Future<void> resetPassword(
      {required String token, required String newPassword}) async {
    state = const AuthLoading();

    try {
      await dio.post(
        '/auth/reset-password',
        data: {
          'token': token,
          'newPassword': newPassword,
        },
      );

      state = const AuthUnauthenticated();
    } catch (e) {
      state = AuthError(_extractErrorMessage(e));
    }
  }

  /// Private: Extract error message from DioException
  String _extractErrorMessage(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        // Backend error message
        return error.response!.data['message'] ??
            error.response!.statusMessage ??
            'An error occurred';
      }
      return error.message ?? 'Network error';
    }
    return error.toString();
  }
}

/// Riverpod Providers

/// Dio instance (HTTP client)
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://localhost:3000/api', // TODO: Use env
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: 'application/json',
    ),
  );

  // Add response interceptor for error handling
  dio.interceptors.add(
    InterceptorsWrapper(
      onResponse: (response, handler) {
        // Handle 401 - token expired
        if (response.statusCode == 401) {
          // Trigger logout in app
        }
        return handler.next(response);
      },
      onError: (error, handler) {
        // Handle errors
        return handler.next(error);
      },
    ),
  );

  return dio;
});

/// Auth State Notifier

/// Auth provider - main state management
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthNotifier(dio);
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
    return state.accessToken;
  }
  return null;
});
