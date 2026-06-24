import 'package:equatable/equatable.dart';

enum MachineStatus { running, idle, maintenance }

extension MachineStatusX on MachineStatus {
  String get label {
    switch (this) {
      case MachineStatus.running:     return 'Running';
      case MachineStatus.idle:        return 'Idle';
      case MachineStatus.maintenance: return 'Maintenance';
    }
  }

  static MachineStatus fromValue(String? v) {
    return MachineStatus.values.firstWhere(
      (s) => s.name == v,
      orElse: () => MachineStatus.idle,
    );
  }
}

class Machine extends Equatable {
  final int id;
  final String name;
  final MachineStatus status;
  final double utilization;
  final String note;
  // Extended fields
  final String machineNumber;
  final String type;
  final String manufacturer;
  final String modelNumber;
  final String capacity;
  final String purchaseDate;

  const Machine({
    required this.id,
    required this.name,
    required this.status,
    required this.utilization,
    this.note = '',
    this.machineNumber = '',
    this.type = '',
    this.manufacturer = '',
    this.modelNumber = '',
    this.capacity = '',
    this.purchaseDate = '',
  });

  String get statusLabel => status.label;

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name.substring(0, name.length.clamp(0, 2)).toUpperCase() : 'MC';
  }

  factory Machine.fromJson(Map<String, dynamic> json) => Machine(
        id: json['id'] as int,
        name: json['name'] as String,
        status: MachineStatusX.fromValue(json['status'] as String?),
        utilization: (json['utilization'] as num? ?? 0).toDouble(),
        note: (json['note'] as String?) ?? '',
        machineNumber: (json['machine_number'] as String?) ?? '',
        type: (json['type'] as String?) ?? '',
        manufacturer: (json['manufacturer'] as String?) ?? '',
        modelNumber: (json['model_number'] as String?) ?? '',
        capacity: (json['capacity'] as String?) ?? '',
        purchaseDate: (json['purchase_date'] as String?) ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'status': status.name,
        'utilization': utilization.round(),
        'note': note.isEmpty ? null : note,
        'machine_number': machineNumber.isEmpty ? null : machineNumber,
        'type': type.isEmpty ? null : type,
        'manufacturer': manufacturer.isEmpty ? null : manufacturer,
        'model_number': modelNumber.isEmpty ? null : modelNumber,
        'capacity': capacity.isEmpty ? null : capacity,
        'purchase_date': purchaseDate.isEmpty ? null : purchaseDate,
      };

  Map<String, dynamic> toUpdateJson() => {
        'name': name,
        'status': status.name,
        'utilization': utilization.round(),
        'note': note.isEmpty ? null : note,
        'machine_number': machineNumber.isEmpty ? null : machineNumber,
        'type': type.isEmpty ? null : type,
        'manufacturer': manufacturer.isEmpty ? null : manufacturer,
        'model_number': modelNumber.isEmpty ? null : modelNumber,
        'capacity': capacity.isEmpty ? null : capacity,
        'purchase_date': purchaseDate.isEmpty ? null : purchaseDate,
      };

  Machine copyWith({
    String? name,
    MachineStatus? status,
    double? utilization,
    String? note,
    String? machineNumber,
    String? type,
    String? manufacturer,
    String? modelNumber,
    String? capacity,
    String? purchaseDate,
  }) =>
      Machine(
        id: id,
        name: name ?? this.name,
        status: status ?? this.status,
        utilization: utilization ?? this.utilization,
        note: note ?? this.note,
        machineNumber: machineNumber ?? this.machineNumber,
        type: type ?? this.type,
        manufacturer: manufacturer ?? this.manufacturer,
        modelNumber: modelNumber ?? this.modelNumber,
        capacity: capacity ?? this.capacity,
        purchaseDate: purchaseDate ?? this.purchaseDate,
      );

  @override
  List<Object?> get props => [id, name, status, utilization, note, machineNumber, type, manufacturer, modelNumber, capacity, purchaseDate];
}
