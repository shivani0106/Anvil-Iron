import 'package:equatable/equatable.dart';

class Team extends Equatable {
  final int id;
  final String teamName;
  final String leader;
  final String contact;
  final String email;
  final int membersCount;
  final String skills;
  final String notes;

  const Team({
    required this.id,
    required this.teamName,
    this.leader = '',
    this.contact = '',
    this.email = '',
    this.membersCount = 1,
    this.skills = '',
    this.notes = '',
  });

  String get initials {
    final words = teamName.trim().split(' ');
    if (words.length >= 2) return '${words[0][0]}${words[1][0]}'.toUpperCase();
    return teamName.isNotEmpty ? teamName.substring(0, teamName.length.clamp(0, 2)).toUpperCase() : 'TM';
  }

  factory Team.fromJson(Map<String, dynamic> json) => Team(
        id: json['id'] as int,
        teamName: json['team_name'] as String,
        leader: (json['leader'] as String?) ?? '',
        contact: (json['contact'] as String?) ?? '',
        email: (json['email'] as String?) ?? '',
        membersCount: (json['members_count'] as int?) ?? 1,
        skills: (json['skills'] as String?) ?? '',
        notes: (json['notes'] as String?) ?? '',
      );

  Map<String, dynamic> toInsertJson() => {
        'team_name': teamName,
        'leader': leader.isEmpty ? null : leader,
        'contact': contact.isEmpty ? null : contact,
        'email': email.isEmpty ? null : email,
        'members_count': membersCount,
        'skills': skills.isEmpty ? null : skills,
        'notes': notes.isEmpty ? null : notes,
      };

  Map<String, dynamic> toUpdateJson() => toInsertJson();

  Team copyWith({
    String? teamName,
    String? leader,
    String? contact,
    String? email,
    int? membersCount,
    String? skills,
    String? notes,
  }) =>
      Team(
        id: id,
        teamName: teamName ?? this.teamName,
        leader: leader ?? this.leader,
        contact: contact ?? this.contact,
        email: email ?? this.email,
        membersCount: membersCount ?? this.membersCount,
        skills: skills ?? this.skills,
        notes: notes ?? this.notes,
      );

  @override
  List<Object?> get props => [id, teamName, leader, contact, email, membersCount, skills, notes];
}
