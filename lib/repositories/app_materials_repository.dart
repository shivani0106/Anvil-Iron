import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_material.dart';

class AppMaterialsRepository {
  final _client = Supabase.instance.client;

  Future<List<AppMaterial>> fetchAll() async {
    final data = await _client.from('materials').select().order('name');
    return (data as List).map((e) => AppMaterial.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<AppMaterial> create(AppMaterial material) async {
    final json = material.toInsertJson()..['user_id'] = _client.auth.currentUser!.id;
    final data = await _client.from('materials').insert(json).select().single();
    return AppMaterial.fromJson(data);
  }

  Future<AppMaterial> update(AppMaterial material) async {
    final data = await _client
        .from('materials')
        .update(material.toUpdateJson())
        .eq('id', material.id)
        .select()
        .single();
    return AppMaterial.fromJson(data);
  }

  Future<void> delete(int id) async {
    await _client.from('materials').delete().eq('id', id);
  }

  RealtimeChannel subscribeToChanges(void Function() onChanged) {
    return _client
        .channel('public:materials')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'materials',
          callback: (_) => onChanged(),
        )
        .subscribe();
  }
}
