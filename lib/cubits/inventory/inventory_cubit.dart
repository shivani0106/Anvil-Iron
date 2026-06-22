import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/inventory_item.dart';
import '../../data/sample_data.dart';
import 'inventory_state.dart';

class InventoryCubit extends Cubit<InventoryState> {
  InventoryCubit() : super(InventoryState(items: SampleData.inventory));

  void setSearch(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void setStockInput(String value) {
    emit(state.copyWith(stockInput: value));
  }

  void applyStock(int materialId, int delta) {
    final qty = double.tryParse(state.stockInput.trim());
    if (qty == null || qty <= 0) return;

    final now = 'today';
    final note = delta > 0 ? 'Stock added' : 'Stock used';

    final updated = state.items.map((m) {
      if (m.id != materialId) return m;
      final newQty = (m.qty + qty * delta).clamp(0.0, double.infinity);
      return m.copyWith(
        qty: newQty,
        log: [StockLogEntry(date: now, delta: (qty * delta).round(), note: note), ...m.log],
      );
    }).toList();

    emit(state.copyWith(items: updated, stockInput: ''));
  }

  InventoryItem? getItemById(int id) {
    try {
      return state.items.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }
}
