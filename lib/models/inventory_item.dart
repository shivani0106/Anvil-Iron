import 'package:equatable/equatable.dart';

class StockLogEntry extends Equatable {
  final String date;
  final int delta;
  final String note;

  const StockLogEntry({required this.date, required this.delta, required this.note});

  factory StockLogEntry.fromJson(Map<String, dynamic> json) => StockLogEntry(
        date: json['date'] as String,
        delta: (json['delta'] as num).toInt(),
        note: (json['note'] as String?) ?? '',
      );

  Map<String, dynamic> toJson() => {
        'date': date,
        'delta': delta,
        'note': note,
      };

  @override
  List<Object?> get props => [date, delta, note];
}

class InventoryItem extends Equatable {
  final int id;
  final String name;
  final String category;
  final double qty;
  final String unit;
  final double reorder;
  final List<StockLogEntry> log;

  const InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.qty,
    required this.unit,
    required this.reorder,
    this.log = const [],
  });

  bool get isLow => qty < reorder;

  String get qtyText => '${qty % 1 == 0 ? qty.toInt() : qty} $unit';

  double get stockPercent => (qty / (reorder * 2)).clamp(0.0, 1.0);

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    final logEntries = (json['stock_log_entries'] as List<dynamic>? ?? [])
        .map((e) => StockLogEntry.fromJson(e as Map<String, dynamic>))
        .toList();
    return InventoryItem(
      id: json['id'] as int,
      name: json['name'] as String,
      category: json['category'] as String,
      qty: (json['qty'] as num).toDouble(),
      unit: json['unit'] as String,
      reorder: (json['reorder_qty'] as num).toDouble(),
      log: logEntries,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'qty': qty,
        'unit': unit,
        'reorder_qty': reorder,
      };

  InventoryItem copyWith({
    int? id,
    String? name,
    String? category,
    double? qty,
    String? unit,
    double? reorder,
    List<StockLogEntry>? log,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      qty: qty ?? this.qty,
      unit: unit ?? this.unit,
      reorder: reorder ?? this.reorder,
      log: log ?? this.log,
    );
  }

  @override
  List<Object?> get props => [id, name, category, qty, unit, reorder, log];
}
