import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../cubits/navigation/navigation_cubit.dart';
import '../../cubits/orders/orders_cubit.dart';
import '../../cubits/orders/orders_state.dart';
import '../../models/order.dart';
import '../../widgets/common/screen_app_bar.dart';
import '../../widgets/common/status_chip.dart';

class OrderDetailScreen extends StatelessWidget {
  final int orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersCubit, OrdersState>(
      builder: (ctx, state) {
        final order = ctx.read<OrdersCubit>().getOrderById(orderId);

        if (order == null) {
          return Scaffold(
            appBar: ScreenAppBar(title: 'Order'),
            body: const Center(child: Text('Order not found')),
          );
        }

        final stageColor = StatusChip.colorForOrderStage(order.stage, order.delivered);

        String advLabel;
        bool advDisabled = false;
        if (order.delivered) {
          advLabel = '✓ Delivered';
          advDisabled = true;
        } else if (order.stage == OrderStage.ready) {
          advLabel = 'Mark as Delivered';
        } else {
          advLabel = 'Advance → ${Order.stageLabels[order.stage.index + 1]}';
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: ScreenAppBar(title: '#${order.id} · ${order.customer}'),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status badge + item
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        order.item,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.02,
                        ),
                      ),
                    ),
                    StatusChip(label: order.stageLabel, color: stageColor),
                  ],
                ),
                const SizedBox(height: 16),
                // Details grid
                _buildDetailsGrid(order),
                const SizedBox(height: 20),
                // Stage pipeline
                const Text(
                  'Production Stage',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 14),
                _buildStagePipeline(order),
                const SizedBox(height: 24),
                // Advance button
                if (!advDisabled)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final ordersCubit = ctx.read<OrdersCubit>();
                        final navCubit = ctx.read<NavigationCubit>();
                        await ordersCubit.advanceStage(orderId);
                        final updated = ordersCubit.getOrderById(orderId);
                        if (updated != null && updated.delivered) {
                          navCubit.showToast('Order #$orderId delivered ✓');
                        } else if (updated != null) {
                          navCubit.showToast('Moved to ${updated.stageLabel}');
                        }
                      },
                      child: Text(advLabel),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: AppColors.statusDelivered.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: const Center(
                      child: Text(
                        '✓ Delivered',
                        style: TextStyle(
                          color: AppColors.statusDelivered,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailsGrid(Order order) {
    final details = [
      ['Customer', order.customer],
      ['Qty', '${order.qty} pcs'],
      ['Material', order.material],
      ['Spec', order.spec.isEmpty ? '—' : order.spec],
      ['Due', order.due],
      ['Ordered', order.ordered],
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: details.asMap().entries.map((e) {
          final isLast = e.key == details.length - 1;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 90,
                      child: Text(
                        e.value[0],
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        e.value[1],
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast) const Divider(height: 1, color: AppColors.divider),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStagePipeline(Order order) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: Order.stageLabels.asMap().entries.map((e) {
        final i = e.key;
        final label = e.value;
        final done = order.delivered || i < order.stage.index;
        final current = !order.delivered && i == order.stage.index;
        final isLast = i == Order.stageLabels.length - 1;

        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (done || current) ? AppColors.accent : AppColors.surface,
                      border: Border.all(
                        color: (done || current) ? AppColors.accent : AppColors.borderLight,
                        width: 2,
                      ),
                    ),
                    child: done
                        ? const Icon(Icons.check, size: 10, color: Colors.white)
                        : null,
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: done ? AppColors.accent : AppColors.borderLight,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: current ? FontWeight.w700 : FontWeight.w500,
                  color: current ? AppColors.textPrimary : (done ? AppColors.textSecondary : AppColors.textMuted),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
