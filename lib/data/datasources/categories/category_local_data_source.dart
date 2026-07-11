import 'dart:async';
import 'dart:convert';

import 'package:hive/hive.dart';

import '../../models/category_model.dart';

/// Stores and observes serialized category records on the current device.
abstract interface class CategoryLocalDataSource {
  /// Watches all category records, including hidden ones.
  Stream<List<CategoryModel>> watchCategories();

  /// Gets all category records, including hidden ones.
  Future<List<CategoryModel>> getCategories();

  /// Creates or replaces one category record by identifier.
  Future<void> saveCategory(CategoryModel category);

  /// Creates or replaces category records by identifier.
  Future<void> saveCategories(Iterable<CategoryModel> categories);
}

/// Persists category JSON in a versioned Hive string box.
class HiveCategoryLocalDataSource implements CategoryLocalDataSource {
  /// Creates a Hive-backed category data source.
  const HiveCategoryLocalDataSource(this._box);

  final Box<String> _box;

  @override
  Future<List<CategoryModel>> getCategories() async {
    return _box.values.map(_decode).toList(growable: false);
  }

  @override
  Future<void> saveCategories(Iterable<CategoryModel> categories) {
    final entries = <String, String>{
      for (final category in categories)
        category.id: jsonEncode(category.toJson()),
    };
    return _box.putAll(entries);
  }

  @override
  Future<void> saveCategory(CategoryModel category) {
    return _box.put(category.id, jsonEncode(category.toJson()));
  }

  @override
  Stream<List<CategoryModel>> watchCategories() => _watchSnapshots(
    changes: _box.watch(),
    load: getCategories,
  );

  CategoryModel _decode(String value) {
    final decoded = jsonDecode(value);
    return switch (decoded) {
      Map<String, dynamic> json => CategoryModel.fromJson(json),
      _ => throw const FormatException('Stored category must be a JSON map.'),
    };
  }
}

/// Provides deterministic category persistence for tests and local previews.
class InMemoryCategoryLocalDataSource implements CategoryLocalDataSource {
  /// Creates an in-memory data source with optional [seed] records.
  InMemoryCategoryLocalDataSource([Iterable<CategoryModel> seed = const []])
    : _records = {for (final category in seed) category.id: category};

  final Map<String, CategoryModel> _records;
  final StreamController<void> _changes = StreamController<void>.broadcast(
    sync: true,
  );

  @override
  Future<List<CategoryModel>> getCategories() async {
    return List<CategoryModel>.unmodifiable(_records.values);
  }

  @override
  Future<void> saveCategories(Iterable<CategoryModel> categories) async {
    for (final category in categories) {
      _records[category.id] = category;
    }
    _changes.add(null);
  }

  @override
  Future<void> saveCategory(CategoryModel category) async {
    _records[category.id] = category;
    _changes.add(null);
  }

  @override
  Stream<List<CategoryModel>> watchCategories() => _watchSnapshots(
    changes: _changes.stream,
    load: getCategories,
  );

  /// Releases the broadcast controller used by this test data source.
  Future<void> close() => _changes.close();
}

Stream<List<CategoryModel>> _watchSnapshots({
  required Stream<Object?> changes,
  required Future<List<CategoryModel>> Function() load,
}) {
  late final StreamController<List<CategoryModel>> controller;
  late final StreamSubscription<Object?> subscription;

  Future<void> emitSnapshot() async {
    try {
      controller.add(await load());
    } on Object catch (error, stackTrace) {
      controller.addError(error, stackTrace);
    }
  }

  controller = StreamController<List<CategoryModel>>(
    onListen: () {
      subscription = changes.listen(
        (_) => unawaited(emitSnapshot()),
        onError: controller.addError,
        onDone: controller.close,
      );
      unawaited(emitSnapshot());
    },
    onCancel: () => subscription.cancel(),
  );
  return controller.stream;
}
