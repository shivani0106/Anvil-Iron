import 'package:flutter/material.dart';
import '../../core/theme/app_color_scheme.dart';
import '../../cubits/navigation/navigation_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ScreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final Widget? action;

  const ScreenAppBar({
    super.key,
    required this.title,
    this.showBack = true,
    this.action,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).viewPadding.top;

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(bottom: BorderSide(color: context.colors.divider)),
      ),
      padding: EdgeInsets.only(top: statusBarHeight),
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            if (showBack)
              GestureDetector(
                onTap: () => context.read<NavigationCubit>().back(),
                child: Container(
                  width: 44,
                  height: 44,
                  margin: const EdgeInsets.only(left: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.chevron_left, size: 28, color: context.colors.textPrimary),
                ),
              )
            else
              const SizedBox(width: 18),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: context.colors.textPrimary,
                  letterSpacing: -0.02,
                ),
              ),
            ),
            if (action != null) ...[
              action!,
              const SizedBox(width: 12),
            ],
          ],
        ),
      ),
    );
  }
}
