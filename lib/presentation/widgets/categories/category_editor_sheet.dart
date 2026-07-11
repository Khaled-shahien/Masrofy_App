import 'package:flutter/material.dart';

import '../../../domain/entities/category.dart';
import '../../../domain/entities/transaction_type.dart';
import '../../../domain/entities/wallet_type.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'category_localization.dart';
import 'category_visual_registry.dart';

part 'category_editor_pickers.dart';

/// Persists values collected by [CategoryEditorSheet].
typedef CategoryEditorSubmit =
    Future<bool> Function({
      required String name,
      required String iconKey,
      required int colorValue,
      required WalletType? defaultWallet,
    });

/// Form used to create or edit a custom category.
class CategoryEditorSheet extends StatefulWidget {
  const CategoryEditorSheet({
    required this.type,
    required this.existingNames,
    required this.onSubmit,
    this.category,
    super.key,
  });

  final TransactionType type;
  final Iterable<String> existingNames;
  final Category? category;
  final CategoryEditorSubmit onSubmit;

  @override
  State<CategoryEditorSheet> createState() => _CategoryEditorSheetState();
}

class _CategoryEditorSheetState extends State<CategoryEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late String _iconKey;
  late int _colorValue;
  late WalletType? _defaultWallet;
  var _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name);
    _iconKey = widget.category?.iconKey ?? _initialIconKey(widget.type);
    _colorValue = widget.category?.colorValue ?? categoryColorValues.first;
    _defaultWallet = widget.category?.defaultWallet;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.only(bottom: keyboardInset),
        child: SingleChildScrollView(
          key: const ValueKey('category-editor-sheet'),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _EditorHeader(
                  title: widget.category == null
                      ? localizations.addCategory
                      : localizations.editCategory,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const ValueKey('category-name-field'),
                  controller: _nameController,
                  enabled: !_isSubmitting,
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: localizations.categoryNameLabel,
                    border: const OutlineInputBorder(),
                  ),
                  validator: _validateName,
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 20),
                _SectionLabel(text: localizations.categoryIconLabel),
                const SizedBox(height: 8),
                _IconPicker(
                  selectedKey: _iconKey,
                  enabled: !_isSubmitting,
                  onSelected: (value) => setState(() => _iconKey = value),
                ),
                const SizedBox(height: 20),
                _SectionLabel(text: localizations.categoryColorLabel),
                const SizedBox(height: 8),
                _ColorPicker(
                  selectedValue: _colorValue,
                  enabled: !_isSubmitting,
                  onSelected: (value) => setState(() => _colorValue = value),
                ),
                const SizedBox(height: 20),
                _SectionLabel(
                  text: localizations.categoryDefaultWalletLabel,
                ),
                const SizedBox(height: 8),
                _WalletPicker(
                  selectedWallet: _defaultWallet,
                  enabled: !_isSubmitting,
                  onSelected: (value) => setState(() => _defaultWallet = value),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        key: const ValueKey('category-editor-cancel'),
                        onPressed: _isSubmitting
                            ? null
                            : () => Navigator.pop(context),
                        child: Text(localizations.commonCancel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        key: const ValueKey('category-editor-save'),
                        onPressed: _isSubmitting ? null : _submit,
                        child: _isSubmitting
                            ? const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(localizations.commonSave),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _validateName(String? value) {
    final localizations = AppLocalizations.of(context);
    final normalized = value?.trim().toLowerCase() ?? '';
    if (normalized.isEmpty) {
      return localizations.categoryNameRequired;
    }
    final duplicate = widget.existingNames.any(
      (name) => name.trim().toLowerCase() == normalized,
    );
    return duplicate ? localizations.categoryNameAlreadyExists : null;
  }

  Future<void> _submit() async {
    if (_isSubmitting || !(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() => _isSubmitting = true);
    final didSave = await widget.onSubmit(
      name: _nameController.text.trim(),
      iconKey: _iconKey,
      colorValue: _colorValue,
      defaultWallet: _defaultWallet,
    );
    if (!mounted) {
      return;
    }
    if (didSave) {
      Navigator.pop(context, true);
      return;
    }
    setState(() => _isSubmitting = false);
  }
}

class _EditorHeader extends StatelessWidget {
  const _EditorHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        IconButton(
          tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

String _initialIconKey(TransactionType type) => switch (type) {
  TransactionType.expense => 'restaurant',
  TransactionType.income => 'payments',
};
