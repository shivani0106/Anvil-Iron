import 'package:equatable/equatable.dart';

class Supplier extends Equatable {
  final int id;
  final String name;
  final String materials;
  final String phone;
  final String location;
  final String contactPerson;
  final String mobile;
  final String email;
  final String address;
  final String notes;

  const Supplier({
    required this.id,
    required this.name,
    this.materials = '',
    this.phone = '',
    this.location = '',
    this.contactPerson = '',
    this.mobile = '',
    this.email = '',
    this.address = '',
    this.notes = '',
  });

  String get primaryPhone => mobile.isNotEmpty ? mobile : phone;

  factory Supplier.fromJson(Map<String, dynamic> json) => Supplier(
        id: json['id'] as int,
        name: json['name'] as String,
        materials: (json['materials'] as String?) ?? '',
        phone: (json['phone'] as String?) ?? '',
        location: (json['location'] as String?) ?? '',
        contactPerson: (json['contact_person'] as String?) ?? '',
        mobile: (json['mobile'] as String?) ?? '',
        email: (json['email'] as String?) ?? '',
        address: (json['address'] as String?) ?? '',
        notes: (json['notes'] as String?) ?? '',
      );

  Map<String, dynamic> toInsertJson() => {
        'name': name,
        'materials': materials.isEmpty ? null : materials,
        'phone': phone.isEmpty ? null : phone,
        'location': location.isEmpty ? null : location,
        'contact_person': contactPerson.isEmpty ? null : contactPerson,
        'mobile': mobile.isEmpty ? null : mobile,
        'email': email.isEmpty ? null : email,
        'address': address.isEmpty ? null : address,
        'notes': notes.isEmpty ? null : notes,
      };

  Map<String, dynamic> toUpdateJson() => toInsertJson();

  Supplier copyWith({
    String? name,
    String? materials,
    String? phone,
    String? location,
    String? contactPerson,
    String? mobile,
    String? email,
    String? address,
    String? notes,
  }) =>
      Supplier(
        id: id,
        name: name ?? this.name,
        materials: materials ?? this.materials,
        phone: phone ?? this.phone,
        location: location ?? this.location,
        contactPerson: contactPerson ?? this.contactPerson,
        mobile: mobile ?? this.mobile,
        email: email ?? this.email,
        address: address ?? this.address,
        notes: notes ?? this.notes,
      );

  @override
  List<Object?> get props => [id, name, materials, phone, location, contactPerson, mobile, email, address, notes];
}
