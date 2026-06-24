import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/customer.dart';

class CustomersRepository {
  final _client = Supabase.instance.client;

  Future<List<Customer>> fetchAll() async {
    final data = await _client.from('customers').select().order('name');
    return (data as List).map((e) => Customer.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Customer> create(Customer customer) async {
    final data = await _client
        .from('customers')
        .insert(customer.toInsertJson())
        .select()
        .single();
    return Customer.fromJson(data);
  }

  Future<Customer> update(Customer customer) async {
    final data = await _client
        .from('customers')
        .update(customer.toUpdateJson())
        .eq('id', customer.id)
        .select()
        .single();
    return Customer.fromJson(data);
  }

  Future<void> delete(int id) async {
    await _client.from('customers').delete().eq('id', id);
  }

  Future<Customer?> fetchById(int id) async {
    final data = await _client.from('customers').select().eq('id', id).maybeSingle();
    if (data == null) return null;
    return Customer.fromJson(data);
  }
}
