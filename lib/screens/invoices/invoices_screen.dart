import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_color_scheme.dart';
import '../../cubits/navigation/navigation_cubit.dart';
import '../../cubits/invoices/invoices_cubit.dart';
import '../../cubits/invoices/invoices_state.dart';
import '../../models/invoice.dart';
import '../../widgets/common/screen_app_bar.dart';
import '../../widgets/common/filter_chip_row.dart';
import '../../widgets/common/info_card.dart';
import '../../widgets/common/status_chip.dart';

class InvoicesScreen extends StatelessWidget {
  const InvoicesScreen({super.key});

  String _inr(double amount) {
    if (amount >= 100000) return '₹${(amount / 100000).toStringAsFixed(1)}L';
    if (amount >= 1000) return '₹${(amount / 1000).toStringAsFixed(1)}K';
    return '₹${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InvoicesCubit, InvoicesState>(
      builder: (ctx, state) {
        final cubit = ctx.read<InvoicesCubit>();
        final nav = ctx.read<NavigationCubit>();

        return Scaffold(
          backgroundColor: context.colors.background,
          appBar: ScreenAppBar(
            title: 'Invoices & Quotes',
            action: GestureDetector(
              onTap: () => nav.showToast(
                  state.activeTab == InvoiceTab.invoices ? 'New invoice (demo)' : 'New quote (demo)'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColorScheme.accent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  state.activeTab == InvoiceTab.invoices ? '+ Invoice' : '+ Quote',
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
                child: FilterChipRow(
                  labels: const ['Invoices', 'Quotes'],
                  selectedIndex: state.activeTab.index,
                  onSelected: (i) => cubit.setTab(InvoiceTab.values[i]),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: state.activeTab == InvoiceTab.invoices
                    ? _buildInvoicesList(context, state.invoices, nav)
                    : _buildQuotesList(context, state.quotes, nav),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInvoicesList(BuildContext context, List<Invoice> invoices, NavigationCubit nav) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
      itemCount: invoices.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final inv = invoices[i];
        final color = StatusChip.colorForInvoice(inv.status);
        return InfoCard(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      inv.id,
                      style: TextStyle(fontSize: 12, color: context.colors.textMuted, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      inv.customer,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.colors.textPrimary),
                    ),
                    Text(
                      inv.date,
                      style: TextStyle(fontSize: 12, color: context.colors.textSecondary),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _inr(inv.amount),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: context.colors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  StatusChip(label: inv.statusLabel, color: color, small: true),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuotesList(BuildContext context, List<Quote> quotes, NavigationCubit nav) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
      itemCount: quotes.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final q = quotes[i];
        final color = q.status == QuoteStatus.won
            ? AppColorScheme.statusReady
            : q.status == QuoteStatus.lost
                ? AppColorScheme.error
                : context.colors.textSecondary;
        return InfoCard(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      q.id,
                      style: TextStyle(fontSize: 12, color: context.colors.textMuted, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      q.customer,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.colors.textPrimary),
                    ),
                    Text(
                      q.date,
                      style: TextStyle(fontSize: 12, color: context.colors.textSecondary),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _inr(q.amount),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: context.colors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  StatusChip(label: q.statusLabel, color: color, small: true),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
