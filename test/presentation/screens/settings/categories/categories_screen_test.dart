import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masrofy/core/theme/app_theme.dart';
import 'package:masrofy/data/catalog/default_category_catalog.dart';
import 'package:masrofy/data/datasources/categories/category_local_data_source.dart';
import 'package:masrofy/data/repositories/category_repository_impl.dart';
import 'package:masrofy/domain/entities/transaction_type.dart';
import 'package:masrofy/domain/usecases/categories/initialize_default_categories.dart';
import 'package:masrofy/domain/usecases/categories/save_custom_category.dart';
import 'package:masrofy/domain/usecases/categories/set_category_default_wallet.dart';
import 'package:masrofy/domain/usecases/categories/set_category_visibility.dart';
import 'package:masrofy/domain/usecases/categories/watch_categories.dart';
import 'package:masrofy/l10n/generated/app_localizations.dart';
import 'package:masrofy/presentation/cubits/categories/categories_cubit.dart';
import 'package:masrofy/presentation/screens/settings/categories/categories_screen.dart';

void main() {
  late InMemoryCategoryLocalDataSource dataSource;
  late CategoryRepositoryImpl repository;
  late CategoriesCubit cubit;
  var generatedId = 0;

  setUp(() async {
    generatedId = 0;
    dataSource = InMemoryCategoryLocalDataSource();
    repository = CategoryRepositoryImpl(localDataSource: dataSource);
    await InitializeDefaultCategories(
      repository: repository,
      defaults: defaultCategories,
    )();
    cubit = CategoriesCubit(
      watchCategories: WatchCategories(repository),
      saveCustomCategory: SaveCustomCategory(
        repository: repository,
        generateId: () => 'custom_${generatedId++}',
      ),
      setCategoryVisibility: SetCategoryVisibility(repository),
      setCategoryDefaultWallet: SetCategoryDefaultWallet(repository),
    );
    final loaded = cubit.stream.firstWhere(
      (state) => state.status == CategoriesStatus.success,
    );
    await cubit.load();
    await loaded;
  });

  tearDown(() async {
    await dataSource.close();
    await cubit.close();
  });

  testWidgets('renders localized defaults and soft-hides a category', (
    tester,
  ) async {
    await _pumpScreen(tester, cubit);

    expect(find.text('أكل وشرب'), findsOneWidget);
    final visibility = find.byKey(
      const ValueKey('category-visibility-expense_food_drink'),
    );
    expect(visibility, findsOneWidget);

    await tester.tap(visibility);
    await tester.pump();
    final stored = await repository.getCategories(includeHidden: true);
    expect(
      stored
          .singleWhere((category) => category.id == 'expense_food_drink')
          .isHidden,
      isTrue,
    );
    expect(find.text('أكل وشرب'), findsOneWidget);
  });

  testWidgets('shows expense and income type controls', (tester) async {
    await _pumpScreen(tester, cubit);

    expect(find.text('صادر'), findsOneWidget);
    expect(find.text('وارد'), findsOneWidget);
    final segmentedButton = tester.widget<SegmentedButton<TransactionType>>(
      find.byKey(const ValueKey('category-type-segment')),
    );
    expect(segmentedButton.selected, hasLength(1));
  });

  testWidgets('validates and saves a custom category', (tester) async {
    await _pumpScreen(tester, cubit);

    await tester.tap(find.byKey(const ValueKey('add-category-button')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('category-editor-sheet')),
      findsOneWidget,
    );

    final saveButton = find.byKey(
      const ValueKey('category-editor-save'),
    );
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pump();
    expect(find.text('أدخل اسم التصنيف'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('category-name-field')),
      'الجيم',
    );
    final wallet = find.byKey(
      const ValueKey('category-wallet-instaPay'),
    );
    await tester.ensureVisible(wallet);
    await tester.tap(wallet);
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    final stored = await repository.getCategories(includeHidden: true);
    expect(stored.any((category) => category.name == 'الجيم'), isTrue);
    expect(find.text('تمت إضافة التصنيف'), findsOneWidget);
  });
}

Future<void> _pumpScreen(
  WidgetTester tester,
  CategoriesCubit cubit,
) async {
  await tester.pumpWidget(
    BlocProvider.value(
      value: cubit,
      child: MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.light(),
        home: const CategoriesScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
