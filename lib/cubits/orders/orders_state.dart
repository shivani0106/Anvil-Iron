import 'package:equatable/equatable.dart';
import '../../models/order.dart';

enum OrderFilter { all, active, done }

class OrdersState extends Equatable {
  final List<Order> orders;
  final OrderFilter filter;
  final String searchQuery;
  final String formCustomer;
  final String formItem;
  final String formQty;
  final String formMaterial;
  final String formDue;
  final String formError;

  const OrdersState({
    required this.orders,
    this.filter = OrderFilter.all,
    this.searchQuery = '',
    this.formCustomer = '',
    this.formItem = '',
    this.formQty = '',
    this.formMaterial = '',
    this.formDue = '',
    this.formError = '',
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

    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      list = list.where((o) {
        return '#${o.id} ${o.customer} ${o.item}'.toLowerCase().contains(q);
      }).toList();
    }

    return list;
  }

  List<Order> get activeOrders => orders.where((o) => !o.delivered).toList();

  OrdersState copyWith({
    List<Order>? orders,
    OrderFilter? filter,
    String? searchQuery,
    String? formCustomer,
    String? formItem,
    String? formQty,
    String? formMaterial,
    String? formDue,
    String? formError,
  }) {
    return OrdersState(
      orders: orders ?? this.orders,
      filter: filter ?? this.filter,
      searchQuery: searchQuery ?? this.searchQuery,
      formCustomer: formCustomer ?? this.formCustomer,
      formItem: formItem ?? this.formItem,
      formQty: formQty ?? this.formQty,
      formMaterial: formMaterial ?? this.formMaterial,
      formDue: formDue ?? this.formDue,
      formError: formError ?? this.formError,
    );
  }

  @override
  List<Object?> get props => [orders, filter, searchQuery, formCustomer, formItem, formQty, formMaterial, formDue, formError];
}
