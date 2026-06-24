import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/workflow_step.dart';

class WorkflowStepsRepository {
  final _client = Supabase.instance.client;

  Future<List<WorkflowStep>> fetchForOrder(int orderId) async {
    final data = await _client
        .from('workflow_steps')
        .select()
        .eq('order_id', orderId)
        .order('position');
    return (data as List)
        .map((e) => WorkflowStep.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<WorkflowStep> create(String name, int orderId, int position) async {
    final data = await _client.from('workflow_steps').insert({
      'order_id': orderId,
      'name': name,
      'position': position,
    }).select().single();
    return WorkflowStep.fromJson(data);
  }

  Future<void> delete(int id) async {
    await _client.from('workflow_steps').delete().eq('id', id);
  }

  Future<void> updatePositions(List<WorkflowStep> steps) async {
    await Future.wait(
      steps.map((s) => _client
          .from('workflow_steps')
          .update({'position': s.position})
          .eq('id', s.id)),
    );
  }
}
