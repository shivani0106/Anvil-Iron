import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/inventory_item.dart';
import '../../repositories/inventory_repository.dart';
import 'inventory_state.dart';

class InventoryCubit extends Cubit<InventoryState> {
  final InventoryRepository _repo;
  RealtimeChannel? _channel;

  InventoryCubit({InventoryRepository? repo})
      : _repo = repo ?? InventoryRepository(),
        super(const InventoryState(items: [], isLoading: true)) {
    _init();
  }

  Future<void> _init() async {
    await loadData();
    _subscribeRealtime();
  }

  Future<void> loadData() async {
    emit(state.copyWith(isLoading: true));
    final items = await _repo.fetchAll();
    emit(state.copyWith(items: items, isLoading: false));
  }

  void _subscribeRealtime() {
    _channel?.unsubscribe();
    _channel = _repo.subscribeToChanges(() => loadData());
  }

  void setSearch(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void setStockInput(String value) {
    emit(state.copyWith(stockInput: value));
  }

  Future<void> applyStock(int materialId, int delta) async {
    final qty = double.tryParse(state.stockInput.trim());
    if (qty == null || qty <= 0) return;

    final item = state.items.firstWhere((m) => m.id == materialId);
    final newQty = (item.qty + qty * delta).clamp(0.0, double.infinity);
    final today = DateFormat('MMM d').format(DateTime.now());
    final note = delta > 0 ? 'Stock added' : 'Stock used';
    final entry = StockLogEntry(date: today, delta: (qty * delta).round(), note: note);

    await _repo.updateQty(materialId, newQty);
    await _repo.addStockLogEntry(materialId, entry);

    final updated = state.items.map((m) {
      if (m.id != materialId) return m;
      return m.copyWith(qty: newQty, log: [entry, ...m.log]);
    }).toList();

    emit(state.copyWith(items: updated, stockInput: ''));
  }

  Future<void> addItem(InventoryItem item) async {
    try {
      final created = await _repo.addItem(item);
      emit(state.copyWith(items: [...state.items, created]));
    } catch (_) {}
  }

  InventoryItem? getItemById(int id) {
    try {
      return state.items.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> close() {
    _channel?.unsubscribe();
    return super.close();
  }
}
