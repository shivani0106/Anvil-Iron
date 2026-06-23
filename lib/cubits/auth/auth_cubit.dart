import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/auth_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AppAuthState> {
  late final StreamSubscription<AuthState> _authSub;

  AuthCubit() : super(const AppAuthInitial()) {
    // React to every Supabase session event so state stays in sync even on
    // token refresh, magic-link callback, or cold app restart.
    _authSub = AuthService.instance.authStateChanges.listen(_onAuthEvent);
  }

  // ── Supabase session stream ───────────────────────────────────────────────

  void _onAuthEvent(AuthState event) {
    switch (event.event) {
      case AuthChangeEvent.initialSession:
        // Fired once on startup with whatever session is stored on device.
        final user = event.session?.user;
        emit(user != null ? AppAuthAuthenticated(user) : const AppAuthUnauthenticated());
      case AuthChangeEvent.signedIn:
      case AuthChangeEvent.tokenRefreshed:
        final user = event.session?.user;
        if (user != null) emit(AppAuthAuthenticated(user));
      case AuthChangeEvent.signedOut:
        emit(const AppAuthUnauthenticated());
      default:
        break;
    }
  }

  // ── Email / password ──────────────────────────────────────────────────────

  /// Creates a new account. Stores [fullName] in Supabase user_metadata.
  Future<void> signUpWithEmail({
    required String fullName,
    required String email,
    required String password,
  }) async {
    if (state is AppAuthLoading) return;
    emit(const AppAuthLoading());

    final result = await AuthService.instance.signUpWithEmail(
      fullName: fullName,
      email: email,
      password: password,
    );

    switch (result) {
      case AuthSuccess(:final user):
        emit(AppAuthAuthenticated(user));
      case AuthConfirmationRequired(:final email):
        emit(AppAuthConfirmationRequired(email));
      case AuthCancelled():
        emit(const AppAuthUnauthenticated());
      case AuthFailure(:final message):
        emit(AppAuthError(message));
    }
  }

  /// Signs in with email and password.
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (state is AppAuthLoading) return;
    emit(const AppAuthLoading());

    final result = await AuthService.instance.signInWithEmail(
      email: email,
      password: password,
    );

    switch (result) {
      case AuthSuccess(:final user):
        emit(AppAuthAuthenticated(user));
      case AuthConfirmationRequired(:final email):
        emit(AppAuthConfirmationRequired(email));
      case AuthCancelled():
        emit(const AppAuthUnauthenticated());
      case AuthFailure(:final message):
        emit(AppAuthError(message));
    }
  }

  // ── Google (native) ───────────────────────────────────────────────────────

  Future<void> signInWithGoogle() async {
    if (state is AppAuthLoading) return;
    emit(const AppAuthLoading());

    final result = await AuthService.instance.signInWithGoogle();

    switch (result) {
      case AuthSuccess(:final user):
        emit(AppAuthAuthenticated(user));
      case AuthConfirmationRequired():
        // Google accounts are pre-confirmed; this branch is unreachable.
        emit(const AppAuthUnauthenticated());
      case AuthCancelled():
        emit(const AppAuthUnauthenticated());
      case AuthFailure(:final message):
        emit(AppAuthError(message));
    }
  }

  // ── Sign-out ──────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    await AuthService.instance.signOut();
    // _onAuthEvent will emit AppAuthUnauthenticated via the stream.
  }

  // ── Utility ───────────────────────────────────────────────────────────────

  /// Call from error UI once the message has been shown — resets to login.
  void clearError() {
    if (state is AppAuthError) emit(const AppAuthUnauthenticated());
  }

  /// Call from the "check your email" screen — resets to login so the user
  /// can sign in after confirming.
  void clearConfirmation() {
    if (state is AppAuthConfirmationRequired) emit(const AppAuthUnauthenticated());
  }

  @override
  Future<void> close() {
    _authSub.cancel();
    return super.close();
  }
}
