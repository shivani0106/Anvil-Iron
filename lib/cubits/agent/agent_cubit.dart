import 'package:flutter_bloc/flutter_bloc.dart';
import '../../agents/specialized/orchestrator_agent.dart';
import '../../cubits/navigation/navigation_cubit.dart';
import '../../cubits/orders/orders_cubit.dart';
import '../../cubits/inventory/inventory_cubit.dart';
import '../../cubits/invoices/invoices_cubit.dart';
import '../../agents/specialized/ui_agent.dart';
import '../../agents/specialized/business_logic_agent.dart';
import 'agent_state.dart';

class AgentCubit extends Cubit<AgentState> {
  late final OrchestratorAgent _orchestrator;

  AgentCubit({
    required NavigationCubit navigationCubit,
    required OrdersCubit ordersCubit,
    required InventoryCubit inventoryCubit,
    required InvoicesCubit invoicesCubit,
  }) : super(const AgentState()) {
    _orchestrator = OrchestratorAgent(
      uiAgent: UIAgent(navigationCubit: navigationCubit),
      businessLogicAgent: BusinessLogicAgent(
        ordersCubit: ordersCubit,
        inventoryCubit: inventoryCubit,
        invoicesCubit: invoicesCubit,
      ),
    );
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(
      role: ChatRole.user,
      text: text.trim(),
      timestamp: DateTime.now(),
    );

    emit(state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
      clearError: true,
    ));

    try {
      final reply = await _orchestrator.run(text.trim(), []);

      final assistantMsg = ChatMessage(
        role: ChatRole.assistant,
        text: reply,
        timestamp: DateTime.now(),
      );

      emit(state.copyWith(
        messages: [...state.messages, assistantMsg],
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Something went wrong. Please try again.',
      ));
    }
  }

  void clearChat() {
    emit(const AgentState());
  }
}
