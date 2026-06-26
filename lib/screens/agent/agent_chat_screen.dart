import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_color_scheme.dart';
import '../../cubits/agent/agent_cubit.dart';
import '../../cubits/agent/agent_state.dart';
import '../../cubits/navigation/navigation_cubit.dart';
import '../../widgets/agent/chat_bubble.dart';
import '../../widgets/agent/agent_input_bar.dart';

class AgentChatScreen extends StatefulWidget {
  const AgentChatScreen({super.key});

  @override
  State<AgentChatScreen> createState() => _AgentChatScreenState();
}

class _AgentChatScreenState extends State<AgentChatScreen> {
  final _scrollController = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: context.colors.textPrimary),
          onPressed: () => context.read<NavigationCubit>().back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Anvil AI',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: context.colors.textPrimary,
              ),
            ),
            Text(
              'Your business assistant',
              style: TextStyle(
                fontSize: 11,
                color: context.colors.textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, size: 20, color: context.colors.textSecondary),
            onPressed: () => context.read<AgentCubit>().clearChat(),
            tooltip: 'Clear chat',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: context.colors.border),
        ),
      ),
      body: BlocConsumer<AgentCubit, AgentState>(
        listener: (ctx, state) {
          _scrollToBottom();
        },
        builder: (ctx, state) {
          return Column(
            children: [
              Expanded(
                child: state.messages.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                        itemCount: state.messages.length,
                        itemBuilder: (_, i) => ChatBubble(message: state.messages[i]),
                      ),
              ),
              if (state.error != null)
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColorScheme.error.withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColorScheme.error.withAlpha(77)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, size: 16, color: AppColorScheme.error),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          state.error!,
                          style: const TextStyle(fontSize: 13, color: AppColorScheme.error),
                        ),
                      ),
                    ],
                  ),
                ),
              AgentInputBar(
                isLoading: state.isLoading,
                onSend: (text) => ctx.read<AgentCubit>().sendMessage(text),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColorScheme.accent.withAlpha(26),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.auto_awesome_rounded, size: 32, color: AppColorScheme.accent),
            ),
            const SizedBox(height: 16),
            Text(
              'Anvil AI',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ask me anything about your orders, inventory, or invoices. I can also navigate the app for you.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: context.colors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 24),
            _buildSuggestionChips(),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChips() {
    final suggestions = [
      'Show active orders',
      'Any low stock items?',
      'Go to inventory',
      'Outstanding invoice total?',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: suggestions.map((s) => GestureDetector(
        onTap: () => context.read<AgentCubit>().sendMessage(s),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: context.colors.border),
          ),
          child: Text(
            s,
            style: TextStyle(
              fontSize: 13,
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      )).toList(),
    );
  }
}
