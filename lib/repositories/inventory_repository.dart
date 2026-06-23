import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/inventory_item.dart';

class InventoryRepository {
  final _client = Supabase.instance.client;

  Future<List<InventoryItem>> fetchAll() async {
    final data = await _client
        .from('inventory_items')
        .select('*, stock_log_entries(*)')
        .order('id');
    return (data as List).map((e) => InventoryItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> updateQty(int itemId, double newQty) async {
    await _client.from('inventory_items').update({'qty': newQty}).eq('id', itemId);
  }

  Future<void> addStockLogEntry(int itemId, StockLogEntry entry) async {
    await _client.from('stock_log_entries').insert({
      'item_id': itemId,
      'date': entry.date,
      'delta': entry.delta,
      'note': entry.note,
    });
  }
}
