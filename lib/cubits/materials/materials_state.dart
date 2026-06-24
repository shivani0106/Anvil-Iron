import 'package:equatable/equatable.dart';
import '../../models/app_material.dart';

class MaterialsState extends Equatable {
  final List<AppMaterial> materials;
  final String searchQuery;
  final bool isLoading;
  final String? error;

  const MaterialsState({
    this.materials = const [],
    this.searchQuery = '',
    this.isLoading = false,
    this.error,
  });

  List<AppMaterial> get filtered {
    if (searchQuery.trim().isEmpty) return materials;
    final q = searchQuery.trim().toLowerCase();
    return materials.where((m) =>
        m.name.toLowerCase().contains(q) ||
        m.type.toLowerCase().contains(q) ||
        m.supplierName.toLowerCase().contains(q)).toList();
  }

  MaterialsState copyWith({
    List<AppMaterial>? materials,
    String? searchQuery,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) =>
      MaterialsState(
        materials: materials ?? this.materials,
        searchQuery: searchQuery ?? this.searchQuery,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
      );

  @override
  List<Object?> get props => [materials, searchQuery, isLoading, error];
}
