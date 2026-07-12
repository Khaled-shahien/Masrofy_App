import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:masrofy/core/security/app_lock_service.dart';
import 'package:masrofy/core/security/secure_value_store.dart';

void main() {
  test(
    'app lock is disabled by default and stores no PIN in plain text',
    () async {
      final store = InMemorySecureValueStore();
      final service = _service(store);

      final status = await service.loadStatus();

      expect(status.enabled, isFalse);
      expect(store.debugValues.values.join(' '), isNot(contains('1234')));
    },
  );

  test('sets up and verifies a PIN with a salted hash', () async {
    final store = InMemorySecureValueStore();
    final service = _service(store);

    await service.setupPin('1234');
    final status = await service.loadStatus();
    final result = await service.verifyPin('1234');

    expect(status.enabled, isTrue);
    expect(result.isSuccess, isTrue);
    expect(store.debugValues.values, isNot(contains('1234')));
    expect(store.debugValues.values.join(' '), isNot(contains('1234')));
  });

  test('rejects incorrect PIN and locks out after repeated failures', () async {
    final store = InMemorySecureValueStore();
    final service = _service(
      store,
      maxFailedAttempts: 3,
      lockoutDuration: const Duration(minutes: 2),
    );
    final now = DateTime(2026, 7, 12, 9);
    await service.setupPin('1234');

    expect(
      (await service.verifyPin('0000', now: now)).outcome,
      PinVerificationOutcome.invalidPin,
    );
    expect(
      (await service.verifyPin('1111', now: now)).failedAttempts,
      2,
    );
    final locked = await service.verifyPin('2222', now: now);

    expect(locked.outcome, PinVerificationOutcome.lockedOut);
    expect(locked.lockoutUntil, now.add(const Duration(minutes: 2)));
    expect(
      (await service.verifyPin('1234', now: now)).outcome,
      PinVerificationOutcome.lockedOut,
    );
    expect(
      (await service.verifyPin(
        '1234',
        now: now.add(const Duration(minutes: 3)),
      )).isSuccess,
      isTrue,
    );
  });

  test(
    'changes and disables PIN only after current PIN verification',
    () async {
      final store = InMemorySecureValueStore();
      final service = _service(store);
      await service.setupPin('1234');

      await expectLater(
        service.changePin(currentPin: '0000', newPin: '5678'),
        throwsA(isA<AppLockException>()),
      );
      await service.changePin(currentPin: '1234', newPin: '5678');

      expect((await service.verifyPin('1234')).isSuccess, isFalse);
      expect((await service.verifyPin('5678')).isSuccess, isTrue);

      await expectLater(
        service.disable(currentPin: '0000'),
        throwsA(isA<AppLockException>()),
      );
      await service.disable(currentPin: '5678');
      expect((await service.loadStatus()).enabled, isFalse);
    },
  );

  test('rejects invalid PIN shape', () async {
    final service = _service(InMemorySecureValueStore());

    await expectLater(
      service.setupPin('12a4'),
      throwsA(
        isA<AppLockException>().having(
          (error) => error.reason,
          'reason',
          AppLockFailureReason.validation,
        ),
      ),
    );
  });

  test('lifecycle policy locks only after the configured timeout', () {
    const policy = AppLockLifecyclePolicy();
    const status = AppLockStatus(
      enabled: true,
      biometricEnabled: false,
      privacyTimeout: Duration(seconds: 30),
      failedAttempts: 0,
    );
    final backgroundedAt = DateTime(2026, 7, 12, 9);

    expect(
      policy.shouldLockOnResume(
        status: status,
        backgroundedAt: backgroundedAt,
        resumedAt: backgroundedAt.add(const Duration(seconds: 10)),
      ),
      isFalse,
    );
    expect(
      policy.shouldLockOnResume(
        status: status,
        backgroundedAt: backgroundedAt,
        resumedAt: backgroundedAt.add(const Duration(seconds: 31)),
      ),
      isTrue,
    );
    expect(
      policy.shouldLockOnResume(
        status: const AppLockStatus.disabled(),
        backgroundedAt: backgroundedAt,
        resumedAt: backgroundedAt.add(const Duration(hours: 1)),
      ),
      isFalse,
    );
  });
}

AppLockService _service(
  InMemorySecureValueStore store, {
  int maxFailedAttempts = 5,
  Duration lockoutDuration = const Duration(minutes: 5),
}) {
  return AppLockService(
    secureStore: store,
    random: Random(7),
    hashIterations: 12,
    maxFailedAttempts: maxFailedAttempts,
    lockoutDuration: lockoutDuration,
  );
}
