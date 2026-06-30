import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/app_material.dart';
import '../../models/inventory_item.dart';
import '../../repositories/app_materials_repository.dart';
import '../inventory/inventory_cubit.dart';
import 'materials_state.dart';

class MaterialsCubit extends Cubit<MaterialsState> {
  final AppMaterialsRepository _repo;
  final InventoryCubit? _inventoryCubit;
  RealtimeChannel? _channel;

  MaterialsCubit({AppMaterialsRepository? repo, InventoryCubit? inventoryCubit})
      : _repo = repo ?? AppMaterialsRepository(),
        _inventoryCubit = inventoryCubit,
        super(const MaterialsState(isLoading: true)) {
    loadData();
  }

  Future<void> loadData() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final materials = await _repo.fetchAll();
      emit(state.copyWith(materials: materials, isLoading: false));
      _subscribeRealtime();
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Failed to load materials'));
    }
  }

  void _subscribeRealtime() {
    _channel?.unsubscribe();
    _channel = _repo.subscribeToChanges(() {
      loadData();
    });
  }

  void setSearch(String q) => emit(state.copyWith(searchQuery: q));

  Future<bool> create(AppMaterial material) async {
    try {
      final created = await _repo.create(material);
      emit(state.copyWith(materials: [...state.materials, created]));
      await _inventoryCubit?.addItem(InventoryItem(
        id: 0,
        name: created.name,
        category: created.type.isEmpty ? 'General' : created.type,
        qty: created.quantity,
        unit: created.unit.isEmpty ? 'pcs' : created.unit,
        reorder: 0,
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(error: 'Failed to save material'));
      return false;
    }
  }

  Future<bool> update(AppMaterial material) async {
    try {
      final updated = await _repo.update(material);
      final list = state.materials.map((m) => m.id == updated.id ? updated : m).toList();
      emit(state.copyWith(materials: list));
      return true;
    } catch (e) {
      emit(state.copyWith(error: 'Failed to update material'));
      return false;
    }
  }

  Future<bool> delete(int id) async {
    try {
      await _repo.delete(id);
      emit(state.copyWith(materials: state.materials.where((m) => m.id != id).toList()));
      return true;
    } catch (e) {
      emit(state.copyWith(error: 'Failed to delete material'));
      return false;
    }
  }

  @override
  Future<void> close() {
    _channel?.unsubscribe();
    return super.close();
  }
}
