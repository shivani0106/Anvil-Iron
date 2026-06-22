import 'package:equatable/equatable.dart';

enum InvoiceStatus { paid, outstanding, overdue }

enum QuoteStatus { pending, won, lost }

class Invoice extends Equatable {
  final String id;
  final String customer;
  final double amount;
  final InvoiceStatus status;
  final String date;

  const Invoice({
    required this.id,
    required this.customer,
    required this.amount,
    required this.status,
    required this.date,
  });

  String get statusLabel {
    switch (status) {
      case InvoiceStatus.paid:
        return 'Paid';
      case InvoiceStatus.outstanding:
        return 'Outstanding';
      case InvoiceStatus.overdue:
        return 'Overdue';
    }
  }

  @override
  List<Object?> get props => [id, customer, amount, status, date];
}

class Quote extends Equatable {
  final String id;
  final String customer;
  final double amount;
  final QuoteStatus status;
  final String date;

  const Quote({
    required this.id,
    required this.customer,
    required this.amount,
    required this.status,
    required this.date,
  });

  String get statusLabel {
    switch (status) {
      case QuoteStatus.pending:
        return 'Pending';
      case QuoteStatus.won:
        return 'Won';
      case QuoteStatus.lost:
        return 'Lost';
    }
  }

  @override
  List<Object?> get props => [id, customer, amount, status, date];
}
