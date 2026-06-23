import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/machine.dart';

class MachinesRepository {
  final _client = Supabase.instance.client;

  Future<List<Machine>> fetchAll() async {
    final data = await _client.from('machines').select().order('id');
    return (data as List).map((e) => Machine.fromJson(e as Map<String, dynamic>)).toList();
  }
}
