import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'agent_service.dart';

abstract class BaseAgent {
  String get systemPrompt;
  List<Tool> get tools;

  Future<String> handleToolCall(String name, Map<String, dynamic> args);

  Future<String> run(String userMessage, List<InputMessage> history) async {
    final messages = [
      ...history,
      InputMessage.user(userMessage),
    ];

    return AgentService.instance.run(
      systemPrompt: systemPrompt,
      history: messages,
      tools: tools,
      onToolCall: handleToolCall,
    );
  }
}
