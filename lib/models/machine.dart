import 'package:equatable/equatable.dart';

enum MachineStatus { running, idle, maintenance }

class Machine extends Equatable {
  final int id;
  final String name;
  final MachineStatus status;
  final double utilization;
  final String note;

  const Machine({
    required this.id,
    required this.name,
    required this.status,
    required this.utilization,
    required this.note,
  });

  String get statusLabel {
    switch (status) {
      case MachineStatus.running:
        return 'Running';
      case MachineStatus.idle:
        return 'Idle';
      case MachineStatus.maintenance:
        return 'Maintenance';
    }
  }

  @override
  List<Object?> get props => [id, name, status, utilization, note];
}
