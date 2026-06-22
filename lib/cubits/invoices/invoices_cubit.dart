import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/sample_data.dart';
import 'invoices_state.dart';

class InvoicesCubit extends Cubit<InvoicesState> {
  InvoicesCubit()
      : super(InvoicesState(
          invoices: SampleData.invoices,
          quotes: SampleData.quotes,
        ));

  void setTab(InvoiceTab tab) {
    emit(state.copyWith(activeTab: tab));
  }
}
