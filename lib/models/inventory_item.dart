import 'package:equatable/equatable.dart';

class StockLogEntry extends Equatable {
  final String date;
  final int delta;
  final String note;

  const StockLogEntry({required this.date, required this.delta, required this.note});

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
