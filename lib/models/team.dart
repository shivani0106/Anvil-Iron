import 'package:equatable/equatable.dart';

class Teammate extends Equatable {
  final int id;
  final String name;
  final String contact;
  final String skills;
  final String notes;

  const Teammate({
    required this.id,
    required this.name,
    this.contact = '',
    this.skills = '',
    this.notes = '',
  });

  String get initials {
    final words = name.trim().split(' ');
    if (words.length >= 2) return '${words[0][0]}${words[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name.substring(0, name.length.clamp(0, 2)).toUpperCase() : 'TM';
  }

  factory Teammate.fromJson(Map<String, dynamic> json) => Teammate(
        id: json['id'] as int,
        name: (json['team_name'] as String?) ?? '',
        contact: (json['contact'] as String?) ?? '',
        skills: (json['skills'] as String?) ?? '',
        notes: (json['notes'] as String?) ?? '',
      );

  Map<String, dynamic> toInsertJson() => {
        'team_name': name,
        'contact': contact.isEmpty ? null : contact,
        'skills': skills.isEmpty ? null : skills,
        'notes': notes.isEmpty ? null : notes,
      };

  Map<String, dynamic> toUpdateJson() => toInsertJson();

  Teammate copyWith({
    String? name,
    String? contact,
    String? skills,
    String? notes,
  }) =>
      Teammate(
        id: id,
        name: name ?? this.name,
        contact: contact ?? this.contact,
        skills: skills ?? this.skills,
        notes: notes ?? this.notes,
      );

  @override
  List<Object?> get props => [id, name, contact, skills, notes];
}
