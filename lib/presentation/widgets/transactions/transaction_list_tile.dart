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
    final amountText = formatTransactionAmount(
      transaction,
      localeName: localizations.localeName,
      currencySymbol: localizations.currencySymbol,
      obscure: obscureAmount,
    );

    return Semantics(
      button: onTap != null,
      label: '$categoryName, $amountText',
      child: ListTile(
        onTap: onTap,
        minVerticalPadding: AppSpacing.sm,
        contentPadding: const EdgeInsetsDirectional.only(
          start: AppSpacing.xs,
          end: AppSpacing.xxs,
        ),
        leading: DecoratedBox(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: AppRadii.card,
          ),
          child: SizedBox.square(
            dimension: 46,
            child: Icon(
              category == null
                  ? Icons.category_outlined
                  : categoryIconFor(category.iconKey),
              color: color,
            ),
          ),
        ),
        title: Text(
          categoryName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xxs),
          child: Text(
            _transactionSubtitle(transaction, localizations),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amountText,
                  textDirection: TextDirection.ltr,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: amountColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                _TransactionTypeBadge(
                  type: transaction.type,
                  color: amountColor,
                ),
              ],
            ),
            if (onDelete != null) ...[
              const SizedBox(width: AppSpacing.xxs),
              IconButton(
                tooltip: localizations.transactionDeleteTooltip,
                onPressed: () => _confirmDelete(context),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final localizations = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(localizations.transactionDeleteTooltip),
        content: Text(localizations.transactionDeleteConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(localizations.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(localizations.commonDelete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      onDelete?.call();
    }
  }
}

class _TransactionTypeBadge extends StatelessWidget {
  const _TransactionTypeBadge({required this.type, required this.color});

  final TransactionType type;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final icon = type == TransactionType.expense
        ? Icons.south_west
        : Icons.north_east;
    final label = type == TransactionType.expense
        ? localizations.transactionTypeExpenseForm
        : localizations.transactionTypeIncomeForm;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadii.pill,
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xxs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: AppSpacing.xxs),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _transactionSubtitle(
  FinancialTransaction transaction,
  AppLocalizations localizations,
) {
  final details = <String>[
    formatShortDate(transaction.date, localeName: localizations.localeName),
  ];
  if (transaction.wallet case final wallet?) {
    details.add(localizedWalletName(localizations, wallet));
  }
  if (transaction.note case final note? when note.isNotEmpty) {
    details.add(note);
  }
  if (transaction.personName case final person? when person.isNotEmpty) {
    details.add(person);
  }
  return details.join(' - ');
}
