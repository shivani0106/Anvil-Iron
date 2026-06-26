import 'package:flutter/material.dart';

class AppColorScheme extends ThemeExtension<AppColorScheme> {
  final Color background;
  final Color surface;
  final Color border;
  final Color borderLight;
  final Color divider;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color accentSoft;
  final Color tagBg;
  final Color tagText;
  final Color errorSoft;

  // These are the same in both themes
  static const Color accent       = Color(0xFFE07A3C);
  static const Color error        = Color(0xFFC5483B);
  static const Color statusQueued    = Color(0xFF9A958B);
  static const Color statusCutting   = Color(0xFFE07A3C);
  static const Color statusWelding   = Color(0xFFD4622A);
  static const Color statusQC        = Color(0xFF6B5EA8);
  static const Color statusReady     = Color(0xFF2E7D32);
  static const Color statusDelivered = Color(0xFF5A9E6F);
  static const Color machineRunning     = Color(0xFF2E7D32);
  static const Color machineIdle        = Color(0xFF8A857B);
  static const Color machineMaintenance = Color(0xFFC5483B);
  static const Color invoicePaid        = Color(0xFF2E7D32);
  static const Color invoiceOutstanding = Color(0xFFE07A3C);
  static const Color invoiceOverdue     = Color(0xFFC5483B);

  const AppColorScheme({
    required this.background,
    required this.surface,
    required this.border,
    required this.borderLight,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.accentSoft,
    required this.tagBg,
    required this.tagText,
    required this.errorSoft,
  });

  static const light = AppColorScheme(
    background:    Color(0xFFF6F4EF),
    surface:       Color(0xFFFFFFFF),
    border:        Color(0xFFECE7DD),
    borderLight:   Color(0xFFE4DFD5),
    divider:       Color(0xFFF0ECE3),
    textPrimary:   Color(0xFF23211E),
    textSecondary: Color(0xFF8A857B),
    textMuted:     Color(0xFF9A958B),
    accentSoft:    Color(0xFFFBEEE4),
    tagBg:         Color(0xFFF1EEE7),
    tagText:       Color(0xFF6A655C),
    errorSoft:     Color(0xFFFFF0EE),
  );

  static const dark = AppColorScheme(
    background:    Color(0xFF161210),
    surface:       Color(0xFF201D1A),
    border:        Color(0xFF2E2920),
    borderLight:   Color(0xFF28231A),
    divider:       Color(0xFF2E2920),
    textPrimary:   Color(0xFFEDE9E2),
    textSecondary: Color(0x99EDE9E2),
    textMuted:     Color(0x66EDE9E2),
    accentSoft:    Color(0xFF2E1E12),
    tagBg:         Color(0xFF2A2520),
    tagText:       Color(0xFFA09A90),
    errorSoft:     Color(0xFF2A1010),
  );

  @override
  AppColorScheme copyWith({
    Color? background, Color? surface, Color? border, Color? borderLight,
    Color? divider, Color? textPrimary, Color? textSecondary, Color? textMuted,
    Color? accentSoft, Color? tagBg, Color? tagText, Color? errorSoft,
  }) => AppColorScheme(
    background:    background    ?? this.background,
    surface:       surface       ?? this.surface,
    border:        border        ?? this.border,
    borderLight:   borderLight   ?? this.borderLight,
    divider:       divider       ?? this.divider,
    textPrimary:   textPrimary   ?? this.textPrimary,
    textSecondary: textSecondary ?? this.textSecondary,
    textMuted:     textMuted     ?? this.textMuted,
    accentSoft:    accentSoft    ?? this.accentSoft,
    tagBg:         tagBg         ?? this.tagBg,
    tagText:       tagText       ?? this.tagText,
    errorSoft:     errorSoft     ?? this.errorSoft,
  );

  @override
  AppColorScheme lerp(AppColorScheme? other, double t) {
    if (other == null) return this;
    return AppColorScheme(
      background:    Color.lerp(background,    other.background,    t)!,
      surface:       Color.lerp(surface,       other.surface,       t)!,
      border:        Color.lerp(border,        other.border,        t)!,
      borderLight:   Color.lerp(borderLight,   other.borderLight,   t)!,
      divider:       Color.lerp(divider,       other.divider,       t)!,
      textPrimary:   Color.lerp(textPrimary,   other.textPrimary,   t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted:     Color.lerp(textMuted,     other.textMuted,     t)!,
      accentSoft:    Color.lerp(accentSoft,    other.accentSoft,    t)!,
      tagBg:         Color.lerp(tagBg,         other.tagBg,         t)!,
      tagText:       Color.lerp(tagText,       other.tagText,       t)!,
      errorSoft:     Color.lerp(errorSoft,     other.errorSoft,     t)!,
    );
  }
}

extension AppColorSchemeContext on BuildContext {
  AppColorScheme get colors => Theme.of(this).extension<AppColorScheme>()!;
}
