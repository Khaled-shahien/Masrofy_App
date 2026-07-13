import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/financial_transaction.dart';
import '../../../domain/entities/transaction_type.dart';
import '../../../domain/entities/wallet_type.dart';
import '../../../domain/usecases/transactions/save_transaction.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../cubits/transactions/transactions_cubit.dart';
import '../../cubits/transactions/transactions_state.dart';
import '../categories/category_localization.dart';
import '../categories/category_visual_registry.dart';
import 'transaction_formatters.dart';

class AddTransactionSheet extends StatefulWidget {
  const AddTransactionSheet({
    this.initialTransaction,
    super.key,
  });

  final FinancialTransaction? initialTransaction;

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _personController = TextEditingController();

  TransactionType _type = TransactionType.expense;
  String? _categoryId;
  WalletType? _wallet = WalletType.cash;
  DateTime _date = DateTime.now();

  bool get _isEditing => widget.initialTransaction != null;

  @override
  void initState() {
    super.initState();
    final transaction = widget.initialTransaction;
    if (transaction == null) {
      return;
    }
    _amountController.text = transaction.amount.toStringAsFixed(0);
    _noteController.text = transaction.note ?? '';
    _personController.text = transaction.personName ?? '';
    _type = transaction.type;
    _categoryId = transaction.categoryId;
    _wallet = transaction.wallet ?? WalletType.cash;
    _date = transaction.date;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _personController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TransactionsCubit, TransactionsState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage &&
          current.errorMessage != null,
      listener: (context, state) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _localizedTransactionError(l10n, state.errorMessage!),
            ),
          ),
        );
      },
      builder: (context, state) {
        final l10n = AppLocalizations.of(context);
        final categories = state.categories
            .where(
              (category) =>
                  category.type == _type &&
                  (!category.isHidden ||
                      category.id == widget.initialTransaction?.categoryId),
            )
            .toList(growable: false);
        if (_categoryId == null && categories.isNotEmpty) {
          _categoryId = categories.first.id;
        }
        final selectedCategory = _selectedCategory(categories);

        return SafeArea(
          child: AnimatedPadding(
            duration: AppDurations.fast,
            curve: AppCurves.standard,
            padding: EdgeInsetsDirectional.only(
              start: AppSpacing.md,
              end: AppSpacing.md,
              top: AppSpacing.xs,
              bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.md,
            ),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.86,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _isEditing
                                ? l10n.editTransactionTitle
                                : l10n.addTransactionTitle,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        IconButton(
                          tooltip: MaterialLocalizations.of(
                            context,
                          ).closeButtonTooltip,
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SegmentedButton<TransactionType>(
                              segments: [
                                ButtonSegment(
                                  value: TransactionType.expense,
                                  icon: const Icon(Icons.arrow_downward),
                                  label: Text(
                                    l10n.transactionTypeExpenseForm,
                                  ),
                                ),
                                ButtonSegment(
                                  value: TransactionType.income,
                                  icon: const Icon(Icons.arrow_upward),
                                  label: Text(l10n.transactionTypeIncomeForm),
                                ),
                              ],
                              selected: {_type},
                              onSelectionChanged: (selection) {
                                setState(() {
                                  _type = selection.first;
                                  _categoryId = null;
                                });
                              },
                            ),
                            const SizedBox(height: AppSpacing.md),
                            TextFormField(
                              key: const ValueKey('transaction_amount_field'),
                              controller: _amountController,
                              textDirection: TextDirection.ltr,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.payments_outlined),
                                suffixText: l10n.currencySymbol,
                                labelText: l10n.transactionAmountLabel,
                              ),
                              validator: (value) {
                                final amount = _parseAmount(value);
                                if (amount == null || amount <= 0) {
                                  return l10n.transactionAmountRequired;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSpacing.md),
                            DropdownButtonFormField<String>(
                              key: const ValueKey(
                                'transaction_category_field',
                              ),
                              isExpanded: true,
                              initialValue:
                                  categories.any(
                                    (category) => category.id == _categoryId,
                                  )
                                  ? _categoryId
                                  : null,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.category_outlined,
                                ),
                                labelText: l10n.transactionCategoryLabel,
                              ),
                              items: [
                                for (final category in categories)
                                  DropdownMenuItem(
                                    value: category.id,
                                    child: _CategoryOption(category: category),
                                  ),
                              ],
                              onChanged: (value) =>
                                  setState(() => _categoryId = value),
                              validator: (value) => value == null
                                  ? l10n.transactionCategoryRequired
                                  : null,
                            ),
                            if (selectedCategory?.behavior ==
                                CategoryBehavior.personTransfer) ...[
                              const SizedBox(height: AppSpacing.md),
                              AnimatedSwitcher(
                                duration: AppDurations.standard,
                                child: TextFormField(
                                  key: const ValueKey(
                                    'transaction-person-field',
                                  ),
                                  controller: _personController,
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(
                                      Icons.person_outline,
                                    ),
                                    labelText: l10n.transactionPersonLabel,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: AppSpacing.md),
                            _WalletChoiceGroup(
                              selectedWallet: _wallet ?? WalletType.cash,
                              onChanged: (value) =>
                                  setState(() => _wallet = value),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            TextFormField(
                              controller: _noteController,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.notes_outlined),
                                labelText: l10n.transactionNoteLabel,
                              ),
                              maxLines: 2,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            OutlinedButton.icon(
                              onPressed: _pickDate,
                              icon: const Icon(Icons.calendar_month_outlined),
                              label: Text(
                                formatDay(
                                  _date,
                                  localeName: l10n.localeName,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    FilledButton.icon(
                      key: const ValueKey('save_transaction_button'),
                      onPressed: state.isSaving ? null : _save,
                      icon: AnimatedSwitcher(
                        duration: AppDurations.fast,
                        child: state.isSaving
                            ? const SizedBox.square(
                                key: ValueKey('saving'),
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.check, key: ValueKey('check')),
                      ),
                      label: Text(
                        _isEditing
                            ? l10n.updateTransaction
                            : l10n.saveTransaction,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Category? _selectedCategory(List<Category> categories) {
    for (final category in categories) {
      if (category.id == _categoryId) {
        return category;
      }
    }
    return null;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final saved = await context.read<TransactionsCubit>().save(
      SaveTransactionInput(
        id: widget.initialTransaction?.id,
        type: _type,
        amount: _parseAmount(_amountController.text)!,
        categoryId: _categoryId!,
        date: _date,
        createdAt: widget.initialTransaction?.createdAt,
        note: _noteController.text,
        wallet: _wallet,
        personName: _personController.text,
      ),
    );
    if (saved && mounted) {
      final l10n = AppLocalizations.of(context);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? l10n.transactionUpdatedMessage
                : l10n.transactionSavedMessage,
          ),
        ),
      );
    }
  }
}

String _localizedTransactionError(AppLocalizations l10n, String error) {
  return switch (error) {
    'invalidAmount' => l10n.transactionAmountRequired,
    'missingCategory' => l10n.transactionCategoryRequired,
    'unknownCategory' => l10n.transactionUnknownCategoryValidation,
    'categoryTypeMismatch' => l10n.transactionCategoryTypeValidation,
    _ => error,
  };
}

class _CategoryOption extends StatelessWidget {
  const _CategoryOption({required this.category});

  final Category category;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Row(
      children: [
        Icon(
          categoryIconFor(category.iconKey),
          color: Color(category.colorValue),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            localizedCategoryName(localizations, category),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _WalletChoiceGroup extends StatelessWidget {
  const _WalletChoiceGroup({
    required this.selectedWallet,
    required this.onChanged,
  });

  final WalletType selectedWallet;
  final ValueChanged<WalletType> onChanged;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final wallets = WalletType.values;

    return InputDecorator(
      decoration: InputDecoration(
        labelText: localizations.transactionWalletLabel,
        prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
      ),
      child: Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        children: [
          for (final wallet in wallets)
            ChoiceChip(
              label: Text(localizedWalletName(localizations, wallet)),
              selected: selectedWallet == wallet,
              onSelected: (_) => onChanged(wallet),
            ),
        ],
      ),
    );
  }
}

double? _parseAmount(String? value) {
  if (value == null) {
    return null;
  }
  return double.tryParse(value.replaceAll(',', '.').trim());
}
