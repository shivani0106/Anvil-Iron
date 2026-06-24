import 'package:equatable/equatable.dart';
import '../../models/customer.dart';

class CustomersState extends Equatable {
  final List<Customer> customers;
  final String searchQuery;
  final bool isLoading;
  final String? error;

  const CustomersState({
    this.customers = const [],
    this.searchQuery = '',
    this.isLoading = false,
    this.error,
  });

  List<Customer> get filtered {
    if (searchQuery.trim().isEmpty) return customers;
    final q = searchQuery.trim().toLowerCase();
    return customers.where((c) =>
      '${c.name} ${c.mobile} ${c.email}'.toLowerCase().contains(q)).toList();
  }

  CustomersState copyWith({
    List<Customer>? customers,
    String? searchQuery,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) =>
      CustomersState(
        customers: customers ?? this.customers,
        searchQuery: searchQuery ?? this.searchQuery,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
      );

  @override
  List<Object?> get props => [customers, searchQuery, isLoading, error];
}
