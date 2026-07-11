import 'package:flutter_test/flutter_test.dart';
import 'package:masrofy/data/catalog/default_category_catalog.dart';
import 'package:masrofy/domain/entities/category.dart';
import 'package:masrofy/domain/entities/transaction_type.dart';

void main() {
  group('defaultCategories', () {
    test('contains the required expense and income catalogs', () {
      final expense = defaultCategories
          .where((category) => category.type == TransactionType.expense)
          .toList();
      final income = defaultCategories
          .where((category) => category.type == TransactionType.income)
          .toList();

      expect(expense, hasLength(12));
      expect(income, hasLength(3));
      expect(
        expense.map((category) => category.id),
        orderedEquals(const [
          'expense_food_drink',
          'expense_cafes_restaurants',
          'expense_transport',
          'expense_clothing',
          'expense_healthcare',
          'expense_household',
          'expense_extra',
          'expense_person_transfer',
          'expense_personal_care',
          'expense_subscriptions',
          'expense_entertainment',
          'expense_other',
        ]),
      );
      expect(
        income.map((category) => category.id),
        orderedEquals(const [
          'income_salary',
          'income_freelance',
          'income_other',
        ]),
      );
    });

    test('uses unique IDs and complete built-in metadata', () {
      final ids = defaultCategories.map((category) => category.id).toSet();

      expect(ids, hasLength(defaultCategories.length));
      expect(defaultCategories.every((category) => category.isDefault), isTrue);
      expect(defaultCategories.every((category) => !category.isHidden), isTrue);
      expect(
        defaultCategories.every(
          (category) => category.localizationKey?.isNotEmpty ?? false,
        ),
        isTrue,
      );
      expect(
        defaultCategories.every((category) => category.iconKey.isNotEmpty),
        isTrue,
      );
    });

    test('marks only person transfers with special behavior', () {
      final special = defaultCategories
          .where(
            (category) => category.behavior == CategoryBehavior.personTransfer,
          )
          .single;

      expect(special.id, 'expense_person_transfer');
    });
  });
}
