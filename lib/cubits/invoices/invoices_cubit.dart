import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/invoices_repository.dart';
import 'invoices_state.dart';

class InvoicesCubit extends Cubit<InvoicesState> {
  final InvoicesRepository _repo;

  InvoicesCubit({InvoicesRepository? repo})
      : _repo = repo ?? InvoicesRepository(),
        super(const InvoicesState(invoices: [], quotes: [], isLoading: true)) {
    loadData();
  }

  Future<void> loadData() async {
    emit(state.copyWith(isLoading: true));
    final invoices = await _repo.fetchAllInvoices();
    final quotes = await _repo.fetchAllQuotes();
    emit(state.copyWith(invoices: invoices, quotes: quotes, isLoading: false));
  }

  void setTab(InvoiceTab tab) {
    emit(state.copyWith(activeTab: tab));
  }
}
