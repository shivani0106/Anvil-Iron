import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'cubits/auth/auth_cubit.dart';
import 'cubits/auth/auth_state.dart';
import 'cubits/navigation/navigation_cubit.dart';
import 'cubits/navigation/navigation_state.dart';
import 'cubits/orders/orders_cubit.dart';
import 'cubits/inventory/inventory_cubit.dart';
import 'cubits/invoices/invoices_cubit.dart';
import 'cubits/agent/agent_cubit.dart';
import 'screens/auth/sign_in_screen.dart';
import 'screens/hub/hub_screen.dart';
import 'screens/orders/orders_screen.dart';
import 'screens/orders/order_detail_screen.dart';
import 'screens/orders/new_order_screen.dart';
import 'screens/inventory/inventory_screen.dart';
import 'screens/inventory/stock_log_screen.dart';
import 'screens/suppliers/suppliers_screen.dart';
import 'screens/invoices/invoices_screen.dart';
import 'screens/drawings/drawings_screen.dart';
import 'screens/machines/machines_screen.dart';
import 'screens/reports/reports_screen.dart';
import 'screens/team/team_screen.dart';
import 'screens/agent/agent_chat_screen.dart';

class IronWorksApp extends StatelessWidget {
  const IronWorksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // AuthCubit lives at the top so every screen can read it.
      create: (_) => AuthCubit(),
      child: MaterialApp(
        title: 'Shree Iron Works',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const _AuthGate(),
      ),
    );
  }
}

/// Listens to [AuthCubit] and renders either [LoginScreen] or the full app.
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AppAuthState>(
      builder: (ctx, authState) {
        // Splash — Supabase is resolving the stored session
        if (authState is AppAuthInitial) return const _SplashScreen();

        // Not authenticated — show login
        if (authState is AppAuthUnauthenticated ||
            authState is AppAuthError ||
            authState is AppAuthLoading) {
          return const SignInScreen();
        }

        // Authenticated — mount the full app with all cubits
        return const _AppProviders();
      },
    );
  }
}

/// Thin splash shown during the ~150 ms Supabase session restore.
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF6F4EF),
      body: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE07A3C)),
          strokeWidth: 2.5,
        ),
      ),
    );
  }
}

/// All business cubits — only created once auth is confirmed.
class _AppProviders extends StatelessWidget {
  const _AppProviders();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => NavigationCubit()),
        BlocProvider(create: (_) => OrdersCubit()),
        BlocProvider(create: (_) => InventoryCubit()),
        BlocProvider(create: (_) => InvoicesCubit()),
        BlocProvider(
          create: (ctx) => AgentCubit(
            navigationCubit: ctx.read<NavigationCubit>(),
            ordersCubit: ctx.read<OrdersCubit>(),
            inventoryCubit: ctx.read<InventoryCubit>(),
            invoicesCubit: ctx.read<InvoicesCubit>(),
          ),
        ),
      ],
      child: const _AppRoot(),
    );
  }
}

class _AppRoot extends StatelessWidget {
  const _AppRoot();

  Widget _screenForEntry(ScreenEntry entry) {
    switch (entry.screen) {
      case AppScreen.hub:
        return const HubScreen();
      case AppScreen.orders:
        return const OrdersScreen();
      case AppScreen.orderDetail:
        return OrderDetailScreen(orderId: entry.orderId ?? 0);
      case AppScreen.newOrder:
        return const NewOrderScreen();
      case AppScreen.inventory:
        return const InventoryScreen();
      case AppScreen.stockLog:
        return StockLogScreen(materialId: entry.materialId ?? 0);
      case AppScreen.suppliers:
        return const SuppliersScreen();
      case AppScreen.invoices:
        return const InvoicesScreen();
      case AppScreen.drawings:
        return const DrawingsScreen();
      case AppScreen.machines:
        return const MachinesScreen();
      case AppScreen.reports:
        return const ReportsScreen();
      case AppScreen.team:
        return const TeamScreen();
      case AppScreen.agent:
        return const AgentChatScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, NavigationState>(
      builder: (ctx, navState) {
        return Stack(
          children: [
            Navigator(
              pages: navState.stack.map((entry) {
                return MaterialPage(
                  key: ValueKey('${entry.screen.name}-${entry.orderId}-${entry.materialId}'),
                  child: _screenForEntry(entry),
                );
              }).toList(),
              onDidRemovePage: (page) {
                ctx.read<NavigationCubit>().back();
              },
            ),
            // Toast overlay
            if (navState.toast != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 100,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                    decoration: BoxDecoration(
                      color: const Color(0xFF23211E),
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: const [
                        BoxShadow(color: Color(0x47000000), blurRadius: 28, offset: Offset(0, 10)),
                      ],
                    ),
                    child: Text(
                      navState.toast!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
