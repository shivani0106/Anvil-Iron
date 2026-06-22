import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import '../../cubits/navigation/navigation_cubit.dart';
import '../../cubits/navigation/navigation_state.dart';
import '../core/base_agent.dart';

class UIAgent extends BaseAgent {
  final NavigationCubit navigationCubit;

  UIAgent({required this.navigationCubit});

  @override
  String get systemPrompt => '''
You are a navigation assistant for the Shree Iron Works app. You can navigate between screens, show notifications, and go back.
Available screens: hub, orders, inventory, invoices, machines, suppliers, drawings, team, reports, agent.
Use tools to execute navigation. Always confirm what you did.
''';

  @override
  List<Tool> get tools => [
    const Tool(
      name: 'navigate_to',
      description: 'Navigate to a specific screen in the app.',
      inputSchema: InputSchema(
        properties: {
          'screen': {
            'type': 'string',
            'enum': ['hub', 'orders', 'inventory', 'invoices', 'machines', 'suppliers', 'drawings', 'team', 'reports'],
            'description': 'The screen to navigate to',
          },
        },
        required: ['screen'],
      ),
    ),
    const Tool(
      name: 'go_back',
      description: 'Go back to the previous screen.',
      inputSchema: InputSchema(properties: {}),
    ),
    const Tool(
      name: 'show_toast',
      description: 'Show a short notification message at the bottom of the screen.',
      inputSchema: InputSchema(
        properties: {
          'message': {
            'type': 'string',
            'description': 'The notification text (keep it under 50 characters)',
          },
        },
        required: ['message'],
      ),
    ),
  ];

  @override
  Future<String> handleToolCall(String name, Map<String, dynamic> args) async {
    switch (name) {
      case 'navigate_to':
        return _navigateTo(args['screen'] as String);
      case 'go_back':
        return _goBack();
      case 'show_toast':
        return _showToast(args['message'] as String);
      default:
        return 'Unknown tool: $name';
    }
  }

  String _navigateTo(String screenName) {
    final screenMap = {
      'hub': AppScreen.hub,
      'orders': AppScreen.orders,
      'inventory': AppScreen.inventory,
      'invoices': AppScreen.invoices,
      'machines': AppScreen.machines,
      'suppliers': AppScreen.suppliers,
      'drawings': AppScreen.drawings,
      'team': AppScreen.team,
      'reports': AppScreen.reports,
    };

    final screen = screenMap[screenName];
    if (screen == null) return 'Unknown screen: $screenName';

    navigationCubit.navigateTo(screen);
    return 'Navigated to $screenName screen.';
  }

  String _goBack() {
    if (!navigationCubit.state.canGoBack) {
      return 'Already at the home screen — cannot go back.';
    }
    navigationCubit.back();
    return 'Went back to the previous screen.';
  }

  String _showToast(String message) {
    navigationCubit.showToast(message);
    return 'Showed notification: "$message"';
  }
}
