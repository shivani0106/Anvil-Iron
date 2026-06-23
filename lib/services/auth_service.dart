import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── Result types ─────────────────────────────────────────────────────────────
// Sealed class avoids try/catch at call sites — every outcome is explicit.

sealed class AuthResult {
  const AuthResult();
}

/// Sign-in or sign-up succeeded and a session is active.
class AuthSuccess extends AuthResult {
  final User user;
  const AuthSuccess(this.user);
}

/// Sign-up succeeded but Supabase requires email confirmation before a
/// session can be created. The user must click the link in their inbox.
class AuthConfirmationRequired extends AuthResult {
  final String email;
  const AuthConfirmationRequired(this.email);
}

/// The user explicitly cancelled (e.g. dismissed the Google account picker).
class AuthCancelled extends AuthResult {
  const AuthCancelled();
}

/// A recoverable error with a user-facing message.
class AuthFailure extends AuthResult {
  final String message;
  const AuthFailure(this.message);
}

// ── Service ───────────────────────────────────────────────────────────────────

/// Single source of truth for every auth operation in the app.
///
/// Supports:
/// - Email / password sign-up  (stores full_name in user_metadata)
/// - Email / password sign-in
/// - Native Google Sign-In  (no browser redirect on mobile)
/// - Sign-out  (clears both Google and Supabase sessions)
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  late final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Required on Android so Google issues an idToken Supabase can validate.
    // On iOS the value is read from GoogleService-Info.plist automatically.
    serverClientId: dotenv.env['GOOGLE_WEB_CLIENT_ID'],
    scopes: ['email', 'profile'],
  );

  SupabaseClient get _client => Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;
  bool get isSignedIn => currentUser != null;

  /// Stream of Supabase auth lifecycle events (initialSession, signedIn,
  /// tokenRefreshed, signedOut, …). The AuthCubit subscribes to this.
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // ── Email / password ────────────────────────────────────────────────────────

  /// Registers a new user. Stores [fullName] in Supabase user_metadata so
  /// every part of the app can display it without a separate DB table.
  Future<AuthResult> signUpWithEmail({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'display_name': fullName,
        },
      );

      // If Supabase returned a session, the account is live immediately.
      if (response.session != null && response.user != null) {
        return AuthSuccess(response.user!);
      }

      // session is null when "Confirm email" is ON in the Supabase Dashboard
      // (Authentication → Settings → Email Auth). Bypass it by signing in
      // straight away with the same credentials so the user lands in the app.
      return await signInWithEmail(email: email, password: password);
    } on AuthException catch (e) {
      return AuthFailure(_friendlyMessage(e));
    } on Exception catch (e) {
      return AuthFailure(_networkOrUnknown(e));
    }
  }

  /// Signs in an existing user with email and password.
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        return const AuthFailure('Sign-in failed. Please try again.');
      }
      return AuthSuccess(user);
    } on AuthException catch (e) {
      return AuthFailure(_friendlyMessage(e));
    } on Exception catch (e) {
      return AuthFailure(_networkOrUnknown(e));
    }
  }

  // ── Google (native) ─────────────────────────────────────────────────────────

  /// Triggers the native Google account picker, then passes the ID token to
  /// Supabase. No browser redirect on Android/iOS.
  Future<AuthResult> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return const AuthCancelled();

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        return const AuthFailure(
          'Google did not return an ID token. '
          'Check that GOOGLE_WEB_CLIENT_ID is set correctly in .env.',
        );
      }

      final response = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: googleAuth.accessToken,
      );

      final user = response.user;
      if (user == null) {
        return const AuthFailure('Supabase returned no user after Google sign-in.');
      }
      return AuthSuccess(user);
    } on AuthException catch (e) {
      return AuthFailure(_friendlyMessage(e));
    } on Exception catch (e) {
      return AuthFailure(_networkOrUnknown(e));
    }
  }

  // ── Sign-out ────────────────────────────────────────────────────────────────

  /// Clears both Google and Supabase sessions.
  Future<void> signOut() async {
    await Future.wait([
      _googleSignIn.signOut(),
      _client.auth.signOut(),
    ]);
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  String _friendlyMessage(AuthException e) {
    switch (e.code ?? '') {
      case 'invalid_credentials':
        return 'Incorrect email or password.';
      case 'email_not_confirmed':
        return 'Please confirm your email before signing in.';
      case 'user_already_exists':
      case 'email_address_already_used':
        return 'An account with this email already exists.';
      case 'weak_password':
        return 'Password is too weak. Use at least 8 characters.';
      case 'too_many_requests':
        return 'Too many attempts. Please wait a moment.';
      case 'user_not_found':
        return 'No account found with this email.';
      default:
        return e.message.isNotEmpty ? e.message : 'Authentication failed.';
    }
  }

  String _networkOrUnknown(Exception e) {
    final msg = e.toString();
    if (msg.contains('network_error') ||
        msg.contains('SocketException') ||
        msg.contains('Connection refused')) {
      return 'No internet connection. Please try again.';
    }
    return 'Unexpected error. Please try again.';
  }
}
