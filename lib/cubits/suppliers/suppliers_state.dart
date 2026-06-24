import 'package:equatable/equatable.dart';
import '../../models/supplier.dart';

class SuppliersState extends Equatable {
  final List<Supplier> suppliers;
  final String searchQuery;
  final bool isLoading;
  final String? error;

  const SuppliersState({
    this.suppliers = const [],
    this.searchQuery = '',
    this.isLoading = false,
    this.error,
  });

  List<Supplier> get filtered {
    if (searchQuery.trim().isEmpty) return suppliers;
    final q = searchQuery.trim().toLowerCase();
    return suppliers.where((s) =>
      '${s.name} ${s.materials} ${s.location}'.toLowerCase().contains(q)).toList();
  }

  SuppliersState copyWith({
    List<Supplier>? suppliers,
    String? searchQuery,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) =>
      SuppliersState(
        suppliers: suppliers ?? this.suppliers,
        searchQuery: searchQuery ?? this.searchQuery,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
      );

  @override
  List<Object?> get props => [suppliers, searchQuery, isLoading, error];
}
