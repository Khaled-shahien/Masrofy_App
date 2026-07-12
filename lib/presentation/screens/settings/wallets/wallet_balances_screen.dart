import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_design_tokens.dart';
import '../../../../core/theme/masrofy_theme_extension.dart';
import '../../../../domain/entities/wallet_balance_summary.dart';
import '../../../../domain/entities/wallet_type.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../cubits/wallets/wallet_balances_cubit.dart';
import '../../../cubits/wallets/wallet_balances_state.dart';
import '../../../widgets/categories/category_localization.dart';
import '../../../widgets/loading_skeleton.dart';
import '../../../widgets/privacy/financial_privacy.dart';
import '../../../widgets/transactions/transaction_formatters.dart';

class WalletBalancesScreen extends StatelessWidget {
  const WalletBalancesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return BlocConsumer<WalletBalancesCubit, WalletBalancesState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage &&
          current.errorMessage != null,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.errorMessage!)),
        );
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text(localizations.walletBalancesTitle)),
          body: switch (state.status) {
            WalletBalancesStatus.initial || WalletBalancesStatus.loading
                when state.summaries.isEmpty =>
              const LoadingSkeleton(itemCount: 2),
            WalletBalancesStatus.failure when state.summaries.isEmpty =>
              _WalletBalancesErrorBody(
                onRetry: context.read<WalletBalancesCubit>().load,
              ),
            _ => _WalletBalancesBody(state: state),
          },
        );
      },
    );
  }
}

class _WalletBalancesBody extends StatelessWidget {
  const _WalletBalancesBody({required this.state});

  final WalletBalancesState state;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final padding = responsivePagePadding(constraints);
        final sidePadding = padding.left;

        return RefreshIndicator(
          onRefresh: () async => context.read<WalletBalancesCubit>().load(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  sidePadding,
                  AppSpacing.md,
                  sidePadding,
                  AppSpacing.xs,
                ),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    localizations.walletBalancesIntro,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              if (state.isSaving)
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    sidePadding,
                    AppSpacing.xs,
                    sidePadding,
                    0,
                  ),
                  sliver: const SliverToBoxAdapter(
                    child: LinearProgressIndicator(minHeight: 2),
                  ),
                ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  sidePadding,
                  AppSpacing.sm,
                  sidePadding,
                  padding.bottom,
                ),
                sliver: SliverList.separated(
                  itemCount: state.summaries.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppSpacing.xs),
                  itemBuilder: (context, index) {
                    return _WalletBalanceCard(
                      summary: state.summaries[index],
                      isSaving: state.isSaving,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WalletBalanceCard extends StatelessWidget {
  const _WalletBalanceCard({
    required this.summary,
    required this.isSaving,
  });

  final WalletBalanceSummary summary;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final walletColor = _walletColor(context, summary.walletType);
    final obscureAmounts = financialAmountsObscured(context);
    final currentBalance = formatMoney(
      summary.currentBalance,
      localeName: localizations.localeName,
      currencySymbol: localizations.currencySymbol,
      obscure: obscureAmounts,
    );
    final transactionNet = formatMoney(
      summary.transactionNet,
      localeName: localizations.localeName,
      currencySymbol: localizations.currencySymbol,
      obscure: obscureAmounts,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final header = Row(
              children: [
                CircleAvatar(
                  backgroundColor: walletColor.withValues(alpha: 0.14),
                  foregroundColor: walletColor,
                  child: Icon(_walletIcon(summary.walletType)),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizedWalletName(localizations, summary.walletType),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        localizations.walletTransactionNet(transactionNet),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
            final balance = _WalletBalanceAmount(
              currentBalance: currentBalance,
              onPressed: isSaving
                  ? null
                  : () => _editCurrentBalance(context, summary),
            );
            if (constraints.maxWidth < 430) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  header,
                  const SizedBox(height: AppSpacing.md),
                  balance,
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: header),
                const SizedBox(width: AppSpacing.md),
                balance,
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _editCurrentBalance(
    BuildContext context,
    WalletBalanceSummary summary,
  ) async {
    final localizations = AppLocalizations.of(context);
    final cubit = context.read<WalletBalancesCubit>();

    final result = await showDialog<double>(
      context: context,
      builder: (dialogContext) => _WalletBalanceDialog(
        walletName: localizedWalletName(localizations, summary.walletType),
        initialBalance: summary.currentBalance,
      ),
    );

    if (result == null) {
      return;
    }

    await cubit.setCurrentBalance(
      walletType: summary.walletType,
      currentBalance: result,
    );
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(localizations.walletBalanceSavedMessage)),
    );
  }
}

class _WalletBalanceAmount extends StatelessWidget {
  const _WalletBalanceAmount({
    required this.currentBalance,
    required this.onPressed,
  });

  final String currentBalance;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AnimatedSwitcher(
          duration: AppDurations.standard,
          switchInCurve: AppCurves.standard,
          child: Text(
            currentBalance,
            key: ValueKey(currentBalance),
            textDirection: TextDirection.ltr,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        TextButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.edit_outlined),
          label: Text(localizations.walletBalanceEditAction),
        ),
      ],
    );
  }
}

class _WalletBalanceDialog extends StatefulWidget {
  const _WalletBalanceDialog({
    required this.walletName,
    required this.initialBalance,
  });

  final String walletName;
  final double initialBalance;

  @override
  State<_WalletBalanceDialog> createState() => _WalletBalanceDialogState();
}

class _WalletBalanceDialogState extends State<_WalletBalanceDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialBalance.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(localizations.walletBalanceDialogTitle(widget.walletName)),
      content: Form(
        key: _formKey,
        child: TextFormField(
          key: const ValueKey('wallet-current-balance-field'),
          controller: _controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
          ),
          decoration: InputDecoration(
            labelText: localizations.walletCurrentBalanceLabel,
            prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
          ),
          validator: (value) {
            final amount = _parseAmount(value);
            if (amount == null || amount < 0) {
              return localizations.walletCurrentBalanceRequired;
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(localizations.commonCancel),
        ),
        FilledButton(
          key: const ValueKey('wallet-current-balance-save'),
          onPressed: () {
            if (!_formKey.currentState!.validate()) {
              return;
            }
            Navigator.of(context).pop(_parseAmount(_controller.text));
          },
          child: Text(localizations.commonSave),
        ),
      ],
    );
  }
}

class _WalletBalancesErrorBody extends StatelessWidget {
  const _WalletBalancesErrorBody({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.account_balance_wallet_outlined,
              size: AppIconSizes.empty,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              localizations.walletBalancesLoadError,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(localizations.commonRetry),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _walletIcon(WalletType walletType) {
  return switch (walletType) {
    WalletType.instaPay => Icons.account_balance_outlined,
    WalletType.vodafoneCash => Icons.phone_android_outlined,
    WalletType.cash => Icons.payments_outlined,
  };
}

Color _walletColor(BuildContext context, WalletType walletType) {
  final colors = Theme.of(context).extension<MasrofyThemeExtension>()!;
  return switch (walletType) {
    WalletType.instaPay => colors.info,
    WalletType.vodafoneCash => colors.savings,
    WalletType.cash => colors.warning,
  };
}

double? _parseAmount(String? value) {
  if (value == null) {
    return null;
  }
  return double.tryParse(value.replaceAll(',', '.').trim());
}
