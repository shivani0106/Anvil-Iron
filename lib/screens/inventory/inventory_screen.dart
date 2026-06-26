import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_color_scheme.dart';
import '../../cubits/navigation/navigation_cubit.dart';
import '../../cubits/navigation/navigation_state.dart';
import '../../cubits/inventory/inventory_cubit.dart';
import '../../cubits/inventory/inventory_state.dart';
import '../../widgets/common/screen_app_bar.dart';
import '../../widgets/common/search_bar_field.dart';
import '../../widgets/common/info_card.dart';
import '../../widgets/common/progress_bar.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InventoryCubit, InventoryState>(
      builder: (ctx, state) {
        final nav = ctx.read<NavigationCubit>();
        final items = state.filteredItems;
        final lowCount = state.lowStockItems.length;

        return Scaffold(
          backgroundColor: context.colors.background,
          appBar: const ScreenAppBar(title: 'Inventory'),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
                child: SearchBarField(
                  hint: 'Search materials…',
                  onChanged: (q) => ctx.read<InventoryCubit>().setSearch(q),
                  value: state.searchQuery,
                ),
              ),
              if (lowCount > 0)
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.colors.errorSoft,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColorScheme.error.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, size: 16, color: AppColorScheme.error),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '$lowCount item${lowCount > 1 ? 's' : ''} below reorder level — check Inventory before they block a job.',
                            style: const TextStyle(fontSize: 12, color: AppColorScheme.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                  itemCount: items.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final m = items[i];
                    return InfoCard(
                      onTap: () => nav.navigateTo(AppScreen.stockLog, materialId: m.id),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      m.name,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: context.colors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      m.category,
                                      style: TextStyle(fontSize: 12, color: context.colors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    m.qtyText,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: m.isLow ? AppColorScheme.error : context.colors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'min ${m.reorder.toInt()} ${m.unit}',
                                    style: TextStyle(fontSize: 11, color: context.colors.textMuted),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 9),
                          AppProgressBar(
                            value: m.stockPercent,
                            color: m.isLow ? AppColorScheme.error : context.colors.textSecondary,
                            height: 5,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
