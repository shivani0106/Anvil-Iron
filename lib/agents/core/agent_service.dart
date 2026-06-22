import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

typedef ToolHandler = Future<String> Function(String name, Map<String, dynamic> args);

class AgentService {
  static AgentService? _instance;
  late final AnthropicClient _client;

  AgentService._() {
    _client = AnthropicClient(
      config: AnthropicConfig(
        authProvider: ApiKeyProvider(dotenv.env['ANTHROPIC_API_KEY'] ?? ''),
      ),
    );
  }

  static AgentService get instance => _instance ??= AgentService._();

  Future<String> run({
    required String systemPrompt,
    required List<InputMessage> history,
    required List<Tool> tools,
    required ToolHandler onToolCall,
  }) async {
    final messages = List<InputMessage>.from(history);
    final toolDefs = tools.map(ToolDefinition.custom).toList();

    while (true) {
      final response = await _client.messages.create(
        MessageCreateRequest(
          model: 'claude-sonnet-4-6',
          maxTokens: 1024,
          system: SystemPrompt.text(systemPrompt),
          tools: toolDefs.isEmpty ? null : toolDefs,
          messages: messages,
        ),
      );

      if (!response.hasToolUse) {
        return response.text;
      }

      // Append the assistant's tool-use turn
      messages.add(
        InputMessage.assistantBlocks(
          response.content.map((b) => switch (b) {
            TextBlock(:final text) => TextInputBlock(text),
            ToolUseBlock(:final id, :final name, :final input) =>
              ToolUseInputBlock(id: id, name: name, input: input),
            _ => throw StateError('Unexpected block type: $b'),
          }).toList(),
        ),
      );

      // Execute all tool calls and build the result message
      final resultBlocks = <ToolResultInputBlock>[];
      for (final toolUse in response.toolUseBlocks) {
        final args = Map<String, dynamic>.from(toolUse.input);
        final result = await onToolCall(toolUse.name, args);
        resultBlocks.add(ToolResultInputBlock(
          toolUseId: toolUse.id,
          content: [ToolResultTextContent(result)],
        ));
      }

      messages.add(InputMessage(
        role: MessageRole.user,
        content: MessageContent.blocks(resultBlocks),
      ));
    }
  }

  void dispose() {
    _client.close();
    _instance = null;
  }
}
