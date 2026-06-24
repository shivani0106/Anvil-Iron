import 'package:equatable/equatable.dart';
import '../../models/job_material.dart';
import '../../models/job_team.dart';
import '../../models/customer.dart';
import '../../models/supplier.dart';
import '../../models/workflow_step.dart';

class JobDetailsState extends Equatable {
  final int orderId;
  final List<JobMaterial> materials;
  final List<JobTeam> teams;
  final List<WorkflowStep> workflowSteps;
  final Customer? linkedCustomer;
  final Supplier? linkedSupplier;
  final bool isLoading;
  final String? error;

  const JobDetailsState({
    required this.orderId,
    this.materials = const [],
    this.teams = const [],
    this.workflowSteps = const [],
    this.linkedCustomer,
    this.linkedSupplier,
    this.isLoading = false,
    this.error,
  });

  JobDetailsState copyWith({
    List<JobMaterial>? materials,
    List<JobTeam>? teams,
    List<WorkflowStep>? workflowSteps,
    Customer? linkedCustomer,
    bool clearLinkedCustomer = false,
    Supplier? linkedSupplier,
    bool clearLinkedSupplier = false,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return JobDetailsState(
      orderId: orderId,
      materials: materials ?? this.materials,
      teams: teams ?? this.teams,
      workflowSteps: workflowSteps ?? this.workflowSteps,
      linkedCustomer: clearLinkedCustomer ? null : (linkedCustomer ?? this.linkedCustomer),
      linkedSupplier: clearLinkedSupplier ? null : (linkedSupplier ?? this.linkedSupplier),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [orderId, materials, teams, workflowSteps, linkedCustomer, linkedSupplier, isLoading, error];
}
