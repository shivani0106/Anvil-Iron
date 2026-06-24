import 'package:equatable/equatable.dart';
import '../../models/team.dart';

class TeamsMgmtState extends Equatable {
  final List<Team> teams;
  final String searchQuery;
  final bool isLoading;
  final String? error;

  const TeamsMgmtState({
    this.teams = const [],
    this.searchQuery = '',
    this.isLoading = false,
    this.error,
  });

  List<Team> get filtered {
    if (searchQuery.trim().isEmpty) return teams;
    final q = searchQuery.trim().toLowerCase();
    return teams.where((t) =>
        t.teamName.toLowerCase().contains(q) ||
        t.leader.toLowerCase().contains(q) ||
        t.skills.toLowerCase().contains(q)).toList();
  }

  TeamsMgmtState copyWith({
    List<Team>? teams,
    String? searchQuery,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) =>
      TeamsMgmtState(
        teams: teams ?? this.teams,
        searchQuery: searchQuery ?? this.searchQuery,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
      );

  @override
  List<Object?> get props => [teams, searchQuery, isLoading, error];
}
