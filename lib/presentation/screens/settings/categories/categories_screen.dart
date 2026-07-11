import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/entities/category.dart';
import '../../../../domain/entities/transaction_type.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../cubits/categories/categories_cubit.dart';
import '../../../widgets/categories/category_card.dart';
import '../../../widgets/categories/category_editor_sheet.dart';
import '../../../widgets/categories/category_localization.dart';
import '../../../widgets/categories/category_visual_registry.dart';

part 'categories_content.dart';
part 'categories_status_views.dart';

/// Lets the user manage built-in and custom transaction categories.
class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return BlocConsumer<CategoriesCubit, CategoriesState>(
      listenWhen: (previous, current) =>
          previous.error != current.error && current.error != null,
      listener: _showFailure,
      builder: (context, state) {
        final hasCategories = state.categories.isNotEmpty;
        return Scaffold(
          appBar: AppBar(title: Text(localizations.categoriesTitle)),
          body: switch (state.status) {
            CategoriesStatus.initial || CategoriesStatus.loading
                when !hasCategories =>
              const _LoadingBody(),
            CategoriesStatus.failure when !hasCategories => _ErrorBody(
              onRetry: context.read<CategoriesCubit>().load,
            ),
            _ => _CategoriesBody(state: state),
          },
          floatingActionButton:
              state.status == CategoriesStatus.initial ||
                  (state.status == CategoriesStatus.loading && !hasCategories)
              ? null
              : FloatingActionButton.extended(
                  key: const ValueKey('add-category-button'),
                  onPressed: state.isSaving
                      ? null
                      : () => _openEditor(context, state: state),
                  icon: const Icon(Icons.add),
                  label: Text(localizations.addCategory),
                ),
        );
      },
    );
  }

  void _showFailure(BuildContext context, CategoriesState state) {
    final localizations = AppLocalizations.of(context);
    final message = switch (state.error) {
      CategoriesFailure.validation => localizations.categoryNameAlreadyExists,
      CategoriesFailure.storage || null => localizations.categoriesSaveError,
    };
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  static Future<void> _openEditor(
    BuildContext context, {
    required CategoriesState state,
    Category? category,
  }) async {
    final cubit = context.read<CategoriesCubit>();
    final existingNames = state.categories
        .where((item) => item.id != category?.id)
        .map((item) => item.name);
    final didSave = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => CategoryEditorSheet(
        type: category?.type ?? state.selectedType,
        category: category,
        existingNames: existingNames,
        onSubmit:
            ({
              required name,
              required iconKey,
              required colorValue,
              required defaultWallet,
            }) async {
              await cubit.saveCustomCategory(
                id: category?.id,
                type: category?.type ?? state.selectedType,
                name: name,
                iconKey: iconKey,
                colorValue: colorValue,
                defaultWallet: defaultWallet,
              );
              return cubit.state.error == null;
            },
      ),
    );
    if (didSave != true || !context.mounted) {
      return;
    }
    final localizations = AppLocalizations.of(context);
    final message = category == null
        ? localizations.categoryCreatedMessage
        : localizations.categoryUpdatedMessage;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
