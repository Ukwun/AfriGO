import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Exception class for authentication errors
class AuthException implements Exception {
  final String message;
  final String? code;

  AuthException(this.message, {this.code});

  @override
  String toString() => message;
}

/// Firebase Authentication Service
/// Handles email/password, Google, Facebook, and Apple authentication
class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FacebookAuth _facebookAuth = FacebookAuth.instance;

  /// Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => _firebaseAuth.currentUser != null;

  /// Get current user ID
  String? get userId => _firebaseAuth.currentUser?.uid;

  /// Get current user email
  String? get userEmail => _firebaseAuth.currentUser?.email;

  /// REGISTER with Email & Password
  Future<User> registerWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
    String? organization,
    String? countryCode,
  }) async {
    try {
      print(
        '[AuthService] Registering user: $email',
      );

      // Create Firebase account
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw AuthException('Failed to create user account');
      }

      // Update user profile with additional data
      try {
        await user.updateDisplayName('$firstName $lastName');
        await user.updatePhotoURL(
          'https://api.dicebear.com/7.x/avataaars/svg?seed=$email',
        );
      } catch (e) {
        print('[AuthService] Error updating user profile: $e');
      }

      // Send email verification
      try {
        await user.sendEmailVerification();
        print('[AuthService] Verification email sent to $email');
      } catch (e) {
        print('[AuthService] Error sending verification email: $e');
      }

      print('[AuthService] User registered successfully: ${user.uid}');
      return user;
    } on FirebaseAuthException catch (e) {
      String message = _parseFirebaseAuthError(e);
      print('[AuthService] Registration error: ${e.code} - $message');
      throw AuthException(message, code: e.code);
    } catch (e) {
      print('[AuthService] Unexpected registration error: $e');
      throw AuthException('Registration failed: ${e.toString()}');
    }
  }

  /// LOGIN with Email & Password
  Future<User> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      print('[AuthService] Logging in user: $email');

      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw AuthException('Login failed - no user returned');
      }

      print('[AuthService] User logged in successfully: ${user.uid}');
      return user;
    } on FirebaseAuthException catch (e) {
      String message = _parseFirebaseAuthError(e);
      print('[AuthService] Login error: ${e.code} - $message');
      throw AuthException(message, code: e.code);
    } catch (e) {
      print('[AuthService] Unexpected login error: $e');
      throw AuthException('Login failed: ${e.toString()}');
    }
  }

  /// LOGIN with Google
  Future<User> loginWithGoogle() async {
    try {
      print('[AuthService] Starting Google sign-in flow...');

      // Trigger Google Sign-In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw AuthException('Google sign-in cancelled by user');
      }

      print('[AuthService] Google user signed in: ${googleUser.email}');

      // Authenticate with Firebase
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        throw AuthException('Google sign-in failed - no user returned');
      }

      print('[AuthService] Google authentication successful: ${user.uid}');
      return user;
    } catch (e) {
      print('[AuthService] Google sign-in error: $e');
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException('Google sign-in failed: ${e.toString()}');
    }
  }

  /// LOGIN with Facebook
  Future<User> loginWithFacebook() async {
    try {
      print('[AuthService] Starting Facebook sign-in flow...');

      // Trigger Facebook Sign-In
      final LoginResult result = await _facebookAuth.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.cancelled) {
        throw AuthException('Facebook sign-in cancelled by user');
      }

      if (result.status == LoginStatus.failed) {
        throw AuthException(
          'Facebook sign-in failed: ${result.message}',
        );
      }

      final AccessToken? accessToken = result.accessToken;
      if (accessToken == null) {
        throw AuthException('Failed to obtain Facebook access token');
      }

      print('[AuthService] Facebook user authenticated: ${accessToken.userId}');

      // Authenticate with Firebase
      final OAuthCredential credential =
          FacebookAuthProvider.credential(accessToken.token);

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        throw AuthException('Facebook sign-in failed - no user returned');
      }

      print('[AuthService] Facebook authentication successful: ${user.uid}');
      return user;
    } catch (e) {
      print('[AuthService] Facebook sign-in error: $e');
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException('Facebook sign-in failed: ${e.toString()}');
    }
  }

  /// LOGIN with Apple
  Future<User> loginWithApple() async {
    try {
      print('[AuthService] Starting Apple sign-in flow...');

      // Check if Apple sign-in is available
      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        throw AuthException('Apple sign-in is not available on this device');
      }

      // Request Apple authentication
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      print(
          '[AuthService] Apple user authenticated: ${appleCredential.userIdentifier}');

      // Create Firebase credential
      final OAuthProvider oauthProvider = OAuthProvider('apple.com');
      final credential = oauthProvider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in with Firebase
      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        throw AuthException('Apple sign-in failed - no user returned');
      }

      // Update user profile if available
      if (appleCredential.givenName != null ||
          appleCredential.familyName != null) {
        final displayName =
            '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'
                .trim();
        if (displayName.isNotEmpty) {
          try {
            await user.updateDisplayName(displayName);
          } catch (e) {
            print('[AuthService] Error updating Apple user profile: $e');
          }
        }
      }

      print('[AuthService] Apple authentication successful: ${user.uid}');
      return user;
    } catch (e) {
      print('[AuthService] Apple sign-in error: $e');
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException('Apple sign-in failed: ${e.toString()}');
    }
  }

  /// LOGOUT
  Future<void> logout() async {
    try {
      print('[AuthService] Logging out user...');

      // Sign out from Firebase
      await _firebaseAuth.signOut();

      // Sign out from Google
      await _googleSignIn.signOut();

      // Sign out from Facebook
      await _facebookAuth.logOut();

      print('[AuthService] User logged out successfully');
    } catch (e) {
      print('[AuthService] Logout error: $e');
      throw AuthException('Logout failed: ${e.toString()}');
    }
  }

  /// SEND PASSWORD RESET EMAIL
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      print('[AuthService] Sending password reset email to $email');
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
      print('[AuthService] Password reset email sent');
    } on FirebaseAuthException catch (e) {
      String message = _parseFirebaseAuthError(e);
      print('[AuthService] Password reset error: ${e.code} - $message');
      throw AuthException(message, code: e.code);
    } catch (e) {
      print('[AuthService] Unexpected password reset error: $e');
      throw AuthException('Password reset failed: ${e.toString()}');
    }
  }

  /// VERIFY EMAIL
  Future<void> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw AuthException('No user logged in');
      }

      print('[AuthService] Sending email verification to ${user.email}');
      await user.sendEmailVerification();
      print('[AuthService] Verification email sent');
    } catch (e) {
      print('[AuthService] Email verification error: $e');
      throw AuthException('Email verification failed: ${e.toString()}');
    }
  }

  /// RELOAD USER
  Future<void> reloadUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw AuthException('No user logged in');
      }

      await user.reload();
      print('[AuthService] User data reloaded');
    } catch (e) {
      print('[AuthService] Reload user error: $e');
      throw AuthException('Failed to reload user data: ${e.toString()}');
    }
  }

  /// Get ID Token for API calls
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return null;
      }

      final token = await user.getIdToken(forceRefresh);
      return token;
    } catch (e) {
      print('[AuthService] Error getting ID token: $e');
      return null;
    }
  }

  /// Parse Firebase Auth errors into user-friendly messages
  String _parseFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email address';
      case 'wrong-password':
        return 'Incorrect password. Please try again';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'email-already-in-use':
        return 'An account with this email already exists';
      case 'operation-not-allowed':
        return 'This operation is not allowed';
      case 'weak-password':
        return 'Password is too weak. Please use a stronger password';
      case 'too-many-requests':
        return 'Too many login attempts. Please try again later';
      case 'account-exists-with-different-credential':
        return 'An account already exists with this email. Try signing in with your existing method';
      case 'invalid-credential':
        return 'Invalid credentials. Please check and try again';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection';
      default:
        return e.message ?? 'Authentication error: ${e.code}';
    }
  }
}
