import 'package:equatable/equatable.dart';
import '../../models/order.dart';

enum OrderFilter { all, active, done }
enum WorkTypeFilter { all, inHouse, external }

class OrdersState extends Equatable {
  final List<Order> orders;
  final OrderFilter filter;
  final WorkTypeFilter workTypeFilter;
  final String searchQuery;
  final String formCustomer;
  final String formItem;
  final String formQty;
  final String formMaterial;
  final String formDue;
  final WorkType formWorkType;
  final List<String> formWorkflowSteps;
  final String formError;
  final bool isLoading;
  final bool isSubmitting;

  const OrdersState({
    required this.orders,
    this.filter = OrderFilter.all,
    this.workTypeFilter = WorkTypeFilter.all,
    this.searchQuery = '',
    this.formCustomer = '',
    this.formItem = '',
    this.formQty = '',
    this.formMaterial = '',
    this.formDue = '',
    this.formWorkType = WorkType.inHouse,
    this.formWorkflowSteps = const [
      'Raw material received',
      'Cutting',
      'Bending',
      'Machining',
      'Tacking',
      'Welding',
      'QC',
      'Dispatch',
    ],
    this.formError = '',
    this.isLoading = false,
    this.isSubmitting = false,
  });

  List<Order> get filteredOrders {
    var list = orders.where((o) {
      switch (filter) {
        case OrderFilter.all:
          return true;
        case OrderFilter.active:
          return !o.delivered;
        case OrderFilter.done:
          return o.delivered;
      }
    }).toList();

    if (workTypeFilter != WorkTypeFilter.all) {
      final target = workTypeFilter == WorkTypeFilter.inHouse ? WorkType.inHouse : WorkType.external;
      list = list.where((o) => o.workType == target).toList();
    }

    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      list = list.where((o) {
        return '#${o.id} ${o.customer} ${o.item} ${o.workType.label}'.toLowerCase().contains(q);
      }).toList();
    }

    return list;
  }

  List<Order> get activeOrders => orders.where((o) => !o.delivered).toList();

  OrdersState copyWith({
    List<Order>? orders,
    OrderFilter? filter,
    WorkTypeFilter? workTypeFilter,
    String? searchQuery,
    String? formCustomer,
    String? formItem,
    String? formQty,
    String? formMaterial,
    String? formDue,
    WorkType? formWorkType,
    List<String>? formWorkflowSteps,
    String? formError,
    bool? isLoading,
    bool? isSubmitting,
  }) {
    return OrdersState(
      orders: orders ?? this.orders,
      filter: filter ?? this.filter,
      workTypeFilter: workTypeFilter ?? this.workTypeFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      formCustomer: formCustomer ?? this.formCustomer,
      formItem: formItem ?? this.formItem,
      formQty: formQty ?? this.formQty,
      formMaterial: formMaterial ?? this.formMaterial,
      formDue: formDue ?? this.formDue,
      formWorkType: formWorkType ?? this.formWorkType,
      formWorkflowSteps: formWorkflowSteps ?? this.formWorkflowSteps,
      formError: formError ?? this.formError,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [
        orders, filter, workTypeFilter, searchQuery,
        formCustomer, formItem, formQty, formMaterial, formDue,
        formWorkType, formWorkflowSteps, formError, isLoading, isSubmitting,
      ];
}
