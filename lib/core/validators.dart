/// Pure, stateless form-field validators.
/// Each function matches the [FormFieldValidator<String>] signature so it can
/// be passed directly to a [TextFormField]'s [validator] parameter.
class AppValidators {
  AppValidators._();

  static String? fullName(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Full name is required';
    if (v.length < 2) return 'Name must be at least 2 characters';
    if (v.length > 80) return 'Name is too long';
    return null;
  }

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Email address is required';
    // RFC-5322 simplified pattern — covers 99%+ of real addresses.
    final pattern = RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');
    if (!pattern.hasMatch(v)) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Password is required';
    if (v.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  /// Validates the confirm-password field against [original].
  static String? Function(String?) confirmPassword(String original) {
    return (String? value) {
      if (value == null || value.isEmpty) return 'Please confirm your password';
      if (value != original) return 'Passwords do not match';
      return null;
    };
  }
}
