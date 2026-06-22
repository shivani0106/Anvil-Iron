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

  @override
  List<Object?> get props => [name, initials, role, task];
}
