import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/order.dart';
import '../../data/sample_data.dart';
import 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit() : super(OrdersState(orders: SampleData.orders));

  void setFilter(OrderFilter filter) {
    emit(state.copyWith(filter: filter, searchQuery: ''));
  }

  void setSearch(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void updateForm({
    String? customer,
    String? item,
    String? qty,
    String? material,
    String? due,
  }) {
    emit(state.copyWith(
      formCustomer: customer ?? state.formCustomer,
      formItem: item ?? state.formItem,
      formQty: qty ?? state.formQty,
      formMaterial: material ?? state.formMaterial,
      formDue: due ?? state.formDue,
      formError: '',
    ));
  }

  void resetForm() {
    emit(state.copyWith(
      formCustomer: '',
      formItem: '',
      formQty: '',
      formMaterial: '',
      formDue: '',
      formError: '',
    ));
  }

  // Returns the new order id if successful, null otherwise
  int? submitOrder() {
    if (state.formCustomer.trim().isEmpty) {
      emit(state.copyWith(formError: 'Customer name is required'));
      return null;
    }
    if (state.formItem.trim().isEmpty) {
      emit(state.copyWith(formError: 'Item description is required'));
      return null;
    }
    if (state.formQty.trim().isEmpty || int.tryParse(state.formQty.trim()) == null) {
      emit(state.copyWith(formError: 'Enter a valid quantity'));
      return null;
    }

    final nextId = state.orders.map((o) => o.id).reduce((a, b) => a > b ? a : b) + 1;
    final newOrder = Order(
      id: nextId,
      customer: state.formCustomer.trim(),
      item: state.formItem.trim(),
      spec: '',
      qty: int.parse(state.formQty.trim()),
      material: state.formMaterial.trim().isEmpty ? 'TBD' : state.formMaterial.trim(),
      due: state.formDue.trim().isEmpty ? 'TBD' : state.formDue.trim(),
      ordered: 'today',
      stage: OrderStage.queued,
    );

    emit(state.copyWith(
      orders: [newOrder, ...state.orders],
      formCustomer: '',
      formItem: '',
      formQty: '',
      formMaterial: '',
      formDue: '',
      formError: '',
    ));

    return nextId;
  }

  void advanceStage(int orderId) {
    final updated = state.orders.map((o) {
      if (o.id != orderId || o.delivered) return o;
      if (o.stage.index < OrderStage.values.length - 1) {
        return o.copyWith(stage: OrderStage.values[o.stage.index + 1]);
      } else {
        return o.copyWith(delivered: true);
      }
    }).toList();
    emit(state.copyWith(orders: updated));
  }

  Order? getOrderById(int id) {
    try {
      return state.orders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }
}
