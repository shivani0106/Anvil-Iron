import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/job_team.dart';

class JobTeamsRepository {
  final _client = Supabase.instance.client;

  Future<List<JobTeam>> fetchForOrder(int orderId) async {
    final data = await _client
        .from('job_teams')
        .select()
        .eq('order_id', orderId)
        .order('created_at');
    return (data as List).map((e) => JobTeam.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<JobTeam> create(JobTeam team, int orderId) async {
    final data = await _client
        .from('job_teams')
        .insert(team.toInsertJson(orderId))
        .select()
        .single();
    return JobTeam.fromJson(data);
  }

  Future<void> update(int id, JobTeam team) async {
    await _client.from('job_teams').update({
      'team_name': team.teamName,
      'leader': team.leader.isEmpty ? null : team.leader,
      'contact': team.contact.isEmpty ? null : team.contact,
      'members_count': team.membersCount,
      'notes': team.notes.isEmpty ? null : team.notes,
    }).eq('id', id);
  }

  Future<void> delete(int id) async {
    await _client.from('job_teams').delete().eq('id', id);
  }
}
