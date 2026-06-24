import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/supplier.dart';
import '../../repositories/suppliers_repository.dart';
import 'suppliers_state.dart';

class SuppliersCubit extends Cubit<SuppliersState> {
  final SuppliersRepository _repo;

  SuppliersCubit({SuppliersRepository? repo})
      : _repo = repo ?? SuppliersRepository(),
        super(const SuppliersState(isLoading: true)) {
    loadData();
  }

  Future<void> loadData() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final suppliers = await _repo.fetchAll();
      emit(state.copyWith(suppliers: suppliers, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Failed to load suppliers'));
    }
  }

  void setSearch(String q) => emit(state.copyWith(searchQuery: q));

  Future<Supplier?> create(Supplier supplier) async {
    try {
      final created = await _repo.create(supplier);
      emit(state.copyWith(suppliers: [...state.suppliers, created]));
      return created;
    } catch (e) {
      emit(state.copyWith(error: 'Failed to save supplier'));
      return null;
    }
  }

  Future<bool> update(Supplier supplier) async {
    try {
      final updated = await _repo.update(supplier);
      final list = state.suppliers.map((s) => s.id == updated.id ? updated : s).toList();
      emit(state.copyWith(suppliers: list));
      return true;
    } catch (e) {
      emit(state.copyWith(error: 'Failed to update supplier'));
      return false;
    }
  }

  Future<bool> delete(int id) async {
    try {
      await _repo.delete(id);
      emit(state.copyWith(suppliers: state.suppliers.where((s) => s.id != id).toList()));
      return true;
    } catch (e) {
      emit(state.copyWith(error: 'Failed to delete supplier'));
      return false;
    }
  }

  Supplier? getById(int id) {
    try {
      return state.suppliers.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}
