import '../../repositories/transaction_repository.dart';

class DeleteTransaction {
  const DeleteTransaction(this._repository);

  final TransactionRepository _repository;

  Future<void> call(String id) => _repository.deleteTransaction(id);
}
