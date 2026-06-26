import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../models/order.dart';
import '../../repositories/orders_repository.dart';
import '../../repositories/workflow_steps_repository.dart';
import 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  final OrdersRepository _repo;
  final WorkflowStepsRepository _workflowRepo;

  OrdersCubit({OrdersRepository? repo, WorkflowStepsRepository? workflowRepo})
      : _repo = repo ?? OrdersRepository(),
        _workflowRepo = workflowRepo ?? WorkflowStepsRepository(),
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

  void setWorkTypeFilter(WorkTypeFilter wtf) {
    emit(state.copyWith(workTypeFilter: wtf));
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
    WorkType? workType,
  }) {
    emit(state.copyWith(
      formCustomer: customer ?? state.formCustomer,
      formItem: item ?? state.formItem,
      formQty: qty ?? state.formQty,
      formMaterial: material ?? state.formMaterial,
      formDue: due ?? state.formDue,
      formWorkType: workType ?? state.formWorkType,
      formError: '',
    ));
  }

  static const _defaultWorkflowSteps = [
    'Raw material received',
    'Cutting',
    'Bending',
    'Machining',
    'Tacking',
    'Welding',
    'QC',
    'Dispatch',
  ];

  void resetForm() {
    emit(state.copyWith(
      formCustomer: '',
      formItem: '',
      formQty: '',
      formMaterial: '',
      formDue: '',
      formWorkType: WorkType.inHouse,
      formWorkflowSteps: List.of(_defaultWorkflowSteps),
      formError: '',
    ));
  }

  // ── Form workflow steps (local, saved on submit) ─────────────

  void addFormWorkflowStep(String name) {
    emit(state.copyWith(
      formWorkflowSteps: [...state.formWorkflowSteps, name],
    ));
  }

  void removeFormWorkflowStep(int index) {
    final steps = List<String>.from(state.formWorkflowSteps)..removeAt(index);
    emit(state.copyWith(formWorkflowSteps: steps));
  }

  void moveFormWorkflowStepUp(int index) {
    if (index <= 0) return;
    final steps = List<String>.from(state.formWorkflowSteps);
    final tmp = steps[index];
    steps[index] = steps[index - 1];
    steps[index - 1] = tmp;
    emit(state.copyWith(formWorkflowSteps: steps));
  }

  void moveFormWorkflowStepDown(int index) {
    if (index >= state.formWorkflowSteps.length - 1) return;
    final steps = List<String>.from(state.formWorkflowSteps);
    final tmp = steps[index];
    steps[index] = steps[index + 1];
    steps[index + 1] = tmp;
    emit(state.copyWith(formWorkflowSteps: steps));
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
      workType: state.formWorkType,
    );

    final created = await _repo.create(newOrder);

    final steps = state.formWorkflowSteps;
    if (steps.isNotEmpty) {
      await Future.wait([
        for (var i = 0; i < steps.length; i++)
          _workflowRepo.create(steps[i], created.id, i),
      ]);
    }

    emit(state.copyWith(
      orders: [created, ...state.orders],
      formCustomer: '',
      formItem: '',
      formQty: '',
      formMaterial: '',
      formDue: '',
      formWorkType: WorkType.inHouse,
      formWorkflowSteps: List.of(_defaultWorkflowSteps),
      formError: '',
    ));

    return created.id;
  }

  Future<void> advanceWorkflowStep(int orderId, int totalSteps) async {
    final order = getOrderById(orderId);
    if (order == null || order.delivered) return;

    final nextStep = order.currentStep + 1;
    if (nextStep >= totalSteps) return;

    await _repo.updateCurrentStep(orderId, nextStep);

    final updated = state.orders.map((o) {
      if (o.id != orderId) return o;
      return o.copyWith(currentStep: nextStep);
    }).toList();
    emit(state.copyWith(orders: updated));
  }

  Future<void> markAsDelivered(int orderId) async {
    final order = getOrderById(orderId);
    if (order == null || order.delivered) return;

    await _repo.markAsDelivered(orderId);

    final updated = state.orders.map((o) {
      if (o.id != orderId) return o;
      return o.copyWith(delivered: true, stage: OrderStage.ready);
    }).toList();
    emit(state.copyWith(orders: updated));
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

  void patchOrderLocally(Order updated) {
    final list = state.orders.map((o) => o.id == updated.id ? updated : o).toList();
    emit(state.copyWith(orders: list));
  }

  Order? getOrderById(int id) {
    try {
      return state.orders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }
}
