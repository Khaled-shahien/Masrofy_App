import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../core/theme/app_design_tokens.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/financial_transaction.dart';
import '../../domain/entities/transaction_type.dart';
import '../../l10n/generated/app_localizations.dart';
import 'empty_state.dart';
import 'loading_skeleton.dart';
import 'transactions/transaction_list_tile.dart';

Widget masrofyPreviewWrapper(Widget child) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    locale: const Locale('ar'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    theme: AppTheme.light(),
    darkTheme: AppTheme.dark(),
    home: Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: child,
          ),
        ),
      ),
    ),
  );
}

@Preview(
  group: 'Masrofy Widgets',
  name: 'Empty state',
  size: Size(390, 420),
  wrapper: masrofyPreviewWrapper,
)
Widget emptyStatePreview() {
  return const EmptyState(
    icon: Icons.receipt_long_outlined,
    title: 'لا توجد معاملات',
    body: 'ابدأ بإضافة أول مصروف أو دخل لعرضه هنا.',
  );
}

@Preview(
  group: 'Masrofy Widgets',
  name: 'Loading skeleton',
  size: Size(390, 420),
  wrapper: masrofyPreviewWrapper,
)
Widget loadingSkeletonPreview() {
  return const LoadingSkeleton(itemCount: 4);
}

@Preview(
  group: 'Masrofy Widgets',
  name: 'Transaction tile',
  size: Size(390, 160),
  wrapper: masrofyPreviewWrapper,
)
Widget transactionTilePreview() {
  final now = DateTime(2026, 7, 10, 12);
  return Card(
    child: TransactionListTile(
      transaction: FinancialTransaction(
        id: 'preview-transaction',
        type: TransactionType.expense,
        amount: 170,
        categoryId: 'subscriptions',
        date: now,
        note: 'باقة فون',
        createdAt: now,
        updatedAt: now,
      ),
      category: const Category(
        id: 'subscriptions',
        type: TransactionType.expense,
        name: 'Subscriptions',
        localizationKey: 'subscriptions',
        iconKey: 'subscriptions',
        colorValue: 0xFF5E60CE,
        sortOrder: 1,
      ),
    ),
  );
}
