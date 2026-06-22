import 'package:equatable/equatable.dart';

enum ChatRole { user, assistant }

class ChatMessage extends Equatable {
  final ChatRole role;
  final String text;
  final DateTime timestamp;

  const ChatMessage({
    required this.role,
    required this.text,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [role, text, timestamp];
}

class AgentState extends Equatable {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;

  const AgentState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
  });

  AgentState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return AgentState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [messages, isLoading, error];
}
