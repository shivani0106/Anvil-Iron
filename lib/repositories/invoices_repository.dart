import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/invoice.dart';

class InvoicesRepository {
  final _client = Supabase.instance.client;

  Future<List<Invoice>> fetchAllInvoices() async {
    final data = await _client.from('invoices').select().order('date', ascending: false);
    return (data as List).map((e) => Invoice.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Quote>> fetchAllQuotes() async {
    final data = await _client.from('quotes').select().order('date', ascending: false);
    return (data as List).map((e) => Quote.fromJson(e as Map<String, dynamic>)).toList();
  }
}
