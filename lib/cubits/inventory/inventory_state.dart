import 'package:equatable/equatable.dart';
import '../../models/inventory_item.dart';

class InventoryState extends Equatable {
  final List<InventoryItem> items;
  final String searchQuery;
  final String stockInput;

  const InventoryState({
    required this.items,
    this.searchQuery = '',
    this.stockInput = '',
  });

  List<InventoryItem> get filteredItems {
    if (searchQuery.trim().isEmpty) return items;
    final q = searchQuery.trim().toLowerCase();
    return items.where((m) => '${m.name} ${m.category}'.toLowerCase().contains(q)).toList();
  }

  List<InventoryItem> get lowStockItems => items.where((m) => m.isLow).toList();

  InventoryState copyWith({
    List<InventoryItem>? items,
    String? searchQuery,
    String? stockInput,
  }) {
    return InventoryState(
      items: items ?? this.items,
      searchQuery: searchQuery ?? this.searchQuery,
      stockInput: stockInput ?? this.stockInput,
    );
  }

  @override
  List<Object?> get props => [items, searchQuery, stockInput];
}
