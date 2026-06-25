import 'package:equatable/equatable.dart';
import '../../models/team.dart';

class TeamsMgmtState extends Equatable {
  final List<Teammate> teammates;
  final String searchQuery;
  final bool isLoading;
  final String? error;

  const TeamsMgmtState({
    this.teammates = const [],
    this.searchQuery = '',
    this.isLoading = false,
    this.error,
  });

  List<Teammate> get filtered {
    if (searchQuery.trim().isEmpty) return teammates;
    final q = searchQuery.trim().toLowerCase();
    return teammates
        .where((t) =>
            t.name.toLowerCase().contains(q) ||
            t.skills.toLowerCase().contains(q) ||
            t.contact.toLowerCase().contains(q))
        .toList();
  }

  TeamsMgmtState copyWith({
    List<Teammate>? teammates,
    String? searchQuery,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) =>
      TeamsMgmtState(
        teammates: teammates ?? this.teammates,
        searchQuery: searchQuery ?? this.searchQuery,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
      );

  @override
  List<Object?> get props => [teammates, searchQuery, isLoading, error];
}
