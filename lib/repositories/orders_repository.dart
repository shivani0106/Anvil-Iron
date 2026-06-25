import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order.dart';

class OrdersRepository {
  final _client = Supabase.instance.client;

  Future<List<Order>> fetchAll() async {
    final data = await _client.from('orders').select().order('id');
    return (data as List).map((e) => Order.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Order> create(Order order) async {
    final json = order.toJson()..['user_id'] = _client.auth.currentUser!.id;
    final data = await _client.from('orders').insert(json).select().single();
    return Order.fromJson(data);
  }

  Future<void> advanceStage(int id, OrderStage newStage, {bool delivered = false}) async {
    await _client.from('orders').update({
      'stage': newStage.name,
      'delivered': delivered,
    }).eq('id', id);
  }

  Future<void> updateWorkType(int id, WorkType workType) async {
    await _client.from('orders').update({'work_type': workType.value}).eq('id', id);
  }

  Future<void> linkCustomer(int orderId, int? customerId) async {
    await _client.from('orders').update({'customer_id': customerId}).eq('id', orderId);
  }

  Future<void> linkSupplier(int orderId, int? supplierId) async {
    await _client.from('orders').update({'supplier_id': supplierId}).eq('id', orderId);
  }
}
