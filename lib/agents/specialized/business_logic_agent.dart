import 'dart:convert';
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import '../../cubits/orders/orders_cubit.dart';
import '../../cubits/inventory/inventory_cubit.dart';
import '../../cubits/invoices/invoices_cubit.dart';
import '../core/base_agent.dart';

class BusinessLogicAgent extends BaseAgent {
  final OrdersCubit ordersCubit;
  final InventoryCubit inventoryCubit;
  final InvoicesCubit invoicesCubit;

  BusinessLogicAgent({
    required this.ordersCubit,
    required this.inventoryCubit,
    required this.invoicesCubit,
  });

  @override
  String get systemPrompt => '''
You are a business data assistant for Shree Iron Works. You have access to live data about orders, inventory, and invoices.
Use your tools to answer questions accurately. Format your responses clearly and concisely.
When reporting lists, use bullet points. When reporting numbers, include context (e.g. "5 active orders").
''';

  @override
  List<Tool> get tools => [
    const Tool(
      name: 'get_orders',
      description: 'Get a list of orders. Optionally filter by status or search query.',
      inputSchema: InputSchema(
        properties: {
          'filter': {
            'type': 'string',
            'enum': ['all', 'active', 'done'],
            'description': 'Filter by order status',
          },
          'search': {
            'type': 'string',
            'description': 'Search by customer name or item',
          },
        },
      ),
    ),
    const Tool(
      name: 'get_order_detail',
      description: 'Get full details for a specific order by ID.',
      inputSchema: InputSchema(
        properties: {
          'order_id': {
            'type': 'integer',
            'description': 'The order ID',
          },
        },
        required: ['order_id'],
      ),
    ),
    const Tool(
      name: 'advance_order_stage',
      description: 'Advance an order to its next production stage.',
      inputSchema: InputSchema(
        properties: {
          'order_id': {
            'type': 'integer',
            'description': 'The order ID to advance',
          },
        },
        required: ['order_id'],
      ),
    ),
    const Tool(
      name: 'get_inventory',
      description: 'Get inventory items. Optionally filter to low-stock items only.',
      inputSchema: InputSchema(
        properties: {
          'search': {
            'type': 'string',
            'description': 'Search by material name or category',
          },
          'low_stock_only': {
            'type': 'boolean',
            'description': 'If true, return only items below reorder level',
          },
        },
      ),
    ),
    const Tool(
      name: 'get_invoices',
      description: 'Get invoices or quotes with totals.',
      inputSchema: InputSchema(
        properties: {
          'type': {
            'type': 'string',
            'enum': ['invoices', 'quotes'],
            'description': 'Whether to get invoices or quotes',
          },
        },
      ),
    ),
    const Tool(
      name: 'get_summary',
      description: 'Get a high-level business summary: active orders, low stock count, and invoice totals.',
      inputSchema: InputSchema(properties: {}),
    ),
  ];

  @override
  Future<String> handleToolCall(String name, Map<String, dynamic> args) async {
    switch (name) {
      case 'get_orders':
        return _getOrders(args);
      case 'get_order_detail':
        return _getOrderDetail(args);
      case 'advance_order_stage':
        return _advanceOrderStage(args);
      case 'get_inventory':
        return _getInventory(args);
      case 'get_invoices':
        return _getInvoices(args);
      case 'get_summary':
        return _getSummary();
      default:
        return 'Unknown tool: $name';
    }
  }

  String _getOrders(Map<String, dynamic> args) {
    final filterStr = args['filter'] as String? ?? 'all';
    final search = args['search'] as String? ?? '';

    var orders = ordersCubit.state.orders;

    if (filterStr == 'active') {
      orders = orders.where((o) => !o.delivered).toList();
    } else if (filterStr == 'done') {
      orders = orders.where((o) => o.delivered).toList();
    }

    if (search.trim().isNotEmpty) {
      final q = search.trim().toLowerCase();
      orders = orders.where((o) => '#${o.id} ${o.customer} ${o.item}'.toLowerCase().contains(q)).toList();
    }

    if (orders.isEmpty) return 'No orders found.';

    final list = orders.map((o) => {
      'id': o.id,
      'customer': o.customer,
      'item': o.item,
      'qty': o.qty,
      'stage': o.stageLabel,
      'due': o.due,
      'delivered': o.delivered,
    }).toList();

    return jsonEncode(list);
  }

  String _getOrderDetail(Map<String, dynamic> args) {
    final id = args['order_id'] as int;
    final order = ordersCubit.getOrderById(id);
    if (order == null) return 'Order #$id not found.';

    return jsonEncode({
      'id': order.id,
      'customer': order.customer,
      'item': order.item,
      'spec': order.spec,
      'qty': order.qty,
      'material': order.material,
      'due': order.due,
      'ordered': order.ordered,
      'stage': order.stageLabel,
      'stage_progress': order.stageProgress,
      'delivered': order.delivered,
    });
  }

  Future<String> _advanceOrderStage(Map<String, dynamic> args) async {
    final id = args['order_id'] as int;
    final before = ordersCubit.getOrderById(id);
    if (before == null) return 'Order #$id not found.';
    if (before.delivered) return 'Order #$id is already delivered.';

    await ordersCubit.advanceStage(id);

    final after = ordersCubit.getOrderById(id);
    return 'Order #$id advanced from "${before.stageLabel}" to "${after?.stageLabel ?? "Delivered"}".';
  }

  String _getInventory(Map<String, dynamic> args) {
    final search = args['search'] as String? ?? '';
    final lowOnly = args['low_stock_only'] as bool? ?? false;

    var items = lowOnly
        ? inventoryCubit.state.lowStockItems
        : inventoryCubit.state.items;

    if (search.trim().isNotEmpty) {
      final q = search.trim().toLowerCase();
      items = items.where((m) => '${m.name} ${m.category}'.toLowerCase().contains(q)).toList();
    }

    if (items.isEmpty) return lowOnly ? 'No low-stock items.' : 'No items found.';

    final list = items.map((m) => {
      'id': m.id,
      'name': m.name,
      'category': m.category,
      'qty': m.qty,
      'unit': m.unit,
      'reorder_level': m.reorder,
      'is_low': m.isLow,
    }).toList();

    return jsonEncode(list);
  }

  String _getInvoices(Map<String, dynamic> args) {
    final type = args['type'] as String? ?? 'invoices';
    final state = invoicesCubit.state;

    if (type == 'quotes') {
      final list = state.quotes.map((q) => {
        'id': q.id,
        'customer': q.customer,
        'amount': q.amount,
        'status': q.status.name,
        'date': q.date,
      }).toList();
      return jsonEncode(list);
    }

    final list = state.invoices.map((i) => {
      'id': i.id,
      'customer': i.customer,
      'amount': i.amount,
      'status': i.status.name,
      'date': i.date,
    }).toList();

    return jsonEncode({
      'invoices': list,
      'total_outstanding': state.totalOutstanding,
      'total_overdue': state.totalOverdue,
      'total_revenue': state.totalRevenue,
    });
  }

  String _getSummary() {
    final ordersState = ordersCubit.state;
    final invState = inventoryCubit.state;
    final invoiceState = invoicesCubit.state;

    return jsonEncode({
      'active_orders': ordersState.activeOrders.length,
      'total_orders': ordersState.orders.length,
      'low_stock_items': invState.lowStockItems.length,
      'total_inventory_items': invState.items.length,
      'outstanding_amount': invoiceState.totalOutstanding,
      'overdue_amount': invoiceState.totalOverdue,
      'revenue': invoiceState.totalRevenue,
    });
  }
}
