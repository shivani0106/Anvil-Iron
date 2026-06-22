import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AppProgressBar extends StatelessWidget {
  final double value;
  final Color? color;
  final double height;

  const AppProgressBar({
    super.key,
    required this.value,
    this.color,
    this.height = 7,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: height,
        backgroundColor: const Color(0xFFEFEBE3),
        valueColor: AlwaysStoppedAnimation<Color>(color ?? AppColors.accent),
      ),
    );
  }
}

class AvatarCircle extends StatelessWidget {
  final String initials;
  final double size;
  final Color? bg;
  final Color? fg;

  const AvatarCircle({
    super.key,
    required this.initials,
    this.size = 40,
    this.bg,
    this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg ?? AppColors.accentSoft,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: size * 0.36,
            fontWeight: FontWeight.w700,
            color: fg ?? AppColors.accent,
          ),
        ),
      ),
    );
  }
}
