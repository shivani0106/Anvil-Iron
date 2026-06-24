import 'package:equatable/equatable.dart';

class JobMaterial extends Equatable {
  final int id;
  final int orderId;
  final String name;
  final String type;
  final String quality;
  final String createdAt;

  const JobMaterial({
    required this.id,
    required this.orderId,
    required this.name,
    this.type = '',
    this.quality = '',
    this.createdAt = '',
  });

  factory JobMaterial.fromJson(Map<String, dynamic> json) => JobMaterial(
        id: json['id'] as int,
        orderId: json['order_id'] as int,
        name: json['name'] as String,
        type: (json['type'] as String?) ?? '',
        quality: (json['quality'] as String?) ?? '',
        createdAt: (json['created_at'] as String?) ?? '',
      );

  Map<String, dynamic> toInsertJson(int orderId) => {
        'order_id': orderId,
        'name': name,
        'type': type.isEmpty ? null : type,
        'quality': quality.isEmpty ? null : quality,
      };

  JobMaterial copyWith({String? name, String? type, String? quality}) => JobMaterial(
        id: id,
        orderId: orderId,
        name: name ?? this.name,
        type: type ?? this.type,
        quality: quality ?? this.quality,
        createdAt: createdAt,
      );

  @override
  List<Object?> get props => [id, orderId, name, type, quality];
}
