import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:masrofy/core/security/app_lock_service.dart';
import 'package:masrofy/core/security/secure_value_store.dart';
import 'package:masrofy/presentation/cubits/security/app_lock_cubit.dart';

void main() {
  test('loads unlocked when app lock is disabled by default', () async {
    final cubit = _cubit();
    addTearDown(cubit.close);

    await cubit.load();

    expect(cubit.state.isEnabled, isFalse);
    expect(cubit.state.isLocked, isFalse);
  });

  test('locks on cold start after setup and unlocks with PIN', () async {
    final service = _service(InMemorySecureValueStore());
    await service.setupPin('1234');
    final cubit = _cubit(service: service);
    addTearDown(cubit.close);

    await cubit.load();
    expect(cubit.state.isLocked, isTrue);

    final failed = await cubit.unlock('0000');
    expect(failed.isSuccess, isFalse);
    expect(cubit.state.isLocked, isTrue);

    final success = await cubit.unlock('1234');
    expect(success.isSuccess, isTrue);
    expect(cubit.state.isLocked, isFalse);
  });

  test('locks on resume after privacy timeout', () async {
    var now = DateTime(2026, 7, 12, 9);
    final service = _service(InMemorySecureValueStore());
    await service.setupPin('1234');
    final cubit = AppLockCubit(
      appLockService: service,
      now: () => now,
    );
    addTearDown(cubit.close);
    await cubit.load();
    await cubit.unlock('1234');

    cubit.markBackgrounded();
    now = now.add(const Duration(seconds: 31));
    cubit.markResumed();

    expect(cubit.state.isLocked, isTrue);
  });
}

AppLockCubit _cubit({AppLockService? service}) {
  return AppLockCubit(
    appLockService: service ?? _service(InMemorySecureValueStore()),
  );
}

AppLockService _service(InMemorySecureValueStore store) {
  return AppLockService(
    secureStore: store,
    random: Random(3),
    hashIterations: 4,
  );
}
