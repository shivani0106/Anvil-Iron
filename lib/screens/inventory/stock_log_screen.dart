import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_color_scheme.dart';
import '../../core/theme/app_theme.dart';
import '../../cubits/navigation/navigation_cubit.dart';
import '../../cubits/inventory/inventory_cubit.dart';
import '../../cubits/inventory/inventory_state.dart';
import '../../widgets/common/screen_app_bar.dart';
import '../../widgets/common/progress_bar.dart';

class StockLogScreen extends StatelessWidget {
  final int materialId;
  const StockLogScreen({super.key, required this.materialId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InventoryCubit, InventoryState>(
      builder: (ctx, state) {
        final material = ctx.read<InventoryCubit>().getItemById(materialId);

        if (material == null) {
          return Scaffold(
            appBar: const ScreenAppBar(title: 'Stock Log'),
            body: const Center(child: Text('Material not found')),
          );
        }

        return Scaffold(
          backgroundColor: context.colors.background,
          appBar: ScreenAppBar(title: material.name),
          body: Column(
            children: [
              // Current stock card
              Padding(
                padding: const EdgeInsets.all(18),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    border: Border.all(color: context.colors.border),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Current Stock',
                            style: TextStyle(fontSize: 13, color: context.colors.textSecondary),
                          ),
                          Text(
                            material.qtyText,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: material.isLow ? AppColorScheme.error : context.colors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      AppProgressBar(
                        value: material.stockPercent,
                        color: material.isLow ? AppColorScheme.error : AppColorScheme.accent,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            material.isLow ? '⚠ Below reorder level' : 'Stock level OK',
                            style: TextStyle(
                              fontSize: 12,
                              color: material.isLow ? AppColorScheme.error : context.colors.textSecondary,
                            ),
                          ),
                          Text(
                            'Reorder at ${material.reorder.toInt()} ${material.unit}',
                            style: TextStyle(fontSize: 12, color: context.colors.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Add / Remove stock
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (v) => ctx.read<InventoryCubit>().setStockInput(v),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Qty (${material.unit})',
                          filled: true,
                          fillColor: context.colors.surface,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            borderSide: BorderSide(color: context.colors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            borderSide: BorderSide(color: context.colors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            borderSide: const BorderSide(color: AppColorScheme.accent, width: 1.5),
                          ),
                        ),
                        style: TextStyle(fontSize: 14, color: context.colors.textPrimary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StockButton(
                      label: '+ Add',
                      color: AppColorScheme.statusReady,
                      onTap: () {
                        ctx.read<InventoryCubit>().applyStock(materialId, 1);
                        ctx.read<NavigationCubit>().showToast('Stock added');
                      },
                    ),
                    const SizedBox(width: 6),
                    _StockButton(
                      label: '− Use',
                      color: AppColorScheme.error,
                      onTap: () {
                        ctx.read<InventoryCubit>().applyStock(materialId, -1);
                        ctx.read<NavigationCubit>().showToast('Stock updated');
                      },
                    ),
                  ],
                ),
              ),
              // Log
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Log',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: context.colors.textPrimary),
                  ),
                ),
              ),
              Expanded(
                child: material.log.isEmpty
                    ? Center(
                        child: Text('No log entries yet', style: TextStyle(color: context.colors.textMuted)),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                        itemCount: material.log.length,
                        itemBuilder: (_, i) {
                          final entry = material.log[i];
                          final isAdd = entry.delta > 0;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: context.colors.surface,
                              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                              border: Border.all(color: context.colors.border),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: isAdd
                                        ? AppColorScheme.statusReady.withValues(alpha: 0.1)
                                        : AppColorScheme.error.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Icon(
                                      isAdd ? Icons.add : Icons.remove,
                                      size: 16,
                                      color: isAdd ? AppColorScheme.statusReady : AppColorScheme.error,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entry.note,
                                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: context.colors.textPrimary),
                                      ),
                                      Text(
                                        entry.date,
                                        style: TextStyle(fontSize: 11, color: context.colors.textMuted),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${isAdd ? '+' : ''}${entry.delta} ${material.unit}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isAdd ? AppColorScheme.statusReady : AppColorScheme.error,
                                  ),
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

class _StockButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _StockButton({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
