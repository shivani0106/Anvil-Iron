import 'package:equatable/equatable.dart';

class TeamMember extends Equatable {
  final String name;
  final String initials;
  final String role;
  final String task;

  const TeamMember({
    required this.name,
    required this.initials,
    required this.role,
    required this.task,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) => TeamMember(
        name: json['name'] as String,
        initials: (json['initials'] as String?) ?? '',
        role: (json['role'] as String?) ?? '',
        task: (json['task'] as String?) ?? '',
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'initials': initials,
        'role': role,
        'task': task,
      };

  @override
  List<Object?> get props => [name, initials, role, task];
}
