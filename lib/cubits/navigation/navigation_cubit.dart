import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'navigation_state.dart';

class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit()
      : super(const NavigationState(
          stack: [ScreenEntry(screen: AppScreen.hub)],
        ));

  Timer? _toastTimer;

  void navigateTo(AppScreen screen, {int? orderId, int? materialId}) {
    emit(NavigationState(
      stack: [...state.stack, ScreenEntry(screen: screen, orderId: orderId, materialId: materialId)],
      toast: state.toast,
    ));
  }

  void back() {
    if (state.canGoBack) {
      emit(NavigationState(
        stack: state.stack.sublist(0, state.stack.length - 1),
        toast: state.toast,
      ));
    }
  }

  void replaceStack(List<ScreenEntry> entries) {
    emit(NavigationState(stack: entries, toast: state.toast));
  }

  void showToast(String message) {
    _toastTimer?.cancel();
    emit(NavigationState(stack: state.stack, toast: message));
    _toastTimer = Timer(const Duration(milliseconds: 1900), () {
      emit(NavigationState(stack: state.stack, toast: null));
    });
  }

  @override
  Future<void> close() {
    _toastTimer?.cancel();
    return super.close();
  }
}
