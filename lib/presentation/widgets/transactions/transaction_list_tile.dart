import 'package:flutter/material.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../../../core/theme/masrofy_theme_extension.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/financial_transaction.dart';
import '../../../domain/entities/transaction_type.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../categories/category_localization.dart';
import '../categories/category_visual_registry.dart';
import '../privacy/financial_privacy.dart';
import 'transaction_formatters.dart';

class TransactionListTile extends StatelessWidget {
  const TransactionListTile({
    required this.transaction,
    required this.category,
    this.onTap,
    this.onDelete,
    super.key,
  });

  final FinancialTransaction transaction;
  final Category? category;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final colors = Theme.of(context).extension<MasrofyThemeExtension>()!;
    final localizations = AppLocalizations.of(context);
    final obscureAmount = financialAmountsObscured(context);
    final category = this.category;
    final categoryName = category == null
        ? localizations.unknownCategory
        : localizedCategoryName(localizations, category);
    final color = category == null
        ? colorScheme.outline
        : Color(category.colorValue);
    final amountColor = transaction.type == TransactionType.expense
        ? colors.expense
        : colors.income;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxs,
      ),
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.16),
        foregroundColor: color,
        child: Icon(
          category == null
              ? Icons.category_outlined
              : categoryIconFor(category.iconKey),
        ),
      ),
      title: Text(
        categoryName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        _transactionSubtitle(transaction, localizations.localeName),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formatTransactionAmount(
              transaction,
              localeName: localizations.localeName,
              currencySymbol: localizations.currencySymbol,
              obscure: obscureAmount,
            ),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: amountColor,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (onDelete != null) ...[
            const SizedBox(width: AppSpacing.xxs),
            IconButton(
              tooltip: localizations.transactionDeleteTooltip,
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ],
      ),
    );
  }
}

String _transactionSubtitle(
  FinancialTransaction transaction,
  String localeName,
) {
  final details = <String>[
    formatShortDate(transaction.date, localeName: localeName),
  ];
  if (transaction.note case final note? when note.isNotEmpty) {
    details.add(note);
  }
  if (transaction.personName case final person? when person.isNotEmpty) {
    details.add(person);
  }
  return details.join(' - ');
}
