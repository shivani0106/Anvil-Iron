import 'package:equatable/equatable.dart';
import '../../models/drawing.dart';

class DrawingsState extends Equatable {
  final List<Drawing> drawings;
  final bool isLoading;
  final bool isUploading;
  final String error;
  final String searchQuery;

  const DrawingsState({
    required this.drawings,
    this.isLoading = false,
    this.isUploading = false,
    this.error = '',
    this.searchQuery = '',
  });

  List<Drawing> get filteredDrawings {
    if (searchQuery.isEmpty) return drawings;
    final q = searchQuery.toLowerCase();
    return drawings
        .where((d) =>
            d.fileName.toLowerCase().contains(q) ||
            d.customer.toLowerCase().contains(q))
        .toList();
  }

  DrawingsState copyWith({
    List<Drawing>? drawings,
    bool? isLoading,
    bool? isUploading,
    String? error,
    String? searchQuery,
  }) =>
      DrawingsState(
        drawings: drawings ?? this.drawings,
        isLoading: isLoading ?? this.isLoading,
        isUploading: isUploading ?? this.isUploading,
        error: error ?? this.error,
        searchQuery: searchQuery ?? this.searchQuery,
      );

  @override
  List<Object?> get props =>
      [drawings, isLoading, isUploading, error, searchQuery];
}
