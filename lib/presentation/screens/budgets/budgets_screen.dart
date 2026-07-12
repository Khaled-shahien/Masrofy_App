import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../../../core/theme/masrofy_theme_extension.dart';
import '../../../domain/entities/budget.dart';
import '../../../domain/entities/budget_progress.dart';
import '../../../domain/entities/category.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../cubits/budgets/budgets_cubit.dart';
import '../../cubits/budgets/budgets_state.dart';
import '../../widgets/categories/category_localization.dart';
import '../../widgets/categories/category_visual_registry.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_skeleton.dart';
import '../../widgets/privacy/financial_privacy.dart';
import '../../widgets/transactions/transaction_formatters.dart';

class BudgetsScreen extends StatelessWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return BlocConsumer<BudgetsCubit, BudgetsState>(
      listenWhen: (previous, current) =>
          previous.failure != current.failure && current.failure != null,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_failureMessage(localizations, state))),
        );
      },
      builder: (context, state) {
        return switch (state.status) {
          BudgetsStatus.initial || BudgetsStatus.loading
              when state.progress.isEmpty =>
            const LoadingSkeleton(),
          BudgetsStatus.failure when state.progress.isEmpty =>
            _BudgetsErrorBody(onRetry: context.read<BudgetsCubit>().retry),
          _ => _BudgetsBody(state: state),
        };
      },
    );
  }
}

class _BudgetsBody extends StatelessWidget {
  const _BudgetsBody({required this.state});

  final BudgetsState state;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final padding = responsivePagePadding(constraints);
        final categoriesById = {
          for (final category in state.categories) category.id: category,
        };

        return RefreshIndicator(
          onRefresh: () async => context.read<BudgetsCubit>().load(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  padding.left,
                  AppSpacing.md,
                  padding.right,
                  AppSpacing.xs,
                ),
                sliver: SliverToBoxAdapter(
                  child: _BudgetMonthHeader(state: state),
                ),
              ),
              if (state.isSaving)
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: padding.left),
                  sliver: const SliverToBoxAdapter(
                    child: LinearProgressIndicator(minHeight: 2),
                  ),
                ),
              if (!state.hasProgress)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: Icons.savings_outlined,
                    title: AppLocalizations.of(context).budgetsEmptyTitle,
                    body: AppLocalizations.of(context).budgetsEmptyBody,
                    action: FilledButton.icon(
                      key: const ValueKey('add-budget-empty-button'),
                      onPressed: () => _showBudgetEditor(context, state),
                      icon: const Icon(Icons.add),
                      label: Text(AppLocalizations.of(context).addBudget),
                    ),
                  ),
                )
              else ...[
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    padding.left,
                    AppSpacing.sm,
                    padding.right,
                    0,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: _BudgetSummaryCard(progress: state.progress),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    padding.left,
                    AppSpacing.sm,
                    padding.right,
                    padding.bottom,
                  ),
                  sliver: SliverList.separated(
                    itemCount: state.progress.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppSpacing.xs),
                    itemBuilder: (context, index) {
                      final progress = state.progress[index];
                      return _BudgetCard(
                        progress: progress,
                        category: categoriesById[progress.budget.categoryId],
                        categories: state.categories,
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _BudgetSummaryCard extends StatelessWidget {
  const _BudgetSummaryCard({required this.progress});

  final List<BudgetProgress> progress;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final colors = Theme.of(context).extension<MasrofyThemeExtension>()!;
    final obscureAmounts = financialAmountsObscured(context);
    final totalBudget = progress.fold<double>(
      0,
      (sum, item) => sum + item.budget.amount,
    );
    final totalSpent = progress.fold<double>(
      0,
      (sum, item) => sum + item.spentAmount,
    );
    final totalRemaining = totalBudget - totalSpent;
    final ratio = totalBudget <= 0 ? 0.0 : (totalSpent / totalBudget);
    final statusColor = ratio >= 1
        ? colors.budgetExceeded
        : ratio >= 0.8
        ? colors.budgetWarning
        : colors.budgetSafe;

    return Card(
      color: colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.monthlyBudget,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TweenAnimationBuilder<double>(
              duration: AppDurations.standard,
              curve: AppCurves.standard,
              tween: Tween<double>(begin: 0, end: ratio.clamp(0, 1)),
              builder: (context, value, child) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 10,
                  color: statusColor,
                  backgroundColor: colorScheme.surface.withValues(alpha: 0.5),
                  borderRadius: AppRadii.pill,
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.lg,
              runSpacing: AppSpacing.sm,
              children: [
                _BudgetAmount(
                  label: localizations.budget,
                  value: _money(localizations, totalBudget, obscureAmounts),
                ),
                _BudgetAmount(
                  label: localizations.budgetSpent,
                  value: _money(localizations, totalSpent, obscureAmounts),
                ),
                _BudgetAmount(
                  label: localizations.budgetRemaining,
                  value: _money(
                    localizations,
                    totalRemaining,
                    obscureAmounts,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetMonthHeader extends StatelessWidget {
  const _BudgetMonthHeader({required this.state});

  final BudgetsState state;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final monthName = DateFormat.yMMMM(
      localizations.localeName,
    ).format(state.selectedPeriod.start);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final title = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.monthlyBudget,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  localizations.budgetMonthLabel(monthName),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            );
            final controls = Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                IconButton(
                  key: const ValueKey('budget-previous-month'),
                  tooltip: localizations.budgetPreviousMonth,
                  onPressed: context.read<BudgetsCubit>().previousMonth,
                  icon: const Icon(Icons.chevron_left),
                ),
                IconButton(
                  key: const ValueKey('budget-next-month'),
                  tooltip: localizations.budgetNextMonth,
                  onPressed: context.read<BudgetsCubit>().nextMonth,
                  icon: const Icon(Icons.chevron_right),
                ),
                FilledButton.icon(
                  key: const ValueKey('add-budget-button'),
                  onPressed: state.isSaving
                      ? null
                      : () => _showBudgetEditor(context, state),
                  icon: const Icon(Icons.add),
                  label: Text(localizations.addBudget),
                ),
              ],
            );

            if (constraints.maxWidth < 520) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  title,
                  const SizedBox(height: AppSpacing.md),
                  controls,
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: title),
                const SizedBox(width: AppSpacing.md),
                controls,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({
    required this.progress,
    required this.category,
    required this.categories,
  });

  final BudgetProgress progress;
  final Category? category;
  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final categoryName = category == null
        ? localizations.budgetCategoryUnavailable
        : localizedCategoryName(localizations, category!);
    final statusColor = _statusColor(context, progress.status);
    final statusLabel = _statusLabel(localizations, progress.status);
    final ratio = progress.progressRatio.clamp(0.0, 1.0).toDouble();
    final categoryColor = category == null
        ? colorScheme.primary
        : Color(category!.colorValue);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: categoryColor.withValues(alpha: 0.16),
                  foregroundColor: categoryColor,
                  child: Icon(categoryIconFor(category?.iconKey ?? 'category')),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        categoryName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (category?.isHidden ?? false)
                        Text(
                          localizations.budgetHiddenCategory,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  key: ValueKey('budget-edit-${progress.budget.id}'),
                  tooltip: localizations.editBudget,
                  onPressed: () => _showBudgetEditor(
                    context,
                    context.read<BudgetsCubit>().state,
                    budget: progress.budget,
                  ),
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  key: ValueKey('budget-delete-${progress.budget.id}'),
                  tooltip: localizations.deleteBudget,
                  onPressed: () => _confirmDelete(
                    context,
                    progress.budget,
                    categoryName,
                  ),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Semantics(
              label: localizations.budgetProgressSemantics(
                categoryName,
                progress.progressPercentage,
              ),
              child: TweenAnimationBuilder<double>(
                duration: AppDurations.standard,
                curve: AppCurves.standard,
                tween: Tween<double>(begin: 0, end: ratio),
                builder: (context, value, child) {
                  return LinearProgressIndicator(
                    value: value,
                    minHeight: 8,
                    color: statusColor,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    borderRadius: AppRadii.pill,
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _BudgetAmounts(progress: progress),
            const SizedBox(height: AppSpacing.sm),
            _BudgetStatusChip(label: statusLabel, color: statusColor),
            if (progress.budget.note != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                progress.budget.note!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    Budget budget,
    String categoryName,
  ) async {
    final localizations = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(localizations.deleteBudget),
        content: Text(localizations.budgetDeleteConfirmation(categoryName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(localizations.commonCancel),
          ),
          FilledButton(
            key: const ValueKey('confirm-delete-budget'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(localizations.commonDelete),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) {
      return;
    }
    await context.read<BudgetsCubit>().delete(budget.id);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(localizations.budgetDeletedMessage)),
    );
  }
}

class _BudgetAmounts extends StatelessWidget {
  const _BudgetAmounts({required this.progress});

  final BudgetProgress progress;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final obscureAmounts = financialAmountsObscured(context);
    final budget = formatMoney(
      progress.budget.amount,
      localeName: localizations.localeName,
      currencySymbol: localizations.currencySymbol,
      obscure: obscureAmounts,
    );
    final spent = formatMoney(
      progress.spentAmount,
      localeName: localizations.localeName,
      currencySymbol: localizations.currencySymbol,
      obscure: obscureAmounts,
    );
    final remaining = formatMoney(
      progress.remainingAmount,
      localeName: localizations.localeName,
      currencySymbol: localizations.currencySymbol,
      obscure: obscureAmounts,
    );

    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.xs,
      children: [
        _BudgetAmount(label: localizations.budget, value: budget),
        _BudgetAmount(label: localizations.budgetSpent, value: spent),
        _BudgetAmount(label: localizations.budgetRemaining, value: remaining),
      ],
    );
  }
}

class _BudgetAmount extends StatelessWidget {
  const _BudgetAmount({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: AppSpacing.xxs),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

class _BudgetStatusChip extends StatelessWidget {
  const _BudgetStatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: AppRadii.pill,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _BudgetEditorSheet extends StatefulWidget {
  const _BudgetEditorSheet({
    required this.state,
    this.budget,
  });

  final BudgetsState state;
  final Budget? budget;

  @override
  State<_BudgetEditorSheet> createState() => _BudgetEditorSheetState();
}

class _BudgetEditorSheetState extends State<_BudgetEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  String? _categoryId;

  @override
  void initState() {
    super.initState();
    _categoryId = widget.budget?.categoryId;
    _amountController = TextEditingController(
      text: widget.budget?.amount.toStringAsFixed(0) ?? '',
    );
    _noteController = TextEditingController(text: widget.budget?.note ?? '');
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final categories = _editorCategories(widget.state, widget.budget);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.md,
          top: AppSpacing.md,
          right: AppSpacing.md,
          bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.md,
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            key: const ValueKey('budget-editor-sheet'),
            shrinkWrap: true,
            children: [
              Text(
                widget.budget == null
                    ? localizations.addBudget
                    : localizations.editBudget,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              if (categories.isEmpty)
                Text(localizations.budgetNoExpenseCategories)
              else
                DropdownButtonFormField<String>(
                  key: const ValueKey('budget-category-field'),
                  initialValue: _categoryId,
                  decoration: InputDecoration(
                    labelText: localizations.budgetCategoryLabel,
                    prefixIcon: const Icon(Icons.category_outlined),
                  ),
                  items: [
                    for (final category in categories)
                      DropdownMenuItem(
                        value: category.id,
                        child: Text(
                          localizedCategoryName(
                            localizations,
                            category,
                          ),
                        ),
                      ),
                  ],
                  validator: (value) => value == null
                      ? localizations.budgetCategoryRequired
                      : null,
                  onChanged: (value) => setState(() => _categoryId = value),
                ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                key: const ValueKey('budget-amount-field'),
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: localizations.budgetAmountLabel,
                  prefixIcon: const Icon(Icons.payments_outlined),
                ),
                validator: (value) {
                  final amount = _parseAmount(value);
                  if (amount == null || amount <= 0) {
                    return localizations.budgetAmountRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                key: const ValueKey('budget-note-field'),
                controller: _noteController,
                minLines: 1,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: localizations.budgetNoteLabel,
                  prefixIcon: const Icon(Icons.notes_outlined),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(localizations.commonCancel),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: FilledButton(
                      key: const ValueKey('budget-editor-save'),
                      onPressed: categories.isEmpty ? null : _save,
                      child: Text(localizations.commonSave),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final categoryId = _categoryId;
    final amount = _parseAmount(_amountController.text);
    if (categoryId == null || amount == null) {
      return;
    }

    final saved = await context.read<BudgetsCubit>().save(
      id: widget.budget?.id,
      categoryId: categoryId,
      amount: amount,
      note: _noteController.text,
    );
    if (!saved || !mounted) {
      return;
    }
    final localizations = AppLocalizations.of(context);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(localizations.budgetSavedMessage)),
    );
  }
}

class _BudgetsErrorBody extends StatelessWidget {
  const _BudgetsErrorBody({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return EmptyState(
      icon: Icons.savings_outlined,
      title: localizations.budgetsLoadError,
      body: localizations.budgetsLoadErrorBody,
      action: FilledButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh),
        label: Text(localizations.commonRetry),
      ),
    );
  }
}

Future<void> _showBudgetEditor(
  BuildContext context,
  BudgetsState state, {
  Budget? budget,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) => BlocProvider.value(
      value: context.read<BudgetsCubit>(),
      child: _BudgetEditorSheet(state: state, budget: budget),
    ),
  );
}

List<Category> _editorCategories(BudgetsState state, Budget? budget) {
  return state.categories
      .where(
        (category) => !category.isHidden || category.id == budget?.categoryId,
      )
      .toList(growable: false);
}

String _failureMessage(AppLocalizations localizations, BudgetsState state) {
  return switch (state.failure) {
    BudgetsFailure.validation => localizations.budgetAmountRequired,
    BudgetsFailure.duplicate => localizations.budgetDuplicateValidation,
    BudgetsFailure.invalidCategory =>
      localizations.budgetExpenseCategoryValidation,
    BudgetsFailure.storage => localizations.budgetsLoadError,
    null => localizations.budgetsLoadError,
  };
}

String _statusLabel(AppLocalizations localizations, BudgetStatus status) {
  return switch (status) {
    BudgetStatus.safe => localizations.budgetSafe,
    BudgetStatus.approaching => localizations.budgetApproachingLimit,
    BudgetStatus.exceeded => localizations.budgetExceeded,
  };
}

Color _statusColor(BuildContext context, BudgetStatus status) {
  final colors = Theme.of(context).extension<MasrofyThemeExtension>()!;
  return switch (status) {
    BudgetStatus.safe => colors.budgetSafe,
    BudgetStatus.approaching => colors.budgetWarning,
    BudgetStatus.exceeded => colors.budgetExceeded,
  };
}

String _money(
  AppLocalizations localizations,
  double value,
  bool obscureAmounts,
) {
  return formatMoney(
    value,
    localeName: localizations.localeName,
    currencySymbol: localizations.currencySymbol,
    obscure: obscureAmounts,
  );
}

double? _parseAmount(String? value) {
  if (value == null) {
    return null;
  }
  return double.tryParse(value.replaceAll(',', '.').trim());
}
