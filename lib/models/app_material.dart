import 'package:equatable/equatable.dart';

// Named AppMaterial to avoid clash with Flutter's Material widget.
class AppMaterial extends Equatable {
  final int id;
  final String name;
  final String type;
  final String quality;
  final double quantity;
  final String unit;
  final String supplierName;
  final double? cost;
  final String notes;

  const AppMaterial({
    required this.id,
    required this.name,
    this.type = '',
    this.quality = '',
    this.quantity = 0,
    this.unit = '',
    this.supplierName = '',
    this.cost,
    this.notes = '',
  });

  String get displayQty => unit.isEmpty ? '$quantity' : '$quantity $unit';

  String get costLabel => cost != null ? '₹${cost!.toStringAsFixed(2)}' : '—';

  factory AppMaterial.fromJson(Map<String, dynamic> json) => AppMaterial(
        id: json['id'] as int,
        name: json['name'] as String,
        type: (json['type'] as String?) ?? '',
        quality: (json['quality'] as String?) ?? '',
        quantity: (json['quantity'] as num? ?? 0).toDouble(),
        unit: (json['unit'] as String?) ?? '',
        supplierName: (json['supplier_name'] as String?) ?? '',
        cost: (json['cost'] as num?)?.toDouble(),
        notes: (json['notes'] as String?) ?? '',
      );

  Map<String, dynamic> toInsertJson() => {
        'name': name,
        'type': type.isEmpty ? null : type,
        'quality': quality.isEmpty ? null : quality,
        'quantity': quantity,
        'unit': unit.isEmpty ? null : unit,
        'supplier_name': supplierName.isEmpty ? null : supplierName,
        'cost': cost,
        'notes': notes.isEmpty ? null : notes,
      };

  Map<String, dynamic> toUpdateJson() => toInsertJson();

  AppMaterial copyWith({
    String? name,
    String? type,
    String? quality,
    double? quantity,
    String? unit,
    String? supplierName,
    double? cost,
    String? notes,
  }) =>
      AppMaterial(
        id: id,
        name: name ?? this.name,
        type: type ?? this.type,
        quality: quality ?? this.quality,
        quantity: quantity ?? this.quantity,
        unit: unit ?? this.unit,
        supplierName: supplierName ?? this.supplierName,
        cost: cost ?? this.cost,
        notes: notes ?? this.notes,
      );

  @override
  List<Object?> get props => [id, name, type, quality, quantity, unit, supplierName, cost, notes];
}
