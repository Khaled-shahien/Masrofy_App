import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:masrofy/data/datasources/categories/category_local_data_source.dart';
import 'package:masrofy/data/models/category_model.dart';
import 'package:masrofy/domain/entities/transaction_type.dart';
import 'package:masrofy/domain/entities/wallet_type.dart';

void main() {
  late Directory temporaryDirectory;
  late Box<String> box;
  late HiveCategoryLocalDataSource dataSource;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'masrofy_categories_test_',
    );
    Hive.init(temporaryDirectory.path);
    box = await Hive.openBox<String>('categories');
    dataSource = HiveCategoryLocalDataSource(box);
  });

  tearDown(() async {
    await box.close();
    await temporaryDirectory.delete(recursive: true);
  });

  test('stores category records as JSON strings by stable ID', () async {
    const model = CategoryModel(
      id: 'custom_gifts',
      type: TransactionType.expense,
      name: 'Gifts',
      iconKey: 'redeem',
      colorValue: 0xFF123456,
      sortOrder: 12,
      isHidden: true,
      defaultWallet: WalletType.instaPay,
    );

    await dataSource.saveCategory(model);

    final stored = box.get(model.id);
    if (stored == null) {
      fail('Expected a persisted category JSON string.');
    }
    final json = jsonDecode(stored) as Map<String, dynamic>;
    expect(json['isHidden'], isTrue);
    expect(json['defaultWallet'], 'instaPay');
    expect(await dataSource.getCategories(), [model]);
  });

  test('saveCategories upserts without replacing unknown records', () async {
    await box.put('unknown', jsonEncode({'id': 'unknown', 'name': 'Unknown'}));

    await dataSource.saveCategories(const [
      CategoryModel(id: 'known', name: 'Known'),
    ]);

    expect(box.keys, containsAll(const ['unknown', 'known']));
  });
}
