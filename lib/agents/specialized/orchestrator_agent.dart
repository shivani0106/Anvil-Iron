import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import '../core/base_agent.dart';
import 'business_logic_agent.dart';
import 'ui_agent.dart';

class OrchestratorAgent extends BaseAgent {
  final UIAgent uiAgent;
  final BusinessLogicAgent businessLogicAgent;

  OrchestratorAgent({
    required this.uiAgent,
    required this.businessLogicAgent,
  });

  @override
  String get systemPrompt => '''
You are Anvil AI, the intelligent assistant for Shree Iron Works. You help staff manage orders, inventory, invoices, and navigate the app.

You have two sub-agents:
1. **business** — for data queries and actions (orders, inventory, invoices, summaries)
2. **ui** — for app navigation (go to screens, show notifications, go back)

For any user request:
- If it involves data (showing orders, checking stock, advancing stages, getting totals) → delegate to business
- If it involves navigation (go to a screen, show a message) → delegate to ui
- If it involves both → delegate to both, in order

Always delegate via tools. Never answer data questions from memory — always call the sub-agent.
Respond in a friendly, concise tone suitable for manufacturing floor staff.
''';

  @override
  List<Tool> get tools => [
    const Tool(
      name: 'ask_business_agent',
      description: 'Ask the business logic agent to query or act on orders, inventory, or invoices data.',
      inputSchema: InputSchema(
        properties: {
          'task': {
            'type': 'string',
            'description': 'The task or question to send to the business agent',
          },
        },
        required: ['task'],
      ),
    ),
    const Tool(
      name: 'ask_ui_agent',
      description: 'Ask the UI agent to navigate to a screen or show a notification.',
      inputSchema: InputSchema(
        properties: {
          'task': {
            'type': 'string',
            'description': 'The navigation or UI action to perform',
          },
        },
        required: ['task'],
      ),
    ),
  ];

  @override
  Future<String> handleToolCall(String name, Map<String, dynamic> args) async {
    final task = args['task'] as String;
    switch (name) {
      case 'ask_business_agent':
        return businessLogicAgent.run(task, []);
      case 'ask_ui_agent':
        return uiAgent.run(task, []);
      default:
        return 'Unknown tool: $name';
    }
  }
}
