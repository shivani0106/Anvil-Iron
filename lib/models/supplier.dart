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

  @override
  List<Object?> get props => [id, name, materials, phone, location];
}
