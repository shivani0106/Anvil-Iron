import 'package:equatable/equatable.dart';

class WorkflowStep extends Equatable {
  final int id;
  final int orderId;
  final String name;
  final int position;

  const WorkflowStep({
    required this.id,
    required this.orderId,
    required this.name,
    required this.position,
  });

  factory WorkflowStep.fromJson(Map<String, dynamic> json) => WorkflowStep(
        id: json['id'] as int,
        orderId: json['order_id'] as int,
        name: json['name'] as String,
        position: json['position'] as int,
      );

  Map<String, dynamic> toJson() => {
        'order_id': orderId,
        'name': name,
        'position': position,
      };

  WorkflowStep copyWith({int? id, int? orderId, String? name, int? position}) =>
      WorkflowStep(
        id: id ?? this.id,
        orderId: orderId ?? this.orderId,
        name: name ?? this.name,
        position: position ?? this.position,
      );

  @override
  List<Object?> get props => [id, orderId, name, position];
}
