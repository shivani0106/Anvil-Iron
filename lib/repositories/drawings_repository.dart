import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/drawing.dart';

class DrawingsRepository {
  final _client = Supabase.instance.client;

  Future<List<Drawing>> fetchAll() async {
    final data = await _client.from('drawings').select().order('name');
    return (data as List).map((e) => Drawing.fromJson(e as Map<String, dynamic>)).toList();
  }
}
