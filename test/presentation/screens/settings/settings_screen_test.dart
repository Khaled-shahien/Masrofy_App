import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masrofy/core/security/app_lock_service.dart';
import 'package:masrofy/core/security/secure_value_store.dart';
import 'package:masrofy/core/settings/app_settings_store.dart';
import 'package:masrofy/core/theme/app_theme.dart';
import 'package:masrofy/l10n/generated/app_localizations.dart';
import 'package:masrofy/presentation/cubits/security/app_lock_cubit.dart';
import 'package:masrofy/presentation/cubits/settings/app_settings_cubit.dart';
import 'package:masrofy/presentation/screens/settings/settings_screen.dart';

void main() {
  testWidgets('renders data management backup and reset actions', (
    tester,
  ) async {
    final cubit = AppSettingsCubit(store: InMemoryAppSettingsStore());
    final appLockCubit = AppLockCubit(
      appLockService: AppLockService(
        secureStore: InMemorySecureValueStore(),
        hashIterations: 4,
      ),
    );
    await appLockCubit.load();
    addTearDown(cubit.close);
    addTearDown(appLockCubit.close);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: cubit),
          BlocProvider.value(value: appLockCubit),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.light(),
          home: const Scaffold(body: SettingsScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Privacy and security'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('settings-enable-app-lock-tile')),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.text('Data management'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Data management'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('settings-export-backup-tile')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('settings-import-backup-tile')),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('settings-delete-data-tile')),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Delete all local data'), findsOneWidget);
  });
}
