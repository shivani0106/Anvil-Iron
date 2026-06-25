import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/team.dart';

class TeamsRepository {
  final _client = Supabase.instance.client;

  Future<List<Teammate>> fetchAll() async {
    final data = await _client
        .from('teams')
        .select()
        .order('team_name');
    return (data as List)
        .map((e) => Teammate.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Teammate> create(Teammate teammate) async {
    final json = teammate.toInsertJson()
      ..['user_id'] = _client.auth.currentUser!.id;
    final data = await _client.from('teams').insert(json).select().single();
    return Teammate.fromJson(data);
  }

  Future<Teammate> update(Teammate teammate) async {
    final data = await _client
        .from('teams')
        .update(teammate.toUpdateJson())
        .eq('id', teammate.id)
        .select()
        .single();
    return Teammate.fromJson(data);
  }

  Future<void> delete(int id) async {
    await _client.from('teams').delete().eq('id', id);
  }

  RealtimeChannel subscribeToChanges(void Function() onChanged) {
    return _client
        .channel('public:teams')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'teams',
          callback: (_) => onChanged(),
        )
        .subscribe();
  }
}
