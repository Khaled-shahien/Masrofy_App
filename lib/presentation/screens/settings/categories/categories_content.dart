part of 'categories_screen.dart';

class _CategoriesBody extends StatelessWidget {
  const _CategoriesBody({required this.state});

  final CategoriesState state;

  @override
  Widget build(BuildContext context) {
    final defaultCategories = state.categories
        .where((category) => category.isDefault)
        .toList(growable: false);
    final customCategories = state.categories
        .where((category) => !category.isDefault)
        .toList(growable: false);

    return LayoutBuilder(
      builder: (context, constraints) {
        final sidePadding = constraints.maxWidth > 1040
            ? (constraints.maxWidth - 1040) / 2 + 16
            : 16.0;
        return RefreshIndicator(
          onRefresh: context.read<CategoriesCubit>().load,
          child: CustomScrollView(
            key: const ValueKey('categories-scroll-view'),
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  sidePadding,
                  16,
                  sidePadding,
                  8,
                ),
                sliver: SliverToBoxAdapter(
                  child: _CategoriesHeader(state: state),
                ),
              ),
              if (state.categories.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _NoCategoriesBody(horizontalPadding: sidePadding),
                )
              else ...[
                _SectionHeadingSliver(
                  title: AppLocalizations.of(context).defaultCategoriesSection,
                  horizontalPadding: sidePadding,
                ),
                _CategoryGridSliver(
                  categories: defaultCategories,
                  horizontalPadding: sidePadding,
                  state: state,
                ),
                _SectionHeadingSliver(
                  title: AppLocalizations.of(context).customCategoriesSection,
                  horizontalPadding: sidePadding,
                ),
                if (customCategories.isEmpty)
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      sidePadding,
                      0,
                      sidePadding,
                      96,
                    ),
                    sliver: const SliverToBoxAdapter(
                      child: _NoCustomCategoriesCard(),
                    ),
                  )
                else
                  _CategoryGridSliver(
                    categories: customCategories,
                    horizontalPadding: sidePadding,
                    state: state,
                    bottomPadding: 96,
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _CategoriesHeader extends StatelessWidget {
  const _CategoriesHeader({required this.state});

  final CategoriesState state;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          localizations.categoriesIntro,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        SegmentedButton<TransactionType>(
          key: const ValueKey('category-type-segment'),
          expandedInsets: EdgeInsets.zero,
          showSelectedIcon: false,
          segments: [
            ButtonSegment(
              value: TransactionType.expense,
              icon: const Icon(Icons.arrow_upward),
              label: Text(localizations.transactionTypeExpense),
            ),
            ButtonSegment(
              value: TransactionType.income,
              icon: const Icon(Icons.arrow_downward),
              label: Text(localizations.transactionTypeIncome),
            ),
          ],
          selected: {state.selectedType},
          onSelectionChanged: state.isSaving
              ? null
              : (selection) =>
                    context.read<CategoriesCubit>().selectType(selection.first),
        ),
        if (state.status == CategoriesStatus.loading || state.isSaving) ...[
          const SizedBox(height: 12),
          const LinearProgressIndicator(minHeight: 2),
        ],
      ],
    );
  }
}

class _SectionHeadingSliver extends StatelessWidget {
  const _SectionHeadingSliver({
    required this.title,
    required this.horizontalPadding,
  });

  final String title;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        16,
        horizontalPadding,
        8,
      ),
      sliver: SliverToBoxAdapter(
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _CategoryGridSliver extends StatelessWidget {
  const _CategoryGridSliver({
    required this.categories,
    required this.horizontalPadding,
    required this.state,
    this.bottomPadding = 0,
  });

  final List<Category> categories;
  final double horizontalPadding;
  final CategoriesState state;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        0,
        horizontalPadding,
        bottomPadding,
      ),
      sliver: SliverGrid.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 430,
          mainAxisExtent: 132,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return _CategoryGridItem(category: category, state: state);
        },
      ),
    );
  }
}

class _CategoryGridItem extends StatelessWidget {
  const _CategoryGridItem({required this.category, required this.state});

  final Category category;
  final CategoriesState state;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final cubit = context.read<CategoriesCubit>();
    return CategoryCard(
      id: category.id,
      name: localizedCategoryName(localizations, category),
      icon: categoryIconFor(category.iconKey),
      color: Color(category.colorValue),
      isHidden: category.isHidden,
      defaultWallet: category.defaultWallet,
      isSaving: state.isSaving,
      onVisibilityChanged: (isVisible) =>
          cubit.setVisibility(category.id, isVisible),
      onDefaultWalletChanged: (wallet) =>
          cubit.setDefaultWallet(category.id, wallet),
      onEdit: category.isDefault
          ? null
          : () => CategoriesScreen._openEditor(
              context,
              state: state,
              category: category,
            ),
    );
  }
}
