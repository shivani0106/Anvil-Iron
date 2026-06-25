/// Pure, stateless form-field validators.
/// Each function matches the [FormFieldValidator<String>] signature so it can
/// be passed directly to a [TextFormField]'s [validator] parameter.
class AppValidators {
  AppValidators._();

  static String? factoryName(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Factory name is required';
    if (v.length < 2) return 'Factory name must be at least 2 characters';
    if (v.length > 100) return 'Factory name is too long';
    return null;
  }

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

  /// Like [email] but returns null when the field is empty (field is optional).
  static String? optionalEmail(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null;
    return email(value);
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

  /// Validates that [value] is a plausible phone number (digits, spaces, +, -, ()).
  /// Returns null when empty because phone fields are usually optional.
  static String? phone(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null;
    if (!RegExp(r'^[\d\s\+\-\(\)]{7,15}$').hasMatch(v)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  /// Returns an error if [value] is not a valid non-negative number.
  /// When [isRequired] is true, also rejects empty values.
  static String? number(String? value, {bool isRequired = false, String fieldName = 'Value'}) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return isRequired ? '$fieldName is required' : null;
    final n = double.tryParse(v);
    if (n == null) return 'Enter a valid number';
    if (n < 0) return 'Value must be 0 or greater';
    return null;
  }

  /// Returns an error if [value] is not a valid integer percentage (0–100).
  static String? percentage(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null;
    final n = int.tryParse(v);
    if (n == null) return 'Enter a whole number (e.g. 75)';
    if (n < 0 || n > 100) return 'Enter a value between 0 and 100';
    return null;
  }

  /// Generic required-field check with a caller-supplied [fieldName].
  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }
}
