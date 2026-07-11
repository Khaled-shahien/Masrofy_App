import 'package:flutter/material.dart';

import '../../../domain/entities/wallet_type.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'category_localization.dart';

/// Displays one category and its day-to-day management controls.
class CategoryCard extends StatelessWidget {
  const CategoryCard({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.isHidden,
    required this.defaultWallet,
    required this.onVisibilityChanged,
    required this.onDefaultWalletChanged,
    this.onEdit,
    this.isSaving = false,
    super.key,
  });

  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final bool isHidden;
  final WalletType? defaultWallet;
  final ValueChanged<bool> onVisibilityChanged;
  final ValueChanged<WalletType?> onDefaultWalletChanged;
  final VoidCallback? onEdit;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      key: ValueKey('category-card-$id'),
      clipBehavior: Clip.antiAlias,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: isHidden ? 0.62 : 1,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _CategoryIcon(icon: icon, color: color),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _CategoryTitle(
                      name: name,
                      isHidden: isHidden,
                    ),
                  ),
                  if (onEdit != null)
                    IconButton(
                      key: ValueKey('category-edit-$id'),
                      tooltip: localizations.editCategoryLabel(name),
                      onPressed: isSaving ? null : onEdit,
                      icon: const Icon(Icons.edit_outlined),
                    ),
                  Semantics(
                    label: isHidden
                        ? localizations.showCategoryLabel(name)
                        : localizations.hideCategoryLabel(name),
                    child: Switch.adaptive(
                      key: ValueKey('category-visibility-$id'),
                      value: !isHidden,
                      onChanged: isSaving ? null : onVisibilityChanged,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              _WalletMenu(
                categoryId: id,
                wallet: defaultWallet,
                enabled: !isSaving,
                onChanged: onDefaultWalletChanged,
                colorScheme: colorScheme,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SizedBox.square(
        dimension: 44,
        child: Icon(icon, color: color),
      ),
    );
  }
}

class _CategoryTitle extends StatelessWidget {
  const _CategoryTitle({required this.name, required this.isHidden});

  final String name;
  final bool isHidden;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        if (isHidden) ...[
          const SizedBox(height: 4),
          Text(
            localizations.categoryHidden,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}

enum _WalletMenuValue { none, cash, instaPay, vodafoneCash }

class _WalletMenu extends StatelessWidget {
  const _WalletMenu({
    required this.categoryId,
    required this.wallet,
    required this.enabled,
    required this.onChanged,
    required this.colorScheme,
  });

  final String categoryId;
  final WalletType? wallet;
  final bool enabled;
  final ValueChanged<WalletType?> onChanged;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final walletName = wallet == null
        ? localizations.categoryNoDefaultWallet
        : localizations.categoryDefaultWalletValue(
            localizedWalletName(localizations, wallet!),
          );

    return PopupMenuButton<_WalletMenuValue>(
      key: ValueKey('category-wallet-$categoryId'),
      enabled: enabled,
      tooltip: localizations.changeDefaultWallet,
      onSelected: (value) => onChanged(_walletFromMenuValue(value)),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: _WalletMenuValue.none,
          child: Text(localizations.categoryNoDefaultWallet),
        ),
        for (final walletType in WalletType.values)
          PopupMenuItem(
            value: _menuValueFromWallet(walletType),
            child: Text(localizedWalletName(localizations, walletType)),
          ),
      ],
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.account_balance_wallet_outlined, size: 18),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  walletName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_drop_down, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

_WalletMenuValue _menuValueFromWallet(WalletType wallet) => switch (wallet) {
  WalletType.cash => _WalletMenuValue.cash,
  WalletType.instaPay => _WalletMenuValue.instaPay,
  WalletType.vodafoneCash => _WalletMenuValue.vodafoneCash,
};

WalletType? _walletFromMenuValue(_WalletMenuValue value) => switch (value) {
  _WalletMenuValue.none => null,
  _WalletMenuValue.cash => WalletType.cash,
  _WalletMenuValue.instaPay => WalletType.instaPay,
  _WalletMenuValue.vodafoneCash => WalletType.vodafoneCash,
};
