import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/team_member.dart';

class TeamRepository {
  final _client = Supabase.instance.client;

  Future<List<TeamMember>> fetchAll() async {
    final data = await _client.from('team_members').select().order('name');
    return (data as List).map((e) => TeamMember.fromJson(e as Map<String, dynamic>)).toList();
  }
}
