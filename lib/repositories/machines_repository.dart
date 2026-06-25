import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/machine.dart';

class MachinesRepository {
  final _client = Supabase.instance.client;

  Future<List<Machine>> fetchAll() async {
    final data = await _client.from('machines').select().order('id');
    return (data as List).map((e) => Machine.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Machine> create(Machine machine) async {
    final json = machine.toJson()..['user_id'] = _client.auth.currentUser!.id;
    final data = await _client.from('machines').insert(json).select().single();
    return Machine.fromJson(data);
  }

  Future<Machine> update(Machine machine) async {
    final data = await _client
        .from('machines')
        .update(machine.toUpdateJson())
        .eq('id', machine.id)
        .select()
        .single();
    return Machine.fromJson(data);
  }

  Future<void> delete(int id) async {
    await _client.from('machines').delete().eq('id', id);
  }

  RealtimeChannel subscribeToChanges(void Function() onChanged) {
    return _client
        .channel('public:machines')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'machines',
          callback: (_) => onChanged(),
        )
        .subscribe();
  }
}
