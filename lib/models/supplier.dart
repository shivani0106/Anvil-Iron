import 'package:equatable/equatable.dart';

class Supplier extends Equatable {
  final int id;
  final String name;
  final String materials;
  final String phone;
  final String location;

  const Supplier({
    required this.id,
    required this.name,
    required this.materials,
    required this.phone,
    required this.location,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) => Supplier(
        id: json['id'] as int,
        name: json['name'] as String,
        materials: (json['materials'] as String?) ?? '',
        phone: (json['phone'] as String?) ?? '',
        location: (json['location'] as String?) ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'materials': materials,
        'phone': phone,
        'location': location,
      };

  @override
  List<Object?> get props => [id, name, materials, phone, location];
}
