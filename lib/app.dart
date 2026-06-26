import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_color_scheme.dart';
import 'cubits/auth/auth_cubit.dart';
import 'cubits/auth/auth_state.dart';
import 'cubits/theme/theme_cubit.dart';
import 'cubits/navigation/navigation_cubit.dart';
import 'cubits/navigation/navigation_state.dart';
import 'cubits/orders/orders_cubit.dart';
import 'cubits/inventory/inventory_cubit.dart';
import 'cubits/invoices/invoices_cubit.dart';
import 'cubits/customers/customers_cubit.dart';
import 'cubits/suppliers/suppliers_cubit.dart';
import 'cubits/machines/machines_cubit.dart';
import 'cubits/materials/materials_cubit.dart';
import 'cubits/teams_mgmt/teams_mgmt_cubit.dart';
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
import 'cubits/drawings/drawings_cubit.dart';
import 'screens/drawings/drawings_screen.dart';
import 'screens/drawings/drawing_viewer_screen.dart';
import 'screens/machines/machines_screen.dart';
import 'screens/reports/reports_screen.dart';
import 'screens/team/team_screen.dart';
import 'screens/agent/agent_chat_screen.dart';
import 'screens/customers/customers_screen.dart';
import 'screens/materials/materials_screen.dart';
import 'widgets/common/screen_app_bar.dart';

class IronWorksApp extends StatelessWidget {
  const IronWorksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => AuthCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (ctx, themeMode) {
          final isDark = themeMode == ThemeMode.dark;
          SystemChrome.setSystemUIOverlayStyle(
            isDark
                ? SystemUiOverlayStyle.light.copyWith(
                    statusBarColor: Colors.transparent,
                    systemNavigationBarColor: AppColorScheme.dark.surface,
                    systemNavigationBarIconBrightness: Brightness.light,
                  )
                : SystemUiOverlayStyle.dark.copyWith(
                    statusBarColor: Colors.transparent,
                    systemNavigationBarColor: AppColorScheme.light.surface,
                    systemNavigationBarIconBrightness: Brightness.dark,
                  ),
          );
          return MaterialApp(
            title: 'Anvil',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.theme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            home: const _AuthGate(),
          );
        },
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AppAuthState>(
      builder: (ctx, authState) {
        if (authState is AppAuthInitial) return const _SplashScreen();

        if (authState is AppAuthUnauthenticated ||
            authState is AppAuthError ||
            authState is AppAuthLoading) {
          return const SignInScreen();
        }

        return const _AppProviders();
      },
    );
  }
}

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
        BlocProvider(create: (_) => CustomersCubit()),
        BlocProvider(create: (_) => SuppliersCubit()),
        BlocProvider(create: (_) => MachinesCubit()),
        BlocProvider(create: (_) => MaterialsCubit()),
        BlocProvider(create: (_) => TeamsMgmtCubit()),
        BlocProvider(create: (_) => DrawingsCubit()),
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

class _AppRoot extends StatefulWidget {
  const _AppRoot();

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  DateTime? _lastHubBackPress;

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
      case AppScreen.drawingViewer:
        final drawing = context.read<DrawingsCubit>().getById(entry.drawingId ?? '');
        if (drawing == null) {
          return Scaffold(
            appBar: const ScreenAppBar(title: 'Drawing'),
            body: const Center(child: Text('Drawing not found')),
          );
        }
        return DrawingViewerScreen(drawing: drawing);
      case AppScreen.machines:
        return const MachinesScreen();
      case AppScreen.reports:
        return const ReportsScreen();
      case AppScreen.team:
        return const TeamScreen();
      case AppScreen.agent:
        return const AgentChatScreen();
      case AppScreen.customers:
        return const CustomersScreen();
      case AppScreen.materials:
        return const MaterialsScreen();
    }
  }

  void _handleBackPress(NavigationCubit navCubit, NavigationState navState) {
    // Let the child Navigator handle modals / bottom sheets first.
    final childNav = _navigatorKey.currentState;
    if (childNav != null && childNav.canPop()) {
      childNav.pop();
      return;
    }

    // Non-hub screen → navigate back within the app.
    if (navState.current.screen != AppScreen.hub) {
      navCubit.back();
      return;
    }

    // Hub screen → double-back-to-exit.
    final now = DateTime.now();
    if (_lastHubBackPress != null &&
        now.difference(_lastHubBackPress!) < const Duration(seconds: 2)) {
      SystemNavigator.pop();
      return;
    }
    _lastHubBackPress = now;
    navCubit.showToast('Press back again to exit');
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, NavigationState>(
      builder: (ctx, navState) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _handleBackPress(ctx.read<NavigationCubit>(), navState);
          },
          child: Stack(
            children: [
              Navigator(
                key: _navigatorKey,
                pages: navState.stack.map((entry) {
                  return MaterialPage(
                    key: ValueKey('${entry.screen.name}-${entry.orderId}-${entry.materialId}-${entry.customerId}-${entry.drawingId}'),
                    child: _screenForEntry(entry),
                  );
                }).toList(),
                onDidRemovePage: (page) {
                  ctx.read<NavigationCubit>().back();
                },
              ),
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
          ),
        );
      },
    );
  }
}
