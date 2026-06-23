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

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
        id: json['id'] as String,
        customer: json['customer'] as String,
        amount: (json['amount'] as num).toDouble(),
        status: InvoiceStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => InvoiceStatus.outstanding,
        ),
        date: json['date'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'customer': customer,
        'amount': amount,
        'status': status.name,
        'date': date,
      };

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

  factory Quote.fromJson(Map<String, dynamic> json) => Quote(
        id: json['id'] as String,
        customer: json['customer'] as String,
        amount: (json['amount'] as num).toDouble(),
        status: QuoteStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => QuoteStatus.pending,
        ),
        date: json['date'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'customer': customer,
        'amount': amount,
        'status': status.name,
        'date': date,
      };

  @override
  List<Object?> get props => [id, customer, amount, status, date];
}
