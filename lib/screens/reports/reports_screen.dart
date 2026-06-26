import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_color_scheme.dart';
import '../../core/theme/app_theme.dart';
import '../../cubits/invoices/invoices_cubit.dart';
import '../../cubits/invoices/invoices_state.dart';
import '../../cubits/orders/orders_cubit.dart';
import '../../cubits/orders/orders_state.dart';
import '../../models/invoice.dart';
import '../../models/order.dart';
import '../../widgets/common/screen_app_bar.dart';
import '../../widgets/common/info_card.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  static DateTime? _parseDate(String s) {
    final t = s.trim();
    if (t.isEmpty || t == 'TBD') return null;
    try {
      return DateTime.parse(t);
    } catch (_) {}
    try {
      final p = DateFormat('MMM d').parse(t);
      return DateTime(DateTime.now().year, p.month, p.day);
    } catch (_) {}
    try {
      final p = DateFormat('d MMM').parse(t);
      return DateTime(DateTime.now().year, p.month, p.day);
    } catch (_) {}
    return null;
  }

  static String _inr(double amount) {
    if (amount >= 100000) return '₹${(amount / 100000).toStringAsFixed(1)}L';
    if (amount >= 1000) return '₹${(amount / 1000).toStringAsFixed(1)}K';
    return '₹${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersCubit, OrdersState>(
      builder: (ctx, ordersState) {
        return BlocBuilder<InvoicesCubit, InvoicesState>(
          builder: (ctx2, invoicesState) {
            return _buildBody(ctx, ordersState, invoicesState);
          },
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, OrdersState ordersState, InvoicesState invoicesState) {
    if (ordersState.isLoading || invoicesState.isLoading) {
      return Scaffold(
        backgroundColor: context.colors.background,
        appBar: const ScreenAppBar(title: 'Reports'),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final now = DateTime.now();
    final orders = ordersState.orders;
    final invoices = invoicesState.invoices;

    final last6Months = List.generate(6, (i) => DateTime(now.year, now.month - (5 - i)));

    final paidByMonth = <String, double>{};
    for (final inv in invoices.where((i) => i.status == InvoiceStatus.paid)) {
      final d = _parseDate(inv.date);
      if (d == null) continue;
      final key = '${d.year}-${d.month}';
      paidByMonth[key] = (paidByMonth[key] ?? 0) + inv.amount;
    }

    final monthRevenues = last6Months.map((m) => paidByMonth['${m.year}-${m.month}'] ?? 0.0).toList();
    final maxRevenue = monthRevenues.fold(0.0, (a, b) => a > b ? a : b);

    final monthlyData = List.generate(6, (i) {
      final m = last6Months[i];
      final revenue = monthRevenues[i];
      final fraction = maxRevenue > 0 ? revenue / maxRevenue : 0.0;
      return _MonthBar(
        DateFormat('MMM').format(m),
        fraction.clamp(0.0, 1.0),
        revenue > 0 ? _inr(revenue) : '',
      );
    });

    final currentMonthKey = '${now.year}-${now.month}';
    final currentMonthRevenue = paidByMonth[currentMonthKey] ?? 0.0;
    final currentMonthLabel = DateFormat('MMM').format(now);

    final thisMonthOrders = orders.where((o) {
      final d = _parseDate(o.ordered);
      return d != null && d.year == now.year && d.month == now.month;
    }).toList();
    final totalThisMonth = thisMonthOrders.length;

    final leadDays = orders.expand<int>((o) {
      final orderedDate = _parseDate(o.ordered);
      final dueDate = _parseDate(o.due);
      if (orderedDate == null || dueDate == null) return [];
      final diff = dueDate.difference(orderedDate).inDays;
      return diff > 0 ? [diff] : [];
    }).toList();
    final avgLeadTime = leadDays.isEmpty
        ? null
        : leadDays.reduce((a, b) => a + b) / leadDays.length;

    final today = DateTime(now.year, now.month, now.day);
    final ordersWithDue = orders.where((o) => _parseDate(o.due) != null).toList();
    final onTimeCount = ordersWithDue.where((o) {
      if (o.delivered) return true;
      return !_parseDate(o.due)!.isBefore(today);
    }).length;
    final onTimeRate = ordersWithDue.isEmpty ? null : (onTimeCount / ordersWithDue.length * 100).round();

    final stageData = [
      for (final stage in OrderStage.values)
        (
          label: stage == OrderStage.ready ? 'Ready' : stage.name[0].toUpperCase() + stage.name.substring(1),
          count: thisMonthOrders.where((o) => !o.delivered && o.stage == stage).length,
          color: _stageColor(stage),
        ),
    ];
    final deliveredThisMonth = thisMonthOrders.where((o) => o.delivered).length;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: const ScreenAppBar(title: 'Reports'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.9,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _SummaryCard(
                  label: 'Revenue ($currentMonthLabel)',
                  value: currentMonthRevenue > 0 ? _inr(currentMonthRevenue) : '—',
                  color: AppColorScheme.statusReady,
                ),
                _SummaryCard(
                  label: 'Orders ($currentMonthLabel)',
                  value: totalThisMonth > 0 ? '$totalThisMonth' : '—',
                  color: AppColorScheme.accent,
                ),
                _SummaryCard(
                  label: 'Avg. Lead Time',
                  value: avgLeadTime != null ? '${avgLeadTime.toStringAsFixed(1)} days' : '—',
                ),
                _SummaryCard(
                  label: 'On-time Rate',
                  value: onTimeRate != null ? '$onTimeRate%' : '—',
                  color: onTimeRate != null && onTimeRate >= 80
                      ? AppColorScheme.statusReady
                      : AppColorScheme.accent,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Monthly Revenue',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.colors.textPrimary),
            ),
            const SizedBox(height: 14),
            InfoCard(
              padding: const EdgeInsets.all(16),
              child: maxRevenue == 0
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Text(
                          'No paid invoices yet',
                          style: TextStyle(color: context.colors.textMuted, fontSize: 13),
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        SizedBox(
                          height: 140,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: monthlyData.map((bar) {
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        bar.label2,
                                        style: TextStyle(fontSize: 9, color: context.colors.textMuted),
                                      ),
                                      const SizedBox(height: 3),
                                      Flexible(
                                        child: FractionallySizedBox(
                                          heightFactor: 1.0,
                                          child: Align(
                                            alignment: Alignment.bottomCenter,
                                            child: FractionallySizedBox(
                                              heightFactor: bar.value,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: bar.value >= 0.85
                                                      ? AppColorScheme.accent
                                                      : context.colors.accentSoft,
                                                  borderRadius: const BorderRadius.vertical(
                                                    top: Radius.circular(5),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: monthlyData.map((bar) {
                            return Expanded(
                              child: Text(
                                bar.month,
                                style: TextStyle(fontSize: 11, color: context.colors.textMuted),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 20),
            Text(
              'Order Stages (This Month)',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.colors.textPrimary),
            ),
            const SizedBox(height: 14),
            if (totalThisMonth == 0)
              InfoCard(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Center(
                  child: Text(
                    'No orders this month',
                    style: TextStyle(color: context.colors.textMuted, fontSize: 13),
                  ),
                ),
              )
            else
              ...stageData.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _StageRow(s.label, s.count, totalThisMonth, s.color),
                  )),
            if (totalThisMonth > 0 && deliveredThisMonth > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _StageRow('Delivered', deliveredThisMonth, totalThisMonth, AppColorScheme.statusDelivered),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  static Color _stageColor(OrderStage stage) {
    switch (stage) {
      case OrderStage.queued:
        return AppColorScheme.statusQueued;
      case OrderStage.cutting:
        return AppColorScheme.statusCutting;
      case OrderStage.welding:
        return AppColorScheme.statusWelding;
      case OrderStage.qc:
        return AppColorScheme.statusQC;
      case OrderStage.ready:
        return AppColorScheme.statusReady;
    }
  }
}

class _MonthBar {
  final String month;
  final double value;
  final String label2;
  _MonthBar(this.month, this.value, this.label2);
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _SummaryCard({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: context.colors.textSecondary)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color ?? context.colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StageRow extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;

  const _StageRow(this.label, this.count, this.total, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label, style: TextStyle(fontSize: 13, color: context.colors.textPrimary, fontWeight: FontWeight.w500)),
          ),
          Text(
            '$count',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: context.colors.textPrimary),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 80,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: total > 0 ? count / total : 0,
                minHeight: 6,
                backgroundColor: context.colors.border,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
