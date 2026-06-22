import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../cubits/navigation/navigation_cubit.dart';
import '../../cubits/navigation/navigation_state.dart';
import '../../cubits/orders/orders_cubit.dart';
import '../../cubits/orders/orders_state.dart';
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
              const SizedBox(height: 10),
              Expanded(
                child: orders.isEmpty
                    ? const Center(
                        child: Text(
                          'No orders found',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
                        itemCount: orders.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
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
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      StatusChip(label: o.stageLabel, color: stageColor),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${o.customer} · ${o.qty} pcs · due ${o.due}',
                                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                  ),
                                  const SizedBox(height: 9),
                                  AppProgressBar(
                                    value: o.stageProgress / 100,
                                    color: stageColor,
                                    height: 5,
                                  ),
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
