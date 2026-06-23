import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order.dart';

class OrdersRepository {
  final _client = Supabase.instance.client;

  Future<List<Order>> fetchAll() async {
    final data = await _client.from('orders').select().order('id');
    return (data as List).map((e) => Order.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Order> create(Order order) async {
    final data = await _client.from('orders').insert(order.toJson()).select().single();
    return Order.fromJson(data);
  }

  Future<void> advanceStage(int id, OrderStage newStage, {bool delivered = false}) async {
    await _client.from('orders').update({
      'stage': newStage.name,
      'delivered': delivered,
    }).eq('id', id);
  }
}
