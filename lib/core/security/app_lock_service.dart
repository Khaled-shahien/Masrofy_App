import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:equatable/equatable.dart';

import 'secure_value_store.dart';

enum AppLockFailureReason { validation, invalidPin, lockedOut, disabled }

class AppLockException implements Exception {
  const AppLockException(this.reason, this.message);

  final AppLockFailureReason reason;
  final String message;

  @override
  String toString() => 'AppLockException($reason): $message';
}

class AppLockStatus extends Equatable {
  const AppLockStatus({
    required this.enabled,
    required this.biometricEnabled,
    required this.privacyTimeout,
    required this.failedAttempts,
    this.lockoutUntil,
  });

  const AppLockStatus.disabled()
    : enabled = false,
      biometricEnabled = false,
      privacyTimeout = AppLockService.defaultPrivacyTimeout,
      failedAttempts = 0,
      lockoutUntil = null;

  final bool enabled;
  final bool biometricEnabled;
  final Duration privacyTimeout;
  final int failedAttempts;
  final DateTime? lockoutUntil;

  bool isLockedOut(DateTime now) {
    final until = lockoutUntil;
    return until != null && now.isBefore(until);
  }

  @override
  List<Object?> get props => [
    enabled,
    biometricEnabled,
    privacyTimeout,
    failedAttempts,
    lockoutUntil,
  ];
}

enum PinVerificationOutcome { success, invalidPin, lockedOut, disabled }

class PinVerificationResult extends Equatable {
  const PinVerificationResult({
    required this.outcome,
    required this.failedAttempts,
    this.lockoutUntil,
  });

  final PinVerificationOutcome outcome;
  final int failedAttempts;
  final DateTime? lockoutUntil;

  bool get isSuccess => outcome == PinVerificationOutcome.success;

  @override
  List<Object?> get props => [outcome, failedAttempts, lockoutUntil];
}

class AppLockLifecyclePolicy {
  const AppLockLifecyclePolicy();

  bool shouldLockOnResume({
    required AppLockStatus status,
    required DateTime? backgroundedAt,
    required DateTime resumedAt,
  }) {
    if (!status.enabled || backgroundedAt == null) {
      return false;
    }
    final elapsed = resumedAt.difference(backgroundedAt);
    return !elapsed.isNegative && elapsed >= status.privacyTimeout;
  }
}

class AppLockService {
  AppLockService({
    required this._secureStore,
    Random? random,
    this._hashIterations = 12000,
    this._maxFailedAttempts = 5,
    this._lockoutDuration = const Duration(minutes: 5),
  }) : _random = random ?? Random.secure();

  static const defaultPrivacyTimeout = Duration(seconds: 30);

  static const _saltKey = 'masrofy_app_lock_salt_v1';
  static const _hashKey = 'masrofy_app_lock_hash_v1';
  static const _biometricEnabledKey = 'masrofy_app_lock_biometric_v1';
  static const _privacyTimeoutKey = 'masrofy_app_lock_timeout_seconds_v1';
  static const _failedAttemptsKey = 'masrofy_app_lock_failed_attempts_v1';
  static const _lockoutUntilKey = 'masrofy_app_lock_lockout_until_v1';

  final SecureValueStore _secureStore;
  final Random _random;
  final int _hashIterations;
  final int _maxFailedAttempts;
  final Duration _lockoutDuration;

  Future<AppLockStatus> loadStatus({DateTime? now}) async {
    final hash = await _secureStore.read(_hashKey);
    if (hash == null || hash.isEmpty) {
      return const AppLockStatus.disabled();
    }
    final currentTime = now ?? DateTime.now();
    final lockoutUntil = _parseDate(await _secureStore.read(_lockoutUntilKey));
    if (lockoutUntil != null && !currentTime.isBefore(lockoutUntil)) {
      await _secureStore.delete(_lockoutUntilKey);
      await _secureStore.write(_failedAttemptsKey, '0');
    }

    return AppLockStatus(
      enabled: true,
      biometricEnabled:
          (await _secureStore.read(_biometricEnabledKey)) == 'true',
      privacyTimeout: _readPrivacyTimeout(
        await _secureStore.read(_privacyTimeoutKey),
      ),
      failedAttempts:
          int.tryParse(await _secureStore.read(_failedAttemptsKey) ?? '') ?? 0,
      lockoutUntil: _parseDate(await _secureStore.read(_lockoutUntilKey)),
    );
  }

  Future<void> setupPin(String pin) async {
    _validatePin(pin);
    final salt = _generateSalt();
    await _secureStore.write(_saltKey, salt);
    await _secureStore.write(_hashKey, _hashPin(pin: pin, salt: salt));
    await _secureStore.write(
      _privacyTimeoutKey,
      defaultPrivacyTimeout.inSeconds.toString(),
    );
    await _resetFailures();
  }

  Future<PinVerificationResult> verifyPin(
    String pin, {
    DateTime? now,
  }) async {
    final currentTime = now ?? DateTime.now();
    final status = await loadStatus(now: currentTime);
    if (!status.enabled) {
      return const PinVerificationResult(
        outcome: PinVerificationOutcome.disabled,
        failedAttempts: 0,
      );
    }
    if (status.isLockedOut(currentTime)) {
      return PinVerificationResult(
        outcome: PinVerificationOutcome.lockedOut,
        failedAttempts: status.failedAttempts,
        lockoutUntil: status.lockoutUntil,
      );
    }

    final salt = await _secureStore.read(_saltKey);
    final storedHash = await _secureStore.read(_hashKey);
    if (salt == null || storedHash == null) {
      throw const AppLockException(
        AppLockFailureReason.disabled,
        'App lock is not configured.',
      );
    }

    if (_hashPin(pin: pin, salt: salt) == storedHash) {
      await _resetFailures();
      return const PinVerificationResult(
        outcome: PinVerificationOutcome.success,
        failedAttempts: 0,
      );
    }

    final failedAttempts = status.failedAttempts + 1;
    await _secureStore.write(_failedAttemptsKey, failedAttempts.toString());
    if (failedAttempts >= _maxFailedAttempts) {
      final lockoutUntil = currentTime.add(_lockoutDuration);
      await _secureStore.write(
        _lockoutUntilKey,
        lockoutUntil.toIso8601String(),
      );
      return PinVerificationResult(
        outcome: PinVerificationOutcome.lockedOut,
        failedAttempts: failedAttempts,
        lockoutUntil: lockoutUntil,
      );
    }

    return PinVerificationResult(
      outcome: PinVerificationOutcome.invalidPin,
      failedAttempts: failedAttempts,
    );
  }

  Future<void> changePin({
    required String currentPin,
    required String newPin,
  }) async {
    final result = await verifyPin(currentPin);
    if (!result.isSuccess) {
      throw const AppLockException(
        AppLockFailureReason.invalidPin,
        'Current PIN verification failed.',
      );
    }
    await setupPin(newPin);
  }

  Future<void> disable({required String currentPin}) async {
    final result = await verifyPin(currentPin);
    if (!result.isSuccess) {
      throw const AppLockException(
        AppLockFailureReason.invalidPin,
        'Current PIN verification failed.',
      );
    }
    await _secureStore.delete(_saltKey);
    await _secureStore.delete(_hashKey);
    await _secureStore.delete(_biometricEnabledKey);
    await _secureStore.delete(_failedAttemptsKey);
    await _secureStore.delete(_lockoutUntilKey);
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    final status = await loadStatus();
    if (!status.enabled) {
      throw const AppLockException(
        AppLockFailureReason.disabled,
        'Set a PIN before enabling biometric unlock.',
      );
    }
    await _secureStore.write(_biometricEnabledKey, enabled.toString());
  }

  Future<void> setPrivacyTimeout(Duration timeout) async {
    if (timeout < const Duration(seconds: 5)) {
      throw const AppLockException(
        AppLockFailureReason.validation,
        'Privacy timeout is too short.',
      );
    }
    await _secureStore.write(
      _privacyTimeoutKey,
      timeout.inSeconds.toString(),
    );
  }

  Future<void> _resetFailures() async {
    await _secureStore.write(_failedAttemptsKey, '0');
    await _secureStore.delete(_lockoutUntilKey);
  }

  String _generateSalt() {
    return base64Encode(
      Uint8List.fromList(List<int>.generate(16, (_) => _random.nextInt(256))),
    );
  }

  String _hashPin({required String pin, required String salt}) {
    var digest = sha256.convert(utf8.encode('$salt:$pin')).bytes;
    final pinBytes = utf8.encode(pin);
    final saltBytes = utf8.encode(salt);
    for (var index = 0; index < _hashIterations; index++) {
      digest = sha256.convert(<int>[
        ...digest,
        ...saltBytes,
        ...pinBytes,
      ]).bytes;
    }
    return base64Encode(digest);
  }

  void _validatePin(String pin) {
    final isDigitsOnly = RegExp(r'^\d{4,8}$').hasMatch(pin);
    if (!isDigitsOnly) {
      throw const AppLockException(
        AppLockFailureReason.validation,
        'PIN must be 4 to 8 digits.',
      );
    }
  }

  Duration _readPrivacyTimeout(String? value) {
    final seconds = int.tryParse(value ?? '');
    if (seconds == null || seconds < 5) {
      return defaultPrivacyTimeout;
    }
    return Duration(seconds: seconds);
  }

  DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }
}
