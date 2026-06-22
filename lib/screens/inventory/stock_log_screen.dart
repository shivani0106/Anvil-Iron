import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
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
          backgroundColor: AppColors.background,
          appBar: ScreenAppBar(title: material.name),
          body: Column(
            children: [
              // Current stock card
              Padding(
                padding: const EdgeInsets.all(18),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Current Stock',
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                          Text(
                            material.qtyText,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: material.isLow ? AppColors.error : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      AppProgressBar(
                        value: material.stockPercent,
                        color: material.isLow ? AppColors.error : AppColors.accent,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            material.isLow ? '⚠ Below reorder level' : 'Stock level OK',
                            style: TextStyle(
                              fontSize: 12,
                              color: material.isLow ? AppColors.error : AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            'Reorder at ${material.reorder.toInt()} ${material.unit}',
                            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
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
                          fillColor: AppColors.surface,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
                          ),
                        ),
                        style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StockButton(
                      label: '+ Add',
                      color: AppColors.statusReady,
                      onTap: () {
                        ctx.read<InventoryCubit>().applyStock(materialId, 1);
                        ctx.read<NavigationCubit>().showToast('Stock added');
                      },
                    ),
                    const SizedBox(width: 6),
                    _StockButton(
                      label: '− Use',
                      color: AppColors.error,
                      onTap: () {
                        ctx.read<InventoryCubit>().applyStock(materialId, -1);
                        ctx.read<NavigationCubit>().showToast('Stock updated');
                      },
                    ),
                  ],
                ),
              ),
              // Log
              const Padding(
                padding: EdgeInsets.fromLTRB(18, 0, 18, 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Log',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                ),
              ),
              Expanded(
                child: material.log.isEmpty
                    ? const Center(
                        child: Text('No log entries yet', style: TextStyle(color: AppColors.textMuted)),
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
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: isAdd
                                        ? AppColors.statusReady.withValues(alpha: 0.1)
                                        : AppColors.error.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Icon(
                                      isAdd ? Icons.add : Icons.remove,
                                      size: 16,
                                      color: isAdd ? AppColors.statusReady : AppColors.error,
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
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                                      ),
                                      Text(
                                        entry.date,
                                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${isAdd ? '+' : ''}${entry.delta} ${material.unit}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isAdd ? AppColors.statusReady : AppColors.error,
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
