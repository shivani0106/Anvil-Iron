import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/customer.dart';
import '../../repositories/customers_repository.dart';
import 'customers_state.dart';

class CustomersCubit extends Cubit<CustomersState> {
  final CustomersRepository _repo;

  CustomersCubit({CustomersRepository? repo})
      : _repo = repo ?? CustomersRepository(),
        super(const CustomersState(isLoading: true)) {
    loadData();
  }

  Future<void> loadData() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final customers = await _repo.fetchAll();
      emit(state.copyWith(customers: customers, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Failed to load customers'));
    }
  }

  void setSearch(String q) => emit(state.copyWith(searchQuery: q));

  Future<Customer?> create(Customer customer) async {
    try {
      final created = await _repo.create(customer);
      emit(state.copyWith(customers: [...state.customers, created]));
      return created;
    } catch (e) {
      emit(state.copyWith(error: 'Failed to save customer'));
      return null;
    }
  }

  Future<bool> update(Customer customer) async {
    try {
      final updated = await _repo.update(customer);
      final list = state.customers.map((c) => c.id == updated.id ? updated : c).toList();
      emit(state.copyWith(customers: list));
      return true;
    } catch (e) {
      emit(state.copyWith(error: 'Failed to update customer'));
      return false;
    }
  }

  Future<bool> delete(int id) async {
    try {
      await _repo.delete(id);
      emit(state.copyWith(customers: state.customers.where((c) => c.id != id).toList()));
      return true;
    } catch (e) {
      emit(state.copyWith(error: 'Failed to delete customer'));
      return false;
    }
  }

  Customer? getById(int id) {
    try {
      return state.customers.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
