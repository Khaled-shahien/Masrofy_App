import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../di/service_locator.dart';
import '../presentation/cubits/categories/categories_cubit.dart';
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
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.history,
                builder: (context, state) => const HistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.reports,
                builder: (context, state) => const ReportsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.budgets,
                builder: (context, state) => const BudgetsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.categories,
        builder: (context, state) => BlocProvider(
          create: (context) => serviceLocator<CategoriesCubit>()..load(),
          child: const CategoriesScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.walletBalances,
        builder: (context, state) => BlocProvider(
          create: (context) => serviceLocator<WalletBalancesCubit>()..load(),
          child: const WalletBalancesScreen(),
        ),
      ),
    ],
    errorBuilder: (context, state) => const NotFoundScreen(),
  );
}
