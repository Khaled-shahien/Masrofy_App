import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masrofy/app/masrofy_app.dart';
import 'package:masrofy/core/security/secure_value_store.dart';
import 'package:masrofy/di/service_locator.dart';
import 'package:masrofy/presentation/widgets/transactions/transaction_formatters.dart';

void main() {
  setUp(() async {
    serviceLocator.registerSingleton<SecureValueStore>(
      InMemorySecureValueStore(),
    );
    await configureDependencies();
  });

  tearDown(serviceLocator.reset);

  testWidgets('shows the Arabic dashboard shell', (tester) async {
    await tester.pumpWidget(const MasrofyApp());
    await tester.pumpAndSettle();

    expect(find.text('مصروفي'), findsOneWidget);
    expect(find.text('الرئيسية'), findsOneWidget);
    expect(find.text('لا توجد معاملات حتى الآن'), findsOneWidget);
  });

  testWidgets('adds a daily expense from the floating action button', (
    tester,
  ) async {
    await tester.pumpWidget(const MasrofyApp());
    await tester.pumpAndSettle();

    await _addExpense(tester, '100');

    expect(find.text('ملخص المصاريف'), findsOneWidget);
    expect(find.text('لا توجد معاملات حتى الآن'), findsNothing);
  });

  testWidgets('groups same-day history entries under one date heading', (
    tester,
  ) async {
    await tester.pumpWidget(const MasrofyApp());
    await tester.pumpAndSettle();

    await _addExpense(tester, '100');
    await _addExpense(tester, '60');

    await tester.tap(find.byIcon(Icons.receipt_long_outlined));
    await tester.pumpAndSettle();

    expect(find.text(formatDay(DateTime.now())), findsOneWidget);
  });
}

Future<void> _addExpense(WidgetTester tester, String amount) async {
  await tester.tap(find.byIcon(Icons.add));
  await tester.pumpAndSettle();

  await tester.enterText(
    find.byKey(const ValueKey('transaction_amount_field')),
    amount,
  );
  await tester.tap(find.byKey(const ValueKey('save_transaction_button')));
  await tester.pumpAndSettle();
}
