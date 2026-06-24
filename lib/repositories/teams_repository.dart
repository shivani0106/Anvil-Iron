import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/team.dart';

class TeamsRepository {
  final _client = Supabase.instance.client;

  Future<List<Team>> fetchAll() async {
    final data = await _client.from('teams').select().order('team_name');
    return (data as List).map((e) => Team.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Team> create(Team team) async {
    final data = await _client
        .from('teams')
        .insert(team.toInsertJson())
        .select()
        .single();
    return Team.fromJson(data);
  }

  Future<Team> update(Team team) async {
    final data = await _client
        .from('teams')
        .update(team.toUpdateJson())
        .eq('id', team.id)
        .select()
        .single();
    return Team.fromJson(data);
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
