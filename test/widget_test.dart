import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masrofy/app/masrofy_app.dart';
import 'package:masrofy/core/security/biometric_authentication_service.dart';
import 'package:masrofy/core/security/secure_value_store.dart';
import 'package:masrofy/core/settings/app_settings_store.dart';
import 'package:masrofy/di/service_locator.dart';
import 'package:masrofy/presentation/widgets/empty_state.dart';
import 'package:masrofy/presentation/widgets/transactions/transaction_formatters.dart';

void main() {
  setUp(() async {
    serviceLocator.registerSingleton<SecureValueStore>(
      InMemorySecureValueStore(),
    );
    serviceLocator.registerSingleton<BiometricAuthenticationService>(
      InMemoryBiometricAuthenticationService(),
    );
    final settingsStore = InMemoryAppSettingsStore();
    await settingsStore.migrateOnboardingState(existingInstallation: true);
    serviceLocator.registerSingleton<AppSettingsStore>(settingsStore);
    await configureDependencies(
      existingInstallation: true,
      allowInMemoryStores: true,
    );
  });

  tearDown(serviceLocator.reset);

  testWidgets('shows the Arabic dashboard shell', (tester) async {
    await _pumpApp(tester);

    expect(find.byIcon(Icons.dashboard), findsOneWidget);
    expect(find.byIcon(Icons.account_balance_wallet_outlined), findsOneWidget);
  });

  testWidgets('adds a daily expense from the floating action button', (
    tester,
  ) async {
    await _pumpApp(tester);

    await _addExpense(tester, '100');

    expect(find.byIcon(Icons.account_balance_wallet_outlined), findsWidgets);
  });

  testWidgets('groups same-day history entries under one date heading', (
    tester,
  ) async {
    await _pumpApp(tester);

    await _addExpense(tester, '100');
    await _addExpense(tester, '60');

    await tester.tap(find.byIcon(Icons.receipt_long_outlined));
    await tester.pumpAndSettle();

    expect(find.text(formatDay(DateTime.now())), findsOneWidget);
  });
}

Future<void> _pumpApp(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(430, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(const MasrofyApp());
  await tester.pumpAndSettle();
}

Future<void> _addExpense(WidgetTester tester, String amount) async {
  final emptyStateAction = find.descendant(
    of: find.byType(EmptyState),
    matching: find.byType(FilledButton),
  );
  if (tester.any(emptyStateAction)) {
    await tester.tap(emptyStateAction.first);
  } else {
    await tester.tap(find.byIcon(Icons.add));
  }
  await tester.pumpAndSettle();

  await tester.enterText(
    find.byKey(const ValueKey('transaction_amount_field')).last,
    amount,
  );

  await tester.tap(
    find.byKey(const ValueKey('transaction_category_field')).last,
  );
  await tester.pumpAndSettle();
  final categoryItems = find.byWidgetPredicate(
    (widget) => widget is DropdownMenuItem<String>,
  );
  if (tester.any(categoryItems)) {
    await tester.tap(categoryItems.last);
    await tester.pumpAndSettle();
  }

  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();

  final saveButton = find.byKey(const ValueKey('save_transaction_button'));
  await tester.ensureVisible(saveButton);
  await tester.pumpAndSettle();
  tester.widget<FilledButton>(saveButton.last).onPressed?.call();
  await tester.pumpAndSettle();
}
