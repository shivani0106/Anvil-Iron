import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../models/order.dart';
import '../../repositories/orders_repository.dart';
import 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  final OrdersRepository _repo;

  OrdersCubit({OrdersRepository? repo})
      : _repo = repo ?? OrdersRepository(),
        super(const OrdersState(orders: [], isLoading: true)) {
    loadData();
  }

  Future<void> loadData() async {
    emit(state.copyWith(isLoading: true));
    final orders = await _repo.fetchAll();
    emit(state.copyWith(orders: orders, isLoading: false));
  }

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

  Future<int?> submitOrder() async {
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

    final maxId = state.orders.isEmpty ? 1000 : state.orders.map((o) => o.id).reduce((a, b) => a > b ? a : b);
    final nextId = maxId + 1;
    final today = DateFormat('MMM d').format(DateTime.now());

    final newOrder = Order(
      id: nextId,
      customer: state.formCustomer.trim(),
      item: state.formItem.trim(),
      spec: '',
      qty: int.parse(state.formQty.trim()),
      material: state.formMaterial.trim().isEmpty ? 'TBD' : state.formMaterial.trim(),
      due: state.formDue.trim().isEmpty ? 'TBD' : state.formDue.trim(),
      ordered: today,
      stage: OrderStage.queued,
    );

    final created = await _repo.create(newOrder);

    emit(state.copyWith(
      orders: [created, ...state.orders],
      formCustomer: '',
      formItem: '',
      formQty: '',
      formMaterial: '',
      formDue: '',
      formError: '',
    ));

    return created.id;
  }

  Future<void> advanceStage(int orderId) async {
    final order = state.orders.firstWhere((o) => o.id == orderId);
    if (order.delivered) return;

    final OrderStage? newStage = order.stage.index < OrderStage.values.length - 1
        ? OrderStage.values[order.stage.index + 1]
        : null;
    final bool nowDelivered = newStage == null;
    final effectiveStage = newStage ?? order.stage;

    await _repo.advanceStage(orderId, effectiveStage, delivered: nowDelivered);

    final updated = state.orders.map((o) {
      if (o.id != orderId) return o;
      return o.copyWith(stage: effectiveStage, delivered: nowDelivered);
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
