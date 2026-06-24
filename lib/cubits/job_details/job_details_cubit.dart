import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/job_material.dart';
import '../../models/job_team.dart';
import '../../models/workflow_step.dart';
import '../../repositories/job_materials_repository.dart';
import '../../repositories/job_teams_repository.dart';
import '../../repositories/workflow_steps_repository.dart';
import '../../repositories/customers_repository.dart';
import '../../repositories/suppliers_repository.dart';
import '../../repositories/orders_repository.dart';
import 'job_details_state.dart';

class JobDetailsCubit extends Cubit<JobDetailsState> {
  final int orderId;
  final JobMaterialsRepository _materialsRepo;
  final JobTeamsRepository _teamsRepo;
  final WorkflowStepsRepository _workflowRepo;
  final CustomersRepository _customersRepo;
  final SuppliersRepository _suppliersRepo;
  final OrdersRepository _ordersRepo;

  JobDetailsCubit({
    required this.orderId,
    JobMaterialsRepository? materialsRepo,
    JobTeamsRepository? teamsRepo,
    WorkflowStepsRepository? workflowRepo,
    CustomersRepository? customersRepo,
    SuppliersRepository? suppliersRepo,
    OrdersRepository? ordersRepo,
  })  : _materialsRepo = materialsRepo ?? JobMaterialsRepository(),
        _teamsRepo = teamsRepo ?? JobTeamsRepository(),
        _workflowRepo = workflowRepo ?? WorkflowStepsRepository(),
        _customersRepo = customersRepo ?? CustomersRepository(),
        _suppliersRepo = suppliersRepo ?? SuppliersRepository(),
        _ordersRepo = ordersRepo ?? OrdersRepository(),
        super(JobDetailsState(orderId: orderId));

  Future<void> load({int? customerId, int? supplierId}) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final results = await Future.wait([
        _materialsRepo.fetchForOrder(orderId),
        _teamsRepo.fetchForOrder(orderId),
        _workflowRepo.fetchForOrder(orderId),
      ]);

      final materials = results[0] as List<JobMaterial>;
      final teams = results[1] as List<JobTeam>;
      final workflowSteps = results[2] as List<WorkflowStep>;

      final linkedCustomer = customerId != null ? await _customersRepo.fetchById(customerId) : null;
      final linkedSupplier = supplierId != null ? await _suppliersRepo.fetchById(supplierId) : null;

      emit(state.copyWith(
        materials: materials,
        teams: teams,
        workflowSteps: workflowSteps,
        linkedCustomer: linkedCustomer,
        linkedSupplier: linkedSupplier,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Failed to load job details'));
    }
  }

  // ── Materials ────────────────────────────────────────────────

  Future<void> addMaterial(JobMaterial material) async {
    final created = await _materialsRepo.create(material, orderId);
    emit(state.copyWith(materials: [...state.materials, created]));
  }

  Future<void> updateMaterial(JobMaterial material) async {
    await _materialsRepo.update(material.id, material);
    final updated = state.materials.map((m) => m.id == material.id ? material : m).toList();
    emit(state.copyWith(materials: updated));
  }

  Future<void> deleteMaterial(int id) async {
    await _materialsRepo.delete(id);
    emit(state.copyWith(materials: state.materials.where((m) => m.id != id).toList()));
  }

  // ── Teams ────────────────────────────────────────────────────

  Future<void> addTeam(JobTeam team) async {
    final created = await _teamsRepo.create(team, orderId);
    emit(state.copyWith(teams: [...state.teams, created]));
  }

  Future<void> updateTeam(JobTeam team) async {
    await _teamsRepo.update(team.id, team);
    final updated = state.teams.map((t) => t.id == team.id ? team : t).toList();
    emit(state.copyWith(teams: updated));
  }

  Future<void> deleteTeam(int id) async {
    await _teamsRepo.delete(id);
    emit(state.copyWith(teams: state.teams.where((t) => t.id != id).toList()));
  }

  // ── Workflow steps ───────────────────────────────────────────

  Future<void> addWorkflowStep(String name) async {
    final nextPosition = state.workflowSteps.length;
    final created = await _workflowRepo.create(name, orderId, nextPosition);
    emit(state.copyWith(workflowSteps: [...state.workflowSteps, created]));
  }

  Future<void> deleteWorkflowStep(int id) async {
    await _workflowRepo.delete(id);
    final remaining = state.workflowSteps.where((s) => s.id != id).toList();
    // Renumber positions after deletion
    final renumbered = [
      for (var i = 0; i < remaining.length; i++)
        remaining[i].copyWith(position: i),
    ];
    emit(state.copyWith(workflowSteps: renumbered));
    if (renumbered.isNotEmpty) {
      await _workflowRepo.updatePositions(renumbered);
    }
  }

  Future<void> moveWorkflowStepUp(int index) async {
    if (index <= 0) return;
    final steps = List<WorkflowStep>.from(state.workflowSteps);
    final tmp = steps[index];
    steps[index] = steps[index - 1].copyWith(position: index);
    steps[index - 1] = tmp.copyWith(position: index - 1);
    emit(state.copyWith(workflowSteps: steps));
    await _workflowRepo.updatePositions([steps[index], steps[index - 1]]);
  }

  Future<void> moveWorkflowStepDown(int index) async {
    if (index >= state.workflowSteps.length - 1) return;
    final steps = List<WorkflowStep>.from(state.workflowSteps);
    final tmp = steps[index];
    steps[index] = steps[index + 1].copyWith(position: index);
    steps[index + 1] = tmp.copyWith(position: index + 1);
    emit(state.copyWith(workflowSteps: steps));
    await _workflowRepo.updatePositions([steps[index], steps[index + 1]]);
  }

  // ── Linked customer/supplier ─────────────────────────────────

  Future<void> linkCustomer(int? customerId) async {
    await _ordersRepo.linkCustomer(orderId, customerId);
    if (customerId == null) {
      emit(state.copyWith(clearLinkedCustomer: true));
    } else {
      final c = await _customersRepo.fetchById(customerId);
      emit(state.copyWith(linkedCustomer: c));
    }
  }

  Future<void> linkSupplier(int? supplierId) async {
    await _ordersRepo.linkSupplier(orderId, supplierId);
    if (supplierId == null) {
      emit(state.copyWith(clearLinkedSupplier: true));
    } else {
      final s = await _suppliersRepo.fetchById(supplierId);
      emit(state.copyWith(linkedSupplier: s));
    }
  }
}
