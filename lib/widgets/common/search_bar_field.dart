import 'package:flutter/material.dart';
import '../../core/theme/app_color_scheme.dart';
import '../../core/theme/app_theme.dart';

class SearchBarField extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  final String value;

  const SearchBarField({
    super.key,
    required this.hint,
    required this.onChanged,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: context.colors.border),
      ),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: context.colors.textMuted, fontSize: 14),
          prefixIcon: Icon(Icons.search, size: 18, color: context.colors.textMuted),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 11),
          isDense: true,
        ),
        style: TextStyle(fontSize: 14, color: context.colors.textPrimary),
      ),
    );
  }
}
