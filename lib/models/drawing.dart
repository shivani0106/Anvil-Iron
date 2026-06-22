import 'package:equatable/equatable.dart';

class Drawing extends Equatable {
  final String name;
  final String customer;
  final String size;
  final String rev;

  const Drawing({
    required this.name,
    required this.customer,
    required this.size,
    required this.rev,
  });

  String get extension => name.contains('.') ? name.split('.').last.toUpperCase() : 'FILE';

  @override
  List<Object?> get props => [name, customer, size, rev];
}
