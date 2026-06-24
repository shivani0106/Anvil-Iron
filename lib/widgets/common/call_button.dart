import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';

class CallButton extends StatelessWidget {
  final String number;
  final double size;

  const CallButton({super.key, required this.number, this.size = 36});

  Future<void> _call(BuildContext context) async {
    final cleaned = number.replaceAll(RegExp(r'\s+'), '');
    if (cleaned.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: cleaned);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot place call from this device')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _call(context),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.statusReady.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.phone_outlined, size: size * 0.5, color: AppColors.statusReady),
      ),
    );
  }
}
