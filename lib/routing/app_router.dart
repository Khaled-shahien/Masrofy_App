import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_design_tokens.dart';
import '../di/service_locator.dart';
import '../presentation/cubits/budgets/budgets_cubit.dart';
import '../presentation/cubits/categories/categories_cubit.dart';
import '../presentation/cubits/reports/reports_cubit.dart';
import '../presentation/cubits/wallets/wallet_balances_cubit.dart';
import '../presentation/screens/budgets/budgets_screen.dart';
import '../presentation/screens/dashboard/dashboard_screen.dart';
import '../presentation/screens/history/history_screen.dart';
import '../presentation/screens/not_found_screen.dart';
import '../presentation/screens/reports/reports_screen.dart';
import '../presentation/screens/settings/categories/categories_screen.dart';
import '../presentation/screens/settings/settings_screen.dart';
import '../presentation/screens/settings/wallets/wallet_balances_screen.dart';
import '../presentation/shell/main_shell.dart';

class AppRoutes {
  const AppRoutes._();

  static const dashboard = '/dashboard';
  static const history = '/history';
  static const reports = '/reports';
  static const budgets = '/budgets';
  static const settings = '/settings';
  static const categories = '/settings/categories';
  static const walletBalances = '/settings/wallet-balances';
}

class AppRouter {
  AppRouter();

  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.dashboard,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                pageBuilder: (context, state) => _fadeThroughPage(
                  state: state,
                  child: const DashboardScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.history,
                pageBuilder: (context, state) => _fadeThroughPage(
                  state: state,
                  child: const HistoryScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.reports,
                pageBuilder: (context, state) => _fadeThroughPage(
                  state: state,
                  child: BlocProvider(
                    create: (context) => serviceLocator<ReportsCubit>()..load(),
                    child: const ReportsScreen(),
                  ),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.budgets,
                pageBuilder: (context, state) => _fadeThroughPage(
                  state: state,
                  child: BlocProvider(
                    create: (context) => serviceLocator<BudgetsCubit>()..load(),
                    child: const BudgetsScreen(),
                  ),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                pageBuilder: (context, state) => _fadeThroughPage(
                  state: state,
                  child: const SettingsScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.categories,
        pageBuilder: (context, state) => _fadeThroughPage(
          state: state,
          child: BlocProvider(
            create: (context) => serviceLocator<CategoriesCubit>()..load(),
            child: const CategoriesScreen(),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.walletBalances,
        pageBuilder: (context, state) => _fadeThroughPage(
          state: state,
          child: BlocProvider(
            create: (context) => serviceLocator<WalletBalancesCubit>()..load(),
            child: const WalletBalancesScreen(),
          ),
        ),
      ),
    ],
    errorBuilder: (context, state) => const NotFoundScreen(),
  );
}

CustomTransitionPage<void> _fadeThroughPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: AppDurations.standard,
    reverseTransitionDuration: AppDurations.fast,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final reducedMotion = MediaQuery.disableAnimationsOf(context);
      if (reducedMotion) {
        return child;
      }
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: AppCurves.standard,
        reverseCurve: AppCurves.emphasized,
      );
      return FadeTransition(
        opacity: curvedAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.025),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        ),
      );
    },
  );
}
