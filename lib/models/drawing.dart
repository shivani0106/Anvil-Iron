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

  factory Drawing.fromJson(Map<String, dynamic> json) => Drawing(
        name: json['name'] as String,
        customer: json['customer'] as String,
        size: (json['size'] as String?) ?? '',
        rev: (json['rev'] as String?) ?? '',
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'customer': customer,
        'size': size,
        'rev': rev,
      };

  @override
  List<Object?> get props => [name, customer, size, rev];
}
