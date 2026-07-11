import '../../entities/financial_transaction.dart';
import '../../entities/transaction_type.dart';
import '../../entities/wallet_balance.dart';
import '../../entities/wallet_balance_summary.dart';
import '../../entities/wallet_type.dart';

const trackedWalletTypes = <WalletType>[
  WalletType.instaPay,
  WalletType.vodafoneCash,
];

List<WalletBalanceSummary> buildWalletBalanceSummaries({
  required Iterable<WalletBalance> balances,
  required Iterable<FinancialTransaction> transactions,
}) {
  final balancesByWallet = {
    for (final balance in balances) balance.walletType: balance,
  };

  return [
    for (final walletType in trackedWalletTypes)
      WalletBalanceSummary(
        walletType: walletType,
        baseBalance: balancesByWallet[walletType]?.baseBalance ?? 0,
        transactionNet: calculateTransactionNet(
          walletType: walletType,
          transactions: transactions,
        ),
      ),
  ];
}

double calculateTransactionNet({
  required WalletType walletType,
  required Iterable<FinancialTransaction> transactions,
}) {
  var total = 0.0;
  for (final transaction in transactions.where(
    (transaction) => transaction.wallet == walletType,
  )) {
    total += switch (transaction.type) {
      TransactionType.income => transaction.amount,
      TransactionType.expense => -transaction.amount,
    };
  }
  return total;
}
