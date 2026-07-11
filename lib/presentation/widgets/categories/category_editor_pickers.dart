part of 'category_editor_sheet.dart';

class _IconPicker extends StatelessWidget {
  const _IconPicker({
    required this.selectedKey,
    required this.enabled,
    required this.onSelected,
  });

  final String selectedKey;
  final bool enabled;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 56,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: categoryIconOptions.length,
          itemBuilder: (context, index) {
            final option = categoryIconOptions[index];
            final isSelected = option.key == selectedKey;
            return Semantics(
              label: localizations.categoryIconOptionLabel(index + 1),
              button: true,
              selected: isSelected,
              child: InkWell(
                key: ValueKey('category-icon-${option.key}'),
                onTap: enabled ? () => onSelected(option.key) : null,
                borderRadius: BorderRadius.circular(8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primaryContainer
                        : colorScheme.surfaceContainerHighest,
                    border: Border.all(
                      color: isSelected
                          ? colorScheme.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(option.icon),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ColorPicker extends StatelessWidget {
  const _ColorPicker({
    required this.selectedValue,
    required this.enabled,
    required this.onSelected,
  });

  final int selectedValue;
  final bool enabled;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final (index, value) in categoryColorValues.indexed)
          Semantics(
            label: localizations.categoryColorOptionLabel(index + 1),
            button: true,
            selected: value == selectedValue,
            child: InkWell(
              key: ValueKey('category-color-$value'),
              onTap: enabled ? () => onSelected(value) : null,
              customBorder: const CircleBorder(),
              child: _ColorOption(
                color: Color(value),
                isSelected: value == selectedValue,
              ),
            ),
          ),
      ],
    );
  }
}

class _ColorOption extends StatelessWidget {
  const _ColorOption({required this.color, required this.isSelected});

  final Color color;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final foreground = color.computeLuminance() > 0.5
        ? Colors.black
        : Colors.white;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected
              ? Theme.of(context).colorScheme.onSurface
              : Colors.transparent,
          width: 3,
        ),
      ),
      child: isSelected ? Icon(Icons.check, color: foreground) : null,
    );
  }
}

class _WalletPicker extends StatelessWidget {
  const _WalletPicker({
    required this.selectedWallet,
    required this.enabled,
    required this.onSelected,
  });

  final WalletType? selectedWallet;
  final bool enabled;
  final ValueChanged<WalletType?> onSelected;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ChoiceChip(
          key: const ValueKey('category-wallet-none'),
          selected: selectedWallet == null,
          onSelected: enabled ? (_) => onSelected(null) : null,
          label: Text(localizations.categoryNoDefaultWallet),
        ),
        for (final wallet in WalletType.values)
          ChoiceChip(
            key: ValueKey('category-wallet-${wallet.name}'),
            selected: selectedWallet == wallet,
            onSelected: enabled ? (_) => onSelected(wallet) : null,
            label: Text(localizedWalletName(localizations, wallet)),
          ),
      ],
    );
  }
}
