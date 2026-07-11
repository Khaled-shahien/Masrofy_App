import '../../domain/entities/financial_transaction.dart';
import '../../domain/entities/transaction_type.dart';
import '../../domain/entities/wallet_type.dart';
import '../../domain/repositories/transaction_repository.dart';

class ProvidedExpensesImporter {
  const ProvidedExpensesImporter(this._repository);

  final TransactionRepository _repository;

  Future<void> importOnce() async {
    final existing = await _repository.getTransactions();
    final existingIds = existing.map((transaction) => transaction.id).toSet();

    for (final transaction in _providedExpenses) {
      if (!existingIds.contains(transaction.id)) {
        await _repository.saveTransaction(transaction);
      }
    }
  }
}

final _importedAt = DateTime(2026, 7, 11, 12);

final _providedExpenses = <FinancialTransaction>[
  _expense(
    id: 'manual_2026_07_01_transport',
    amount: 40,
    categoryId: 'expense_transport',
    date: DateTime(2026, 7),
  ),
  _expense(
    id: 'manual_2026_07_02_transport',
    amount: 20,
    categoryId: 'expense_transport',
    date: DateTime(2026, 7, 2),
  ),
  _expense(
    id: 'manual_2026_07_03_transport',
    amount: 40,
    categoryId: 'expense_transport',
    date: DateTime(2026, 7, 3),
  ),
  _expense(
    id: 'manual_2026_07_03_food',
    amount: 235,
    categoryId: 'expense_food_drink',
    date: DateTime(2026, 7, 3),
  ),
  _expense(
    id: 'manual_2026_07_04_transport',
    amount: 40,
    categoryId: 'expense_transport',
    date: DateTime(2026, 7, 4),
  ),
  _personTransfer(
    id: 'manual_2026_07_04_mama',
    amount: 300,
    personName: 'ماما',
    date: DateTime(2026, 7, 4),
  ),
  _expense(
    id: 'manual_2026_07_04_haircut',
    amount: 100,
    categoryId: 'expense_personal_care',
    date: DateTime(2026, 7, 4),
    note: 'حلاقة',
  ),
  _expense(
    id: 'manual_2026_07_04_supermarket',
    amount: 40,
    categoryId: 'expense_household',
    date: DateTime(2026, 7, 4),
    note: 'سوبرماركت',
  ),
  _expense(
    id: 'manual_2026_07_05_transport',
    amount: 40,
    categoryId: 'expense_transport',
    date: DateTime(2026, 7, 5),
  ),
  _expense(
    id: 'manual_2026_07_05_food',
    amount: 125,
    categoryId: 'expense_food_drink',
    date: DateTime(2026, 7, 5),
  ),
  _expense(
    id: 'manual_2026_07_05_coffee',
    amount: 50,
    categoryId: 'expense_cafes_restaurants',
    date: DateTime(2026, 7, 5),
    note: 'قهوة',
  ),
  _expense(
    id: 'manual_2026_07_06_coffee',
    amount: 40,
    categoryId: 'expense_cafes_restaurants',
    date: DateTime(2026, 7, 6),
    note: 'قهوة',
  ),
  _expense(
    id: 'manual_2026_07_06_food',
    amount: 135,
    categoryId: 'expense_food_drink',
    date: DateTime(2026, 7, 6),
  ),
  _expense(
    id: 'manual_2026_07_07_transport',
    amount: 60,
    categoryId: 'expense_transport',
    date: DateTime(2026, 7, 7),
  ),
  _expense(
    id: 'manual_2026_07_07_food',
    amount: 100,
    categoryId: 'expense_food_drink',
    date: DateTime(2026, 7, 7),
  ),
  _expense(
    id: 'manual_2026_07_07_clothing',
    amount: 300,
    categoryId: 'expense_clothing',
    date: DateTime(2026, 7, 7),
  ),
  _expense(
    id: 'manual_2026_07_08_transport',
    amount: 150,
    categoryId: 'expense_transport',
    date: DateTime(2026, 7, 8),
  ),
  _expense(
    id: 'manual_2026_07_08_supermarket',
    amount: 10,
    categoryId: 'expense_household',
    date: DateTime(2026, 7, 8),
    note: 'سوبرماركت',
  ),
  _personTransfer(
    id: 'manual_2026_07_08_yasmin',
    amount: 700,
    personName: 'ياسمين',
    date: DateTime(2026, 7, 8),
  ),
  _expense(
    id: 'manual_2026_07_08_healthcare',
    amount: 215,
    categoryId: 'expense_healthcare',
    date: DateTime(2026, 7, 8),
  ),
  _expense(
    id: 'manual_2026_07_09_transport',
    amount: 140,
    categoryId: 'expense_transport',
    date: DateTime(2026, 7, 9),
  ),
  _expense(
    id: 'manual_2026_07_09_healthcare',
    amount: 150,
    categoryId: 'expense_healthcare',
    date: DateTime(2026, 7, 9),
  ),
  _expense(
    id: 'manual_2026_07_09_food',
    amount: 200,
    categoryId: 'expense_food_drink',
    date: DateTime(2026, 7, 9),
  ),
  _expense(
    id: 'manual_2026_07_09_coffee',
    amount: 300,
    categoryId: 'expense_cafes_restaurants',
    date: DateTime(2026, 7, 9),
    note: 'قهوة',
  ),
  _expense(
    id: 'manual_2026_07_10_transport',
    amount: 40,
    categoryId: 'expense_transport',
    date: DateTime(2026, 7, 10),
  ),
  _expense(
    id: 'manual_2026_07_10_food',
    amount: 60,
    categoryId: 'expense_food_drink',
    date: DateTime(2026, 7, 10),
  ),
  _expense(
    id: 'manual_2026_07_10_phone_bundle',
    amount: 170,
    categoryId: 'expense_subscriptions',
    date: DateTime(2026, 7, 10),
    note: 'باقة فون',
  ),
];

FinancialTransaction _expense({
  required String id,
  required double amount,
  required String categoryId,
  required DateTime date,
  String? note,
}) {
  return FinancialTransaction(
    id: id,
    type: TransactionType.expense,
    amount: amount,
    categoryId: categoryId,
    date: date,
    note: note,
    wallet: WalletType.cash,
    createdAt: _importedAt,
    updatedAt: _importedAt,
  );
}

FinancialTransaction _personTransfer({
  required String id,
  required double amount,
  required String personName,
  required DateTime date,
}) {
  return FinancialTransaction(
    id: id,
    type: TransactionType.expense,
    amount: amount,
    categoryId: 'expense_person_transfer',
    date: date,
    personName: personName,
    wallet: WalletType.cash,
    createdAt: _importedAt,
    updatedAt: _importedAt,
  );
}
