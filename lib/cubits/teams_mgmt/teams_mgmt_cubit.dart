import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/team.dart';
import '../../repositories/teams_repository.dart';
import 'teams_mgmt_state.dart';

class TeamsMgmtCubit extends Cubit<TeamsMgmtState> {
  final TeamsRepository _repo;
  RealtimeChannel? _channel;

  TeamsMgmtCubit({TeamsRepository? repo})
      : _repo = repo ?? TeamsRepository(),
        super(const TeamsMgmtState(isLoading: true)) {
    loadData();
  }

  Future<void> loadData() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final teams = await _repo.fetchAll();
      emit(state.copyWith(teams: teams, isLoading: false));
      _subscribeRealtime();
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Failed to load teams'));
    }
  }

  void _subscribeRealtime() {
    _channel?.unsubscribe();
    _channel = _repo.subscribeToChanges(() {
      loadData();
    });
  }

  void setSearch(String q) => emit(state.copyWith(searchQuery: q));

  Future<bool> create(Team team) async {
    try {
      final created = await _repo.create(team);
      emit(state.copyWith(teams: [...state.teams, created]));
      return true;
    } catch (e) {
      emit(state.copyWith(error: 'Failed to save team'));
      return false;
    }
  }

  Future<bool> update(Team team) async {
    try {
      final updated = await _repo.update(team);
      final list = state.teams.map((t) => t.id == updated.id ? updated : t).toList();
      emit(state.copyWith(teams: list));
      return true;
    } catch (e) {
      emit(state.copyWith(error: 'Failed to update team'));
      return false;
    }
  }

  Future<bool> delete(int id) async {
    try {
      await _repo.delete(id);
      emit(state.copyWith(teams: state.teams.where((t) => t.id != id).toList()));
      return true;
    } catch (e) {
      emit(state.copyWith(error: 'Failed to delete team'));
      return false;
    }
  }

  @override
  Future<void> close() {
    _channel?.unsubscribe();
    return super.close();
  }
}
