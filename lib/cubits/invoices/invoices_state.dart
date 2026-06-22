import 'package:equatable/equatable.dart';
import '../../models/invoice.dart';

enum InvoiceTab { invoices, quotes }

class InvoicesState extends Equatable {
  final List<Invoice> invoices;
  final List<Quote> quotes;
  final InvoiceTab activeTab;

  const InvoicesState({
    required this.invoices,
    required this.quotes,
    this.activeTab = InvoiceTab.invoices,
  });

  double get totalOutstanding => invoices
      .where((i) => i.status != InvoiceStatus.paid)
      .fold(0.0, (sum, i) => sum + i.amount);

  double get totalOverdue => invoices
      .where((i) => i.status == InvoiceStatus.overdue)
      .fold(0.0, (sum, i) => sum + i.amount);

  double get totalRevenue => invoices
      .where((i) => i.status == InvoiceStatus.paid)
      .fold(0.0, (sum, i) => sum + i.amount);

  InvoicesState copyWith({
    List<Invoice>? invoices,
    List<Quote>? quotes,
    InvoiceTab? activeTab,
  }) {
    return InvoicesState(
      invoices: invoices ?? this.invoices,
      quotes: quotes ?? this.quotes,
      activeTab: activeTab ?? this.activeTab,
    );
  }

  @override
  List<Object?> get props => [invoices, quotes, activeTab];
}
