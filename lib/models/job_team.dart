import 'package:equatable/equatable.dart';

class JobTeam extends Equatable {
  final int id;
  final int orderId;
  final String teamName;
  final String leader;
  final String contact;
  final int membersCount;
  final String notes;
  final String createdAt;

  const JobTeam({
    required this.id,
    required this.orderId,
    required this.teamName,
    this.leader = '',
    this.contact = '',
    this.membersCount = 1,
    this.notes = '',
    this.createdAt = '',
  });

  factory JobTeam.fromJson(Map<String, dynamic> json) => JobTeam(
        id: json['id'] as int,
        orderId: json['order_id'] as int,
        teamName: json['team_name'] as String,
        leader: (json['leader'] as String?) ?? '',
        contact: (json['contact'] as String?) ?? '',
        membersCount: (json['members_count'] as int?) ?? 1,
        notes: (json['notes'] as String?) ?? '',
        createdAt: (json['created_at'] as String?) ?? '',
      );

  Map<String, dynamic> toInsertJson(int orderId) => {
        'order_id': orderId,
        'team_name': teamName,
        'leader': leader.isEmpty ? null : leader,
        'contact': contact.isEmpty ? null : contact,
        'members_count': membersCount,
        'notes': notes.isEmpty ? null : notes,
      };

  JobTeam copyWith({
    String? teamName,
    String? leader,
    String? contact,
    int? membersCount,
    String? notes,
  }) =>
      JobTeam(
        id: id,
        orderId: orderId,
        teamName: teamName ?? this.teamName,
        leader: leader ?? this.leader,
        contact: contact ?? this.contact,
        membersCount: membersCount ?? this.membersCount,
        notes: notes ?? this.notes,
        createdAt: createdAt,
      );

  @override
  List<Object?> get props => [id, orderId, teamName, leader, contact, membersCount, notes];
}
