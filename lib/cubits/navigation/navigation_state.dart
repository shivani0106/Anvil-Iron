import 'package:equatable/equatable.dart';

enum AppScreen {
  hub,
  orders,
  orderDetail,
  newOrder,
  inventory,
  stockLog,
  suppliers,
  invoices,
  drawings,
  machines,
  reports,
  team,
  agent,
  customers,
  materials,
}

class ScreenEntry extends Equatable {
  final AppScreen screen;
  final int? orderId;
  final int? materialId;
  final int? customerId;

  const ScreenEntry({
    required this.screen,
    this.orderId,
    this.materialId,
    this.customerId,
  });

  @override
  List<Object?> get props => [screen, orderId, materialId, customerId];
}

class NavigationState extends Equatable {
  final List<ScreenEntry> stack;
  final String? toast;

  const NavigationState({required this.stack, this.toast});

  ScreenEntry get current => stack.last;

  bool get canGoBack => stack.length > 1;

  @override
  List<Object?> get props => [stack, toast];
}
