import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/job_material.dart';

class JobMaterialsRepository {
  final _client = Supabase.instance.client;

  Future<List<JobMaterial>> fetchForOrder(int orderId) async {
    final data = await _client
        .from('job_materials')
        .select()
        .eq('order_id', orderId)
        .order('created_at');
    return (data as List).map((e) => JobMaterial.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<JobMaterial> create(JobMaterial material, int orderId) async {
    final data = await _client
        .from('job_materials')
        .insert(material.toInsertJson(orderId))
        .select()
        .single();
    return JobMaterial.fromJson(data);
  }

  Future<void> update(int id, JobMaterial material) async {
    await _client.from('job_materials').update({
      'name': material.name,
      'type': material.type.isEmpty ? null : material.type,
      'quality': material.quality.isEmpty ? null : material.quality,
    }).eq('id', id);
  }

  Future<void> delete(int id) async {
    await _client.from('job_materials').delete().eq('id', id);
  }
}
