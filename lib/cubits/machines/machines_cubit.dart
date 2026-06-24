import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/machine.dart';
import '../../repositories/machines_repository.dart';
import 'machines_state.dart';

class MachinesCubit extends Cubit<MachinesState> {
  final MachinesRepository _repo;
  RealtimeChannel? _channel;

  MachinesCubit({MachinesRepository? repo})
      : _repo = repo ?? MachinesRepository(),
        super(const MachinesState(isLoading: true)) {
    loadData();
  }

  Future<void> loadData() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final machines = await _repo.fetchAll();
      emit(state.copyWith(machines: machines, isLoading: false));
      _subscribeRealtime();
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Failed to load machines'));
    }
  }

  void _subscribeRealtime() {
    _channel?.unsubscribe();
    _channel = _repo.subscribeToChanges(() {
      loadData();
    });
  }

  void setSearch(String q) => emit(state.copyWith(searchQuery: q));

  Future<bool> create(Machine machine) async {
    try {
      final allMachines = await _repo.fetchAll();
      final nextId = allMachines.isEmpty
          ? 1
          : allMachines.map((m) => m.id).reduce((a, b) => a > b ? a : b) + 1;
      final withId = Machine(
        id: nextId,
        name: machine.name,
        status: machine.status,
        utilization: machine.utilization,
        note: machine.note,
        machineNumber: machine.machineNumber,
        type: machine.type,
        manufacturer: machine.manufacturer,
        modelNumber: machine.modelNumber,
        capacity: machine.capacity,
        purchaseDate: machine.purchaseDate,
      );
      final created = await _repo.create(withId);
      emit(state.copyWith(machines: [...state.machines, created]));
      return true;
    } catch (e) {
      emit(state.copyWith(error: 'Failed to save machine'));
      return false;
    }
  }

  Future<bool> update(Machine machine) async {
    try {
      final updated = await _repo.update(machine);
      final list = state.machines.map((m) => m.id == updated.id ? updated : m).toList();
      emit(state.copyWith(machines: list));
      return true;
    } catch (e) {
      emit(state.copyWith(error: 'Failed to update machine'));
      return false;
    }
  }

  Future<bool> delete(int id) async {
    try {
      await _repo.delete(id);
      emit(state.copyWith(machines: state.machines.where((m) => m.id != id).toList()));
      return true;
    } catch (e) {
      emit(state.copyWith(error: 'Failed to delete machine'));
      return false;
    }
  }

  @override
  Future<void> close() {
    _channel?.unsubscribe();
    return super.close();
  }
}
