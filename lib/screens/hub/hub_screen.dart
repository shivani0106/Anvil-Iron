import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import '../../cubits/navigation/navigation_cubit.dart';
import '../../cubits/navigation/navigation_state.dart';
import '../../cubits/orders/orders_cubit.dart';
import '../../cubits/orders/orders_state.dart';
import '../../cubits/inventory/inventory_cubit.dart';
import '../../cubits/inventory/inventory_state.dart';
import '../../cubits/invoices/invoices_cubit.dart';
import '../../cubits/invoices/invoices_state.dart';
import '../../models/order.dart';
import '../../widgets/common/status_chip.dart';
import '../../widgets/common/info_card.dart';
import '../../widgets/common/progress_bar.dart';

class HubScreen extends StatelessWidget {
  const HubScreen({super.key});

  String _inr(double amount) {
    if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(0)}K';
    }
    return '₹${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersCubit, OrdersState>(
      builder: (ctx, ordersState) {
        return BlocBuilder<InventoryCubit, InventoryState>(
          builder: (ctx, invState) {
            return BlocBuilder<InvoicesCubit, InvoicesState>(
              builder: (ctx, invState2) {
                final nav = ctx.read<NavigationCubit>();
                final activeOrders = ordersState.activeOrders;
                final lowStock = invState.lowStockItems;
                final outstanding = invState2.totalOutstanding;
                final overdue = invState2.totalOverdue;
                final revenue = invState2.totalRevenue;
                final hubJobs = activeOrders.take(3).toList();

                return Scaffold(
                  backgroundColor: AppColors.background,
                  body: SafeArea(
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(child: _buildHeader(ctx, nav)),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // New Order CTA
                                _buildNewOrderCta(ctx, nav),
                                const SizedBox(height: 18),
                                // Stats grid
                                _buildStatsGrid(ctx, nav, activeOrders.length, lowStock.length, outstanding, overdue, revenue),
                                const SizedBox(height: 18),
                                // Quick access grid
                                _buildQuickAccess(ctx, nav),
                                const SizedBox(height: 18),
                                // Recent jobs
                                if (hubJobs.isNotEmpty) ...[
                                  const Text(
                                    'Active Jobs',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  ...hubJobs.map((o) => Padding(
                                        padding: const EdgeInsets.only(bottom: 10),
                                        child: _buildJobCard(ctx, nav, o),
                                      )),
                                ],
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildHeader(BuildContext ctx, NavigationCubit nav) {
    final authState = ctx.read<AuthCubit>().state;
    final firstName = authState is AppAuthAuthenticated
        ? authState.firstName
        : 'there';
    final initials = authState is AppAuthAuthenticated
        ? authState.initials
        : '?';

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SHREE IRON WORKS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.06,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Hello, $firstName',
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.02,
                  ),
                ),
              ],
            ),
          ),
          // AI assistant button
          GestureDetector(
            onTap: () => nav.navigateTo(AppScreen.agent),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  size: 22, color: AppColors.accent),
            ),
          ),
          const SizedBox(width: 10),
          // Avatar — tap to open profile / logout menu
          GestureDetector(
            onTap: () => _showProfileMenu(ctx, authState),
            child: AvatarCircle(
              initials: initials,
              size: 44,
              bg: AppColors.surface,
              fg: AppColors.tagText,
            ),
          ),
        ],
      ),
    );
  }

  void _showProfileMenu(BuildContext ctx, AppAuthState authState) {
    final displayName = authState is AppAuthAuthenticated
        ? authState.displayName
        : 'User';
    final email = authState is AppAuthAuthenticated
        ? (authState.user.email ?? '')
        : '';

    showModalBottomSheet<void>(
      context: ctx,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProfileSheet(
        displayName: displayName,
        email: email,
        onLogout: () {
          Navigator.of(ctx).pop(); // close sheet first
          ctx.read<AuthCubit>().signOut();
        },
      ),
    );
  }

  Widget _buildNewOrderCta(BuildContext ctx, NavigationCubit nav) {
    return GestureDetector(
      onTap: () {
        ctx.read<OrdersCubit>().resetForm();
        nav.navigateTo(AppScreen.newOrder);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          boxShadow: const [
            BoxShadow(
              color: Color(0x99E07A3C),
              blurRadius: 20,
              offset: Offset(0, 8),
              spreadRadius: -8,
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: Colors.white, size: 22),
            SizedBox(width: 8),
            Text(
              'New Job Order',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext ctx, NavigationCubit nav, int activeCount, int lowCount, double outstanding, double overdue, double revenue) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        StatCard(
          label: 'Active orders',
          value: '$activeCount',
          onTap: () => nav.navigateTo(AppScreen.orders),
        ),
        StatCard(
          label: 'Low stock items',
          value: '$lowCount',
          valueColor: lowCount > 0 ? AppColors.error : AppColors.textPrimary,
          onTap: () => nav.navigateTo(AppScreen.inventory),
        ),
        StatCard(
          label: 'Outstanding',
          value: _inr(outstanding),
          valueColor: AppColors.invoiceOutstanding,
          onTap: () => nav.navigateTo(AppScreen.invoices),
        ),
        StatCard(
          label: 'Overdue',
          value: _inr(overdue),
          valueColor: overdue > 0 ? AppColors.invoiceOverdue : AppColors.textPrimary,
          onTap: () => nav.navigateTo(AppScreen.invoices),
        ),
      ],
    );
  }

  Widget _buildQuickAccess(BuildContext ctx, NavigationCubit nav) {
    final items = [
      _QuickItem(Icons.inventory_2_outlined, 'Inventory', () => nav.navigateTo(AppScreen.inventory)),
      _QuickItem(Icons.receipt_long_outlined, 'Invoices', () => nav.navigateTo(AppScreen.invoices)),
      _QuickItem(Icons.precision_manufacturing_outlined, 'Machines', () => nav.navigateTo(AppScreen.machines)),
      _QuickItem(Icons.description_outlined, 'Drawings', () => nav.navigateTo(AppScreen.drawings)),
      _QuickItem(Icons.store_outlined, 'Suppliers', () => nav.navigateTo(AppScreen.suppliers)),
      _QuickItem(Icons.bar_chart_outlined, 'Reports', () => nav.navigateTo(AppScreen.reports)),
      _QuickItem(Icons.people_outline, 'Team', () => nav.navigateTo(AppScreen.team)),
      _QuickItem(Icons.list_alt_outlined, 'Orders', () => nav.navigateTo(AppScreen.orders)),
    ];

    return GridView.count(
      crossAxisCount: 4,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 0.9,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: items.map((item) => _buildQuickItem(item)).toList(),
    );
  }

  Widget _buildQuickItem(_QuickItem item) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, size: 22, color: AppColors.accent),
            const SizedBox(height: 6),
            Text(
              item.label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobCard(BuildContext ctx, NavigationCubit nav, Order order) {
    final stageColor = StatusChip.colorForOrderStage(order.stage, order.delivered);
    return InfoCard(
      onTap: () => nav.navigateTo(AppScreen.orderDetail, orderId: order.id),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.titleText,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${order.customer} · due ${order.due}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          StatusChip(label: order.stageLabel, color: stageColor),
        ],
      ),
    );
  }
}

class _QuickItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  _QuickItem(this.icon, this.label, this.onTap);
}

// ── Profile / logout bottom sheet ─────────────────────────────────────────────

class _ProfileSheet extends StatelessWidget {
  final String displayName;
  final String email;
  final VoidCallback onLogout;

  const _ProfileSheet({
    required this.displayName,
    required this.email,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // User info
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 4),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.accentSoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.person_outline_rounded,
                      color: AppColors.accent, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (email.isNotEmpty)
                        Text(
                          email,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 24, color: AppColors.divider),
          // Logout row
          InkWell(
            onTap: onLogout,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.errorSoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.logout_rounded,
                        color: AppColors.error, size: 18),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'Sign out',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
