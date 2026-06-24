import 'package:equatable/equatable.dart';

class Customer extends Equatable {
  final int id;
  final String name;
  final String mobile;
  final String altNumber;
  final String email;
  final String address;
  final String notes;

  const Customer({
    required this.id,
    required this.name,
    required this.mobile,
    this.altNumber = '',
    this.email = '',
    this.address = '',
    this.notes = '',
  });

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json['id'] as int,
        name: json['name'] as String,
        mobile: json['mobile'] as String,
        altNumber: (json['alt_number'] as String?) ?? '',
        email: (json['email'] as String?) ?? '',
        address: (json['address'] as String?) ?? '',
        notes: (json['notes'] as String?) ?? '',
      );

  Map<String, dynamic> toInsertJson() => {
        'name': name,
        'mobile': mobile,
        'alt_number': altNumber.isEmpty ? null : altNumber,
        'email': email.isEmpty ? null : email,
        'address': address.isEmpty ? null : address,
        'notes': notes.isEmpty ? null : notes,
      };

  Map<String, dynamic> toUpdateJson() => {
        'name': name,
        'mobile': mobile,
        'alt_number': altNumber.isEmpty ? null : altNumber,
        'email': email.isEmpty ? null : email,
        'address': address.isEmpty ? null : address,
        'notes': notes.isEmpty ? null : notes,
      };

  Customer copyWith({
    String? name,
    String? mobile,
    String? altNumber,
    String? email,
    String? address,
    String? notes,
  }) =>
      Customer(
        id: id,
        name: name ?? this.name,
        mobile: mobile ?? this.mobile,
        altNumber: altNumber ?? this.altNumber,
        email: email ?? this.email,
        address: address ?? this.address,
        notes: notes ?? this.notes,
      );

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  List<Object?> get props => [id, name, mobile, altNumber, email, address, notes];
}
