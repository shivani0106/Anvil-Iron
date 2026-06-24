import 'package:equatable/equatable.dart';
import '../../models/machine.dart';

class MachinesState extends Equatable {
  final List<Machine> machines;
  final String searchQuery;
  final bool isLoading;
  final String? error;

  const MachinesState({
    this.machines = const [],
    this.searchQuery = '',
    this.isLoading = false,
    this.error,
  });

  List<Machine> get filtered {
    if (searchQuery.trim().isEmpty) return machines;
    final q = searchQuery.trim().toLowerCase();
    return machines.where((m) =>
        m.name.toLowerCase().contains(q) ||
        m.machineNumber.toLowerCase().contains(q) ||
        m.type.toLowerCase().contains(q) ||
        m.manufacturer.toLowerCase().contains(q)).toList();
  }

  MachinesState copyWith({
    List<Machine>? machines,
    String? searchQuery,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) =>
      MachinesState(
        machines: machines ?? this.machines,
        searchQuery: searchQuery ?? this.searchQuery,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
      );

  @override
  List<Object?> get props => [machines, searchQuery, isLoading, error];
}
