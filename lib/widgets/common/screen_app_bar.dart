import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
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

  // Only the toolbar height — Scaffold adds statusBarHeight on top of this
  // when allocating space (body offset = preferredSize.height + statusBarHeight).
  // The build() method fills that full allocation by reading viewPadding.top
  // and using it as internal top padding so content sits below the status bar.
  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).viewPadding.top;

    return Container(
      // No explicit height — fills the full space Scaffold allocates
      // (56 + statusBarHeight), so the surface colour covers the status bar.
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
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
                  child: const Icon(Icons.chevron_left, size: 28, color: AppColors.textPrimary),
                ),
              )
            else
              const SizedBox(width: 18),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
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
