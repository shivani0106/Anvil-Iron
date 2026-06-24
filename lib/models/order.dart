import 'package:equatable/equatable.dart';

enum OrderStage { queued, cutting, welding, qc, ready }

enum WorkType { inHouse, external }

extension WorkTypeX on WorkType {
  String get label => this == WorkType.inHouse ? 'In House Work' : 'External Work';
  String get value => this == WorkType.inHouse ? 'in_house' : 'external';

  static WorkType fromValue(String? v) =>
      v == 'external' ? WorkType.external : WorkType.inHouse;
}

class Order extends Equatable {
  final int id;
  final String customer;
  final String item;
  final String spec;
  final int qty;
  final String material;
  final String due;
  final String ordered;
  final OrderStage stage;
  final bool delivered;
  final String? drawing;
  final WorkType workType;
  final int? customerId;
  final int? supplierId;

  const Order({
    required this.id,
    required this.customer,
    required this.item,
    required this.spec,
    required this.qty,
    required this.material,
    required this.due,
    required this.ordered,
    required this.stage,
    this.delivered = false,
    this.drawing,
    this.workType = WorkType.inHouse,
    this.customerId,
    this.supplierId,
  });

  static const List<String> stageLabels = ['Queued', 'Cutting', 'Welding', 'QC', 'Ready'];

  String get stageLabel => delivered ? 'Delivered' : stageLabels[stage.index];

  int get stageProgress => delivered ? 100 : ((stage.index / (OrderStage.values.length - 1)) * 100).round();

  String get titleText => '#$id · $item';

  bool get isActive => !delivered;

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'] as int,
        customer: json['customer'] as String,
        item: json['item'] as String,
        spec: (json['spec'] as String?) ?? '',
        qty: json['qty'] as int,
        material: (json['material'] as String?) ?? '',
        due: json['due'] as String,
        ordered: json['ordered'] as String,
        stage: OrderStage.values.firstWhere(
          (s) => s.name == json['stage'],
          orElse: () => OrderStage.queued,
        ),
        delivered: (json['delivered'] as bool?) ?? false,
        drawing: json['drawing'] as String?,
        workType: WorkTypeX.fromValue(json['work_type'] as String?),
        customerId: json['customer_id'] as int?,
        supplierId: json['supplier_id'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'customer': customer,
        'item': item,
        'spec': spec,
        'qty': qty,
        'material': material,
        'due': due,
        'ordered': ordered,
        'stage': stage.name,
        'delivered': delivered,
        'drawing': drawing,
        'work_type': workType.value,
        'customer_id': customerId,
        'supplier_id': supplierId,
      };

  Order copyWith({
    int? id,
    String? customer,
    String? item,
    String? spec,
    int? qty,
    String? material,
    String? due,
    String? ordered,
    OrderStage? stage,
    bool? delivered,
    String? drawing,
    WorkType? workType,
    int? customerId,
    int? supplierId,
  }) {
    return Order(
      id: id ?? this.id,
      customer: customer ?? this.customer,
      item: item ?? this.item,
      spec: spec ?? this.spec,
      qty: qty ?? this.qty,
      material: material ?? this.material,
      due: due ?? this.due,
      ordered: ordered ?? this.ordered,
      stage: stage ?? this.stage,
      delivered: delivered ?? this.delivered,
      drawing: drawing ?? this.drawing,
      workType: workType ?? this.workType,
      customerId: customerId ?? this.customerId,
      supplierId: supplierId ?? this.supplierId,
    );
  }

  @override
  List<Object?> get props => [
        id, customer, item, spec, qty, material, due, ordered,
        stage, delivered, drawing, workType, customerId, supplierId,
      ];
}
