import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/drawing.dart';

class DrawingsRepository {
  final _client = Supabase.instance.client;
  static const _bucket = 'project-files';

  Future<List<Drawing>> fetchAll() async {
    final data = await _client
        .from('drawings')
        .select()
        .eq('user_id', _client.auth.currentUser!.id)
        .order('created_at', ascending: false);
    return (data as List)
        .map((e) => Drawing.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Drawing> upload({
    required String fileName,
    required String customer,
    required String rev,
    required List<int> bytes,
    required String fileType,
  }) async {
    final userId = _client.auth.currentUser!.id;
    final storagePath =
        '$userId/${DateTime.now().millisecondsSinceEpoch}_$fileName';

    await _client.storage.from(_bucket).uploadBinary(
          storagePath,
          Uint8List.fromList(bytes),
          fileOptions: FileOptions(contentType: _mimeType(fileType)),
        );

    final signedUrl = await _client.storage
        .from(_bucket)
        .createSignedUrl(storagePath, 60 * 60 * 24 * 365);

    final expiresAt = DateTime.now().add(const Duration(days: 365));

    final record = await _client.from('drawings').insert({
      'user_id': userId,
      'file_name': fileName,
      'customer': customer,
      'storage_path': storagePath,
      'signed_url': signedUrl,
      'url_expires_at': expiresAt.toIso8601String(),
      'file_type': fileType.toLowerCase().replaceAll('.', ''),
      'file_size': bytes.length,
      'rev': rev.isEmpty ? 'rev 1' : rev,
      'uploaded_by': userId,
    }).select().single();

    return Drawing.fromJson(record);
  }

  Future<void> delete(String id, String storagePath) async {
    await _client.storage.from(_bucket).remove([storagePath]);
    await _client.from('drawings').delete().eq('id', id);
  }

  Future<String> refreshSignedUrl(String id, String storagePath) async {
    final newUrl = await _client.storage
        .from(_bucket)
        .createSignedUrl(storagePath, 60 * 60 * 24 * 365);
    await _client.from('drawings').update({
      'signed_url': newUrl,
      'url_expires_at':
          DateTime.now().add(const Duration(days: 365)).toIso8601String(),
    }).eq('id', id);
    return newUrl;
  }

  String _mimeType(String ext) {
    final e = ext.toLowerCase().replaceAll('.', '');
    return switch (e) {
      'pdf' => 'application/pdf',
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'dwg' => 'image/vnd.dwg',
      'dxf' => 'image/vnd.dxf',
      'step' => 'model/step',
      'sldprt' => 'application/octet-stream',
      _ => 'application/octet-stream',
    };
  }
}
