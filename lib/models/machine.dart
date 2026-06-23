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

  factory Machine.fromJson(Map<String, dynamic> json) => Machine(
        id: json['id'] as int,
        name: json['name'] as String,
        status: MachineStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => MachineStatus.idle,
        ),
        utilization: (json['utilization'] as num).toDouble(),
        note: (json['note'] as String?) ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'status': status.name,
        'utilization': utilization.round(),
        'note': note,
      };

  @override
  List<Object?> get props => [id, name, status, utilization, note];
}
