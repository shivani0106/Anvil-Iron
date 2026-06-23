import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

sealed class AppAuthState extends Equatable {
  const AppAuthState();
  @override
  List<Object?> get props => [];
}

/// First state — Supabase is resolving the stored session (~150 ms).
class AppAuthInitial extends AppAuthState {
  const AppAuthInitial();
}

/// An auth operation is in flight (sign-in, sign-up, sign-out).
class AppAuthLoading extends AppAuthState {
  const AppAuthLoading();
}

/// A valid Supabase session is active.
class AppAuthAuthenticated extends AppAuthState {
  final User user;
  const AppAuthAuthenticated(this.user);

  /// Display name: full_name from metadata → email → 'User' fallback.
  String get displayName =>
      (user.userMetadata?['full_name'] as String?)?.trim().isNotEmpty == true
          ? user.userMetadata!['full_name'] as String
          : (user.userMetadata?['name'] as String?)?.trim().isNotEmpty == true
              ? user.userMetadata!['name'] as String
              : user.email ?? 'User';

  /// First name only — used in greeting.
  String get firstName => displayName.split(' ').first;

  /// Up to 2 uppercase initials derived from [displayName].
  String get initials => displayName
      .trim()
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .take(2)
      .map((w) => w[0].toUpperCase())
      .join();

  /// Google profile picture URL (null for email/password accounts).
  String? get avatarUrl =>
      user.userMetadata?['avatar_url'] as String? ??
      user.userMetadata?['picture'] as String?;

  @override
  List<Object?> get props => [user.id];
}

/// No session — the app shows the sign-in screen.
class AppAuthUnauthenticated extends AppAuthState {
  const AppAuthUnauthenticated();
}

/// Sign-up succeeded but Supabase requires the user to click the
/// confirmation link in their email before a session is issued.
class AppAuthConfirmationRequired extends AppAuthState {
  final String email;
  const AppAuthConfirmationRequired(this.email);
  @override
  List<Object?> get props => [email];
}

/// A recoverable auth error — the sign-in/up screen shows the message.
class AppAuthError extends AppAuthState {
  final String message;
  const AppAuthError(this.message);
  @override
  List<Object?> get props => [message];
}
