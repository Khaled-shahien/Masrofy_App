import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masrofy/core/theme/app_theme.dart';
import 'package:masrofy/domain/entities/category.dart';
import 'package:masrofy/domain/entities/financial_transaction.dart';
import 'package:masrofy/domain/entities/transaction_type.dart';
import 'package:masrofy/domain/entities/wallet_type.dart';
import 'package:masrofy/l10n/generated/app_localizations.dart';
import 'package:masrofy/presentation/widgets/transactions/transaction_list_tile.dart';

void main() {
  testWidgets('confirms before deleting a transaction', (tester) async {
    var deleted = false;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.light(),
        home: Scaffold(
          body: Center(
            child: Card(
              child: TransactionListTile(
                transaction: _transaction(),
                category: _category(),
                onDelete: () => deleted = true,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.textContaining('Cash'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    expect(find.text('Delete this transaction?'), findsOneWidget);
    expect(deleted, isFalse);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(deleted, isTrue);
  });
}

Category _category() {
  return const Category(
    id: 'food',
    type: TransactionType.expense,
    name: 'Food',
    localizationKey: null,
    iconKey: 'restaurant',
    colorValue: 0xFF2A9D8F,
    sortOrder: 0,
  );
}

FinancialTransaction _transaction() {
  return FinancialTransaction(
    id: 'tx-1',
    type: TransactionType.expense,
    amount: 125,
    categoryId: 'food',
    wallet: WalletType.cash,
    note: 'Lunch',
    date: DateTime(2026, 7, 12),
    createdAt: DateTime(2026, 7, 12),
    updatedAt: DateTime(2026, 7, 12),
  );
}
