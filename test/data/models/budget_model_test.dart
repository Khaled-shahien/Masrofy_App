import 'package:flutter_test/flutter_test.dart';
import 'package:masrofy/data/models/budget_model.dart';
import 'package:masrofy/domain/entities/budget.dart';
import 'package:masrofy/domain/entities/budget_period.dart';

void main() {
  test('maps budget records to and from JSON safely', () {
    final model = BudgetModel.fromDomain(
      Budget(
        id: 'budget-1',
        categoryId: 'food',
        amount: 1200,
        period: const BudgetPeriod(year: 2026, month: 7),
        note: 'Groceries',
        createdAt: DateTime(2026, 7, 1),
        updatedAt: DateTime(2026, 7, 2),
      ),
    );

    final json = model.toJson();
    final decoded = BudgetModel.fromJson(json).toDomain();

    expect(decoded.id, 'budget-1');
    expect(decoded.categoryId, 'food');
    expect(decoded.amount, 1200);
    expect(decoded.period, const BudgetPeriod(year: 2026, month: 7));
    expect(decoded.note, 'Groceries');
  });

  test('rejects invalid month and malformed dates', () {
    final json = {
      'id': 'budget-1',
      'categoryId': 'food',
      'amount': 100,
      'month': 13,
      'year': 2026,
      'createdAt': 'not-a-date',
      'updatedAt': '2026-07-01T00:00:00.000',
    };

    expect(
      () => BudgetModel.fromJson(json),
      throwsA(isA<FormatException>()),
    );
  });
}
