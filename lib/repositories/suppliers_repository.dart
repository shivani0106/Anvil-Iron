import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/supplier.dart';

class SuppliersRepository {
  final _client = Supabase.instance.client;

  Future<List<Supplier>> fetchAll() async {
    final data = await _client.from('suppliers').select().order('name');
    return (data as List).map((e) => Supplier.fromJson(e as Map<String, dynamic>)).toList();
  }
}
