import 'package:flutter_test/flutter_test.dart';
import 'package:masrofy/data/models/category_model.dart';
import 'package:masrofy/domain/entities/category.dart';
import 'package:masrofy/domain/entities/transaction_type.dart';
import 'package:masrofy/domain/entities/wallet_type.dart';

void main() {
  const category = Category(
    id: 'custom_gifts',
    type: TransactionType.expense,
    name: 'Gifts',
    localizationKey: null,
    iconKey: 'cardGiftcard',
    colorValue: 0xFF123456,
    sortOrder: 15,
    isHidden: true,
    defaultWallet: WalletType.instaPay,
  );

  group('CategoryModel', () {
    test('round-trips between domain and JSON', () {
      final model = CategoryModel.fromDomain(category);
      final json = model.toJson();
      final decoded = CategoryModel.fromJson(json);

      expect(decoded.toDomain(), category);
      expect(json['isHidden'], isTrue);
      expect(json['defaultWallet'], 'instaPay');
      expect(json, isNot(contains('is_hidden')));
      expect(json, isNot(contains('default_wallet')));
    });

    test('accepts missing legacy fields and snake-case preferences', () {
      final decoded = CategoryModel.fromJson(const {
        'id': 'legacy',
        'name': 'Legacy',
        'is_hidden': true,
        'default_wallet': 'cash',
      });

      expect(decoded.type, TransactionType.expense);
      expect(decoded.iconKey, 'category');
      expect(decoded.sortOrder, 0);
      expect(decoded.isHidden, isTrue);
      expect(decoded.defaultWallet, WalletType.cash);
      expect(decoded.behavior, CategoryBehavior.standard);
    });

    test('maps an unknown wallet value to null', () {
      final decoded = CategoryModel.fromJson(const {
        'id': 'future-wallet',
        'name': 'Future wallet',
        'defaultWallet': 'unavailableWallet',
      });

      expect(decoded.defaultWallet, isNull);
    });
  });
}
