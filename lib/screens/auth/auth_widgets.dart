// Shared UI building blocks used by SignInScreen and SignUpScreen.
// Kept public (no underscore) so both files can import them.

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

// ── Anvil icon mark (amber gradient + custom anvil shape) ─────────────────────

class AnvilIconMark extends StatelessWidget {
  final double size;
  final bool shadow;
  const AnvilIconMark({super.key, this.size = 46, this.shadow = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment(-0.5, -1.0),
          end: Alignment(0.5, 1.0),
          colors: [Color(0xFFEE8A47), Color(0xFFE07A3C), Color(0xFFC9612A)],
          stops: [0.0, 0.52, 1.0],
        ),
        borderRadius: BorderRadius.circular(size * 0.25),
        boxShadow: shadow
            ? const [
                BoxShadow(
                  color: Color(0x99E07A3C),
                  blurRadius: 28,
                  offset: Offset(0, 12),
                  spreadRadius: -10,
                ),
              ]
            : null,
      ),
      child: CustomPaint(
        painter: _AnvilPainter(),
        size: Size(size, size),
      ),
    );
  }
}

class _AnvilPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 64;
    final sy = size.height / 64;
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(6 * sx, 23 * sy)
      ..lineTo(18 * sx, 16 * sy)
      ..lineTo(54 * sx, 16 * sy)
      ..cubicTo(55.1 * sx, 16 * sy, 56 * sx, 16.9 * sy, 56 * sx, 18 * sy)
      ..lineTo(56 * sx, 24 * sy)
      ..cubicTo(56 * sx, 25.1 * sy, 55.1 * sx, 26 * sy, 54 * sx, 26 * sy)
      ..lineTo(40 * sx, 26 * sy)
      ..lineTo(38 * sx, 30.5 * sy)
      ..lineTo(38 * sx, 33 * sy)
      ..lineTo(49 * sx, 49 * sy)
      ..cubicTo(49.6 * sx, 49.9 * sy, 49 * sx, 51 * sy, 48 * sx, 51 * sy)
      ..lineTo(46 * sx, 51 * sy)
      ..lineTo(46 * sx, 53 * sy)
      ..cubicTo(46 * sx, 54.1 * sy, 45.1 * sx, 55 * sy, 44 * sx, 55 * sy)
      ..lineTo(22 * sx, 55 * sy)
      ..cubicTo(20.9 * sx, 55 * sy, 20 * sx, 54.1 * sy, 20 * sx, 53 * sy)
      ..lineTo(20 * sx, 51 * sy)
      ..lineTo(18 * sx, 51 * sy)
      ..cubicTo(17 * sx, 51 * sy, 16.4 * sx, 49.9 * sy, 17 * sx, 49 * sy)
      ..lineTo(28 * sx, 33 * sy)
      ..lineTo(28 * sx, 30.5 * sy)
      ..lineTo(26 * sx, 26 * sy)
      ..lineTo(18 * sx, 26 * sy)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_AnvilPainter old) => false;
}

// ── Logo ─────────────────────────────────────────────────────────────────────

class AuthAppLogo extends StatelessWidget {
  const AuthAppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const AnvilIconMark(size: 46, shadow: false),
        const SizedBox(width: 14),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Anvil',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.4,
              ),
            ),
            Text(
              'FACTORY MANAGER',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.18,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Headline ─────────────────────────────────────────────────────────────────

class AuthHeadline extends StatelessWidget {
  final String title;
  final String subtitle;
  const AuthHeadline({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.6,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

// ── Form field ────────────────────────────────────────────────────────────────

class AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?) validator;
  final bool enabled;
  final Widget? suffix;

  const AuthField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.validator,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          enabled: enabled,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          decoration: InputDecoration(hintText: hint, suffixIcon: suffix),
        ),
      ],
    );
  }
}

// ── Primary CTA button ────────────────────────────────────────────────────────

class AuthPrimaryButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.isLoading,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(label,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// ── "or" divider ──────────────────────────────────────────────────────────────

class AuthOrDivider extends StatelessWidget {
  const AuthOrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: AppColors.border)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'or',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }
}

// ── Google Sign-In button ─────────────────────────────────────────────────────

class AuthGoogleButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;

  const AuthGoogleButton({super.key, required this.isLoading, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surface,
          side: const BorderSide(color: AppColors.border, width: 1.5),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AuthGoogleColorIcon(),
            const SizedBox(width: 10),
            const Text(
              'Continue with Google',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Google "G" colour icon ────────────────────────────────────────────────────

class AuthGoogleColorIcon extends StatelessWidget {
  const AuthGoogleColorIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'G',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        foreground: Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFF4285F4), Color(0xFFEA4335)],
          ).createShader(const Rect.fromLTWH(0, 0, 18, 18)),
      ),
    );
  }
}

// ── "Don't have an account?" row ──────────────────────────────────────────────

class AuthBottomLink extends StatelessWidget {
  final String question;
  final String actionLabel;
  final VoidCallback? onTap;

  const AuthBottomLink({
    super.key,
    required this.question,
    required this.actionLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$question ',
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            actionLabel,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.accent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
