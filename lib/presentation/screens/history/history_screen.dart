import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../../../core/theme/masrofy_theme_extension.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/financial_transaction.dart';
import '../../../domain/entities/transaction_filter.dart';
import '../../../domain/entities/transaction_type.dart';
import '../../../domain/entities/wallet_type.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../cubits/transactions/transactions_cubit.dart';
import '../../cubits/transactions/transactions_state.dart';
import '../../models/transaction_day_group.dart';
import '../../widgets/categories/category_localization.dart';
import '../../widgets/categories/category_visual_registry.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_skeleton.dart';
import '../../widgets/privacy/financial_privacy.dart';
import '../../widgets/transactions/add_transaction_sheet.dart';
import '../../widgets/transactions/transaction_formatters.dart';
import '../../widgets/transactions/transaction_list_tile.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<TransactionsCubit, TransactionsState>(
      builder: (context, state) {
        if (state.status == TransactionsStatus.loading) {
          return const LoadingSkeleton();
        }
        if (!state.hasTransactions) {
          return EmptyState(
            icon: Icons.receipt_long_outlined,
            title: l10n.historyEmptyTitle,
            body: '${l10n.historyEmptyBody}\n${l10n.historyStartHint}',
          );
        }

        final categoriesById = {
          for (final category in state.categories) category.id: category,
        };
        final transactions = state.filteredTransactions;
        final groups = groupTransactionsByDay(
          transactions,
          localeName: l10n.localeName,
        );

        return LayoutBuilder(
          builder: (context, constraints) {
            final padding = responsivePagePadding(constraints);
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    padding.left,
                    AppSpacing.md,
                    padding.right,
                    AppSpacing.sm,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      l10n.historyTitle,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    padding.left,
                    0,
                    padding.right,
                    AppSpacing.sm,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: _TransactionFilters(state: state),
                  ),
                ),
                if (transactions.isEmpty)
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      padding.left,
                      AppSpacing.lg,
                      padding.right,
                      padding.bottom,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: EmptyState(
                        icon: Icons.manage_search_outlined,
                        title: l10n.transactionNoMatchesTitle,
                        body: l10n.transactionNoMatchesBody,
                      ),
                    ),
                  )
                else ...[
                  for (final group in groups) ...[
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        padding.left,
                        AppSpacing.sm,
                        padding.right,
                        AppSpacing.xs,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: Text(
                          group.dayLabel,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: padding.left),
                      sliver: SliverList.separated(
                        itemCount: group.transactions.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: AppSpacing.xs),
                        itemBuilder: (context, index) {
                          final transaction = group.transactions[index];
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                              ),
                              child: TransactionListTile(
                                transaction: transaction,
                                category:
                                    categoriesById[transaction.categoryId],
                                onTap: () => _showTransactionDetails(
                                  context,
                                  transaction,
                                  categoriesById[transaction.categoryId],
                                ),
                                onDelete: () => context
                                    .read<TransactionsCubit>()
                                    .delete(transaction.id),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  SliverToBoxAdapter(child: SizedBox(height: padding.bottom)),
                ],
              ],
            );
          },
        );
      },
    );
  }
}

class _TransactionFilters extends StatefulWidget {
  const _TransactionFilters({required this.state});

  final TransactionsState state;

  @override
  State<_TransactionFilters> createState() => _TransactionFiltersState();
}

class _TransactionFiltersState extends State<_TransactionFilters> {
  late final TextEditingController _searchController;
  late final TextEditingController _minAmountController;
  late final TextEditingController _maxAmountController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.state.filter.query);
    _minAmountController = TextEditingController(
      text: _amountText(widget.state.filter.minAmount),
    );
    _maxAmountController = TextEditingController(
      text: _amountText(widget.state.filter.maxAmount),
    );
  }

  @override
  void didUpdateWidget(covariant _TransactionFilters oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.filter.query != _searchController.text) {
      _searchController.text = widget.state.filter.query;
    }
    final minText = _amountText(widget.state.filter.minAmount);
    if (minText != _minAmountController.text) {
      _minAmountController.text = minText;
    }
    final maxText = _amountText(widget.state.filter.maxAmount);
    if (maxText != _maxAmountController.text) {
      _maxAmountController.text = maxText;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _minAmountController.dispose();
    _maxAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final filter = widget.state.filter;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            TextField(
              key: const ValueKey('transaction-search-field'),
              controller: _searchController,
              decoration: InputDecoration(
                labelText: l10n.transactionSearchLabel,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: filter.query.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          context.read<TransactionsCubit>().updateSearchQuery(
                            '',
                          );
                        },
                        icon: const Icon(Icons.clear),
                      ),
              ),
              onChanged: context.read<TransactionsCubit>().updateSearchQuery,
            ),
            const SizedBox(height: AppSpacing.sm),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text(l10n.transactionFiltersTitle),
              trailing: TextButton.icon(
                onPressed: context.read<TransactionsCubit>().clearFilters,
                icon: const Icon(Icons.filter_alt_off_outlined),
                label: Text(l10n.transactionClearFilters),
              ),
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= AppBreakpoints.desktop;
                    final controls = [
                      _TypeFilter(filter: filter),
                      _CategoryFilter(
                        filter: filter,
                        categories: widget.state.categories,
                      ),
                      _WalletFilter(filter: filter),
                    ];
                    if (!wide) {
                      return Column(
                        children: [
                          for (final control in controls) ...[
                            control,
                            if (control != controls.last)
                              const SizedBox(height: AppSpacing.xs),
                          ],
                        ],
                      );
                    }
                    return Row(
                      children: [
                        for (final control in controls) ...[
                          Expanded(child: control),
                          if (control != controls.last)
                            const SizedBox(width: AppSpacing.xs),
                        ],
                      ],
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.xs),
                _DateRangeFilter(filter: filter),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        key: const ValueKey('transaction-min-amount-field'),
                        controller: _minAmountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: l10n.transactionMinAmount,
                        ),
                        onChanged: (_) => _setAmountRange(context),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: TextField(
                        key: const ValueKey('transaction-max-amount-field'),
                        controller: _maxAmountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: l10n.transactionMaxAmount,
                        ),
                        onChanged: (_) => _setAmountRange(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.xs,
                  children: [
                    FilterChip(
                      label: Text(l10n.transactionWithPersonName),
                      selected: filter.hasPersonName == true,
                      onSelected: (selected) => context
                          .read<TransactionsCubit>()
                          .setHasPersonName(selected ? true : null),
                    ),
                    FilterChip(
                      label: Text(l10n.transactionWithNotes),
                      selected: filter.hasNote == true,
                      onSelected: (selected) => context
                          .read<TransactionsCubit>()
                          .setHasNote(selected ? true : null),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _setAmountRange(BuildContext context) {
    context.read<TransactionsCubit>().setAmountRange(
      minAmount: _parseAmount(_minAmountController.text),
      maxAmount: _parseAmount(_maxAmountController.text),
    );
  }
}

class _TypeFilter extends StatelessWidget {
  const _TypeFilter({required this.filter});

  final TransactionFilter filter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DropdownButtonFormField<String>(
      key: ValueKey('transaction-type-filter-${filter.type?.name ?? 'all'}'),
      initialValue: filter.type?.name ?? '',
      isExpanded: true,
      decoration: InputDecoration(labelText: l10n.transactionTypeLabel),
      items: [
        DropdownMenuItem(value: '', child: Text(l10n.transactionAllTypes)),
        for (final type in TransactionType.values)
          DropdownMenuItem(
            value: type.name,
            child: Text(localizedTransactionType(l10n, type)),
          ),
      ],
      onChanged: (value) => context.read<TransactionsCubit>().setTypeFilter(
        _transactionTypeFromName(value),
      ),
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  const _CategoryFilter({required this.filter, required this.categories});

  final TransactionFilter filter;
  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DropdownButtonFormField<String>(
      key: ValueKey(
        'transaction-category-filter-${filter.categoryId ?? 'all'}',
      ),
      initialValue: filter.categoryId ?? '',
      isExpanded: true,
      decoration: InputDecoration(labelText: l10n.transactionCategoryLabel),
      items: [
        DropdownMenuItem(value: '', child: Text(l10n.transactionAllCategories)),
        for (final category in categories)
          DropdownMenuItem(
            value: category.id,
            child: Text(localizedCategoryName(l10n, category)),
          ),
      ],
      onChanged: (value) => context.read<TransactionsCubit>().setCategoryFilter(
        value == null || value.isEmpty ? null : value,
      ),
    );
  }
}

class _WalletFilter extends StatelessWidget {
  const _WalletFilter({required this.filter});

  final TransactionFilter filter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DropdownButtonFormField<String>(
      key: ValueKey(
        'transaction-wallet-filter-${filter.wallet?.name ?? 'all'}',
      ),
      initialValue: filter.wallet?.name ?? '',
      isExpanded: true,
      decoration: InputDecoration(labelText: l10n.transactionWalletLabel),
      items: [
        DropdownMenuItem(value: '', child: Text(l10n.transactionAllWallets)),
        for (final wallet in WalletType.values)
          DropdownMenuItem(
            value: wallet.name,
            child: Text(localizedWalletName(l10n, wallet)),
          ),
      ],
      onChanged: (value) => context.read<TransactionsCubit>().setWalletFilter(
        _walletFromName(value),
      ),
    );
  }
}

class _DateRangeFilter extends StatelessWidget {
  const _DateRangeFilter({required this.filter});

  final TransactionFilter filter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasRange = filter.startDate != null || filter.endDate != null;
    final label = hasRange
        ? [
            if (filter.startDate != null)
              formatShortDate(filter.startDate!, localeName: l10n.localeName),
            if (filter.endDate != null)
              formatShortDate(filter.endDate!, localeName: l10n.localeName),
          ].join(' - ')
        : l10n.transactionDateRange;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _pickRange(context),
            icon: const Icon(Icons.date_range_outlined),
            label: Text(label),
          ),
        ),
        if (hasRange) ...[
          const SizedBox(width: AppSpacing.xs),
          IconButton(
            onPressed: () => context.read<TransactionsCubit>().setDateRange(),
            icon: const Icon(Icons.clear),
          ),
        ],
      ],
    );
  }

  Future<void> _pickRange(BuildContext context) async {
    final now = DateTime.now();
    final selected = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1, 12, 31),
      initialDateRange: filter.startDate == null || filter.endDate == null
          ? null
          : DateTimeRange(start: filter.startDate!, end: filter.endDate!),
    );
    if (selected == null || !context.mounted) {
      return;
    }
    context.read<TransactionsCubit>().setDateRange(
      startDate: selected.start,
      endDate: selected.end,
    );
  }
}

class _TransactionDetailsSheet extends StatelessWidget {
  const _TransactionDetailsSheet({
    required this.parentContext,
    required this.transaction,
    required this.category,
  });

  final BuildContext parentContext;
  final FinancialTransaction transaction;
  final Category? category;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final categoryName = category == null
        ? l10n.unknownCategory
        : localizedCategoryName(l10n, category!);
    final obscureAmount = financialAmountsObscured(context);
    final colors = Theme.of(context).extension<MasrofyThemeExtension>()!;
    final amountColor = transaction.type == TransactionType.expense
        ? colors.expense
        : colors.income;
    final categoryColor = category == null
        ? Theme.of(context).colorScheme.primary
        : Color(category!.colorValue);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.transactionDetailsTitle,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.14),
                    borderRadius: AppRadii.card,
                  ),
                  child: SizedBox.square(
                    dimension: 52,
                    child: Icon(
                      category == null
                          ? Icons.category_outlined
                          : categoryIconFor(category!.iconKey),
                      color: categoryColor,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        categoryName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        localizedTransactionType(l10n, transaction.type),
                        style: Theme.of(
                          context,
                        ).textTheme.labelLarge?.copyWith(color: amountColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              formatTransactionAmount(
                transaction,
                localeName: l10n.localeName,
                currencySymbol: l10n.currencySymbol,
                obscure: obscureAmount,
              ),
              textDirection: TextDirection.ltr,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: amountColor,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    _DetailRow(
                      label: l10n.transactionDateLabel,
                      value: formatDay(
                        transaction.date,
                        localeName: l10n.localeName,
                      ),
                    ),
                    if (transaction.wallet != null)
                      _DetailRow(
                        label: l10n.transactionWalletLabel,
                        value: localizedWalletName(l10n, transaction.wallet!),
                      ),
                    if (transaction.personName?.trim().isNotEmpty ?? false)
                      _DetailRow(
                        label: l10n.transactionPersonLabel,
                        value: transaction.personName!,
                      ),
                    if (transaction.note?.trim().isNotEmpty ?? false)
                      _DetailRow(
                        label: l10n.transactionNoteLabel,
                        value: transaction.note!,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showEditTransaction(parentContext, transaction);
                    },
                    icon: const Icon(Icons.edit_outlined),
                    label: Text(l10n.editTransactionTitle),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _confirmDelete(context, l10n),
                    icon: const Icon(Icons.delete_outline),
                    label: Text(l10n.transactionDeleteTooltip),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    AppLocalizations localizations,
  ) async {
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
    if (confirmed != true || !context.mounted) {
      return;
    }
    Navigator.of(context).pop();
    parentContext.read<TransactionsCubit>().delete(transaction.id);
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: Theme.of(context).textTheme.labelLarge),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

Future<void> _showTransactionDetails(
  BuildContext context,
  FinancialTransaction transaction,
  Category? category,
) {
  final cubit = context.read<TransactionsCubit>();
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (sheetContext) => BlocProvider.value(
      value: cubit,
      child: _TransactionDetailsSheet(
        parentContext: context,
        transaction: transaction,
        category: category,
      ),
    ),
  );
}

Future<void> _showEditTransaction(
  BuildContext context,
  FinancialTransaction transaction,
) {
  final cubit = context.read<TransactionsCubit>();
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (sheetContext) => BlocProvider.value(
      value: cubit,
      child: AddTransactionSheet(initialTransaction: transaction),
    ),
  );
}

TransactionType? _transactionTypeFromName(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  for (final type in TransactionType.values) {
    if (type.name == value) {
      return type;
    }
  }
  return null;
}

WalletType? _walletFromName(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  for (final wallet in WalletType.values) {
    if (wallet.name == value) {
      return wallet;
    }
  }
  return null;
}

double? _parseAmount(String? value) {
  if (value == null) {
    return null;
  }
  return double.tryParse(value.replaceAll(',', '.').trim());
}

String _amountText(double? value) {
  if (value == null) {
    return '';
  }
  return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2);
}
