import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/supplier.dart';

class SuppliersRepository {
  final _client = Supabase.instance.client;

  Future<List<Supplier>> fetchAll() async {
    final data = await _client.from('suppliers').select().order('name');
    return (data as List).map((e) => Supplier.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Supplier> create(Supplier supplier) async {
    final json = supplier.toInsertJson();
    // suppliers table uses integer PK — let Supabase auto-assign or include id
    final data = await _client.from('suppliers').insert(json).select().single();
    return Supplier.fromJson(data);
  }

  Future<Supplier> update(Supplier supplier) async {
    final data = await _client
        .from('suppliers')
        .update(supplier.toUpdateJson())
        .eq('id', supplier.id)
        .select()
        .single();
    return Supplier.fromJson(data);
  }

  Future<void> delete(int id) async {
    await _client.from('suppliers').delete().eq('id', id);
  }

  Future<Supplier?> fetchById(int id) async {
    final data = await _client.from('suppliers').select().eq('id', id).maybeSingle();
    if (data == null) return null;
    return Supplier.fromJson(data);
  }
}
