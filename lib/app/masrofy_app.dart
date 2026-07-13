import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_theme.dart';
import '../di/service_locator.dart';
import '../l10n/generated/app_localizations.dart';
import '../presentation/cubits/security/app_lock_cubit.dart';
import '../presentation/cubits/settings/app_settings_cubit.dart';
import '../presentation/cubits/transactions/transactions_cubit.dart';
import '../presentation/screens/onboarding/onboarding_screen.dart';
import '../presentation/security/app_lock_gate.dart';

class MasrofyApp extends StatelessWidget {
  const MasrofyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = serviceLocator<GoRouter>();

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: serviceLocator<AppSettingsCubit>()),
        BlocProvider(
          create: (context) => serviceLocator<AppLockCubit>()..load(),
        ),
        BlocProvider(
          create: (context) => serviceLocator<TransactionsCubit>()..load(),
        ),
      ],
      child: BlocBuilder<AppSettingsCubit, AppSettingsState>(
        builder: (context, settings) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            routerConfig: router,
            onGenerateTitle: (context) => AppLocalizations.of(context).appName,
            locale: settings.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: settings.themeMode,
            builder: (context, child) {
              if (!settings.onboardingCompleted) {
                return OnboardingScreen(
                  onFinished: () {
                    return context
                        .read<AppSettingsCubit>()
                        .completeOnboarding();
                  },
                );
              }
              return AppLockGate(child: child ?? const SizedBox.shrink());
            },
          );
        },
      ),
    );
  }
}
