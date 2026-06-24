import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../cubits/navigation/navigation_cubit.dart';
import '../../cubits/navigation/navigation_state.dart';
import '../../cubits/orders/orders_cubit.dart';
import '../../cubits/orders/orders_state.dart';
import '../../models/order.dart';
import '../../widgets/common/screen_app_bar.dart';
import '../../widgets/common/filter_chip_row.dart';
import '../../widgets/common/search_bar_field.dart';
import '../../widgets/common/info_card.dart';
import '../../widgets/common/status_chip.dart';
import '../../widgets/common/progress_bar.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersCubit, OrdersState>(
      builder: (ctx, state) {
        final nav = ctx.read<NavigationCubit>();
        final orders = state.filteredOrders;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: ScreenAppBar(
            title: 'Orders',
            action: GestureDetector(
              onTap: () {
                ctx.read<OrdersCubit>().resetForm();
                nav.navigateTo(AppScreen.newOrder);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  '+ New',
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
                child: SearchBarField(
                  hint: 'Search by customer, item, #ID',
                  onChanged: (q) => ctx.read<OrdersCubit>().setSearch(q),
                  value: state.searchQuery,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                child: FilterChipRow(
                  labels: const ['All', 'In progress', 'Done'],
                  selectedIndex: state.filter.index,
                  onSelected: (i) => ctx.read<OrdersCubit>().setFilter(OrderFilter.values[i]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
                child: _WorkTypeFilterRow(current: state.workTypeFilter),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent))
                    : orders.isEmpty
                        ? const Center(
                            child: Text('No orders found', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
                            itemCount: orders.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 10),
                            itemBuilder: (_, i) {
                              final o = orders[i];
                              final stageColor = StatusChip.colorForOrderStage(o.stage, o.delivered);
                              return Opacity(
                                opacity: o.delivered ? 0.6 : 1.0,
                                child: InfoCard(
                                  onTap: () => nav.navigateTo(AppScreen.orderDetail, orderId: o.id),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              o.titleText,
                                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                            ),
                                          ),
                                          StatusChip(label: o.stageLabel, color: stageColor),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        '${o.customer} · ${o.qty} pcs · due ${o.due}',
                                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        children: [
                                          _WorkTypeBadge(workType: o.workType),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      AppProgressBar(value: o.stageProgress / 100, color: stageColor, height: 5),
                                    ],
                                  ),
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

class _WorkTypeFilterRow extends StatelessWidget {
  final WorkTypeFilter current;
  const _WorkTypeFilterRow({required this.current});

  @override
  Widget build(BuildContext context) {
    final labels = ['All Types', 'In House', 'External'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(WorkTypeFilter.values.length, (i) {
          final selected = current == WorkTypeFilter.values[i];
          return GestureDetector(
            onTap: () => context.read<OrdersCubit>().setWorkTypeFilter(WorkTypeFilter.values[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: EdgeInsets.only(right: i < WorkTypeFilter.values.length - 1 ? 8 : 0),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? AppColors.accent.withValues(alpha: 0.12) : AppColors.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                border: Border.all(color: selected ? AppColors.accent : AppColors.border),
              ),
              child: Text(
                labels[i],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: selected ? AppColors.accent : AppColors.textSecondary,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _WorkTypeBadge extends StatelessWidget {
  final WorkType workType;
  const _WorkTypeBadge({required this.workType});

  @override
  Widget build(BuildContext context) {
    final isInHouse = workType == WorkType.inHouse;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isInHouse ? AppColors.accentSoft : AppColors.tagBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isInHouse ? Icons.factory_outlined : Icons.local_shipping_outlined,
            size: 11,
            color: isInHouse ? AppColors.accent : AppColors.tagText,
          ),
          const SizedBox(width: 4),
          Text(
            workType.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isInHouse ? AppColors.accent : AppColors.tagText,
            ),
          ),
        ],
      ),
    );
  }
}
