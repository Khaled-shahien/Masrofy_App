import 'package:flutter_test/flutter_test.dart';
import 'package:masrofy/data/models/wallet_balance_model.dart';
import 'package:masrofy/domain/entities/wallet_balance.dart';
import 'package:masrofy/domain/entities/wallet_type.dart';

void main() {
  test('WalletBalanceModel round-trips and rejects invalid timestamps', () {
    final balance = WalletBalance(
      walletType: WalletType.cash,
      baseBalance: 125,
      updatedAt: DateTime(2026, 7, 11, 8),
    );

    final decoded = WalletBalanceModel.fromJson(
      WalletBalanceModel.fromDomain(balance).toJson(),
    );

    expect(decoded.toDomain(), balance);

    expect(
      () => WalletBalanceModel.fromJson({
        'walletType': 'cash',
        'baseBalance': 20,
        'updatedAt': 'broken',
      }),
      throwsFormatException,
    );
  });
}
