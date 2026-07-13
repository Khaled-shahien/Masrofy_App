import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/security/app_lock_service.dart';
import '../../../core/security/biometric_authentication_service.dart';
import 'app_lock_state.dart';

class AppLockCubit extends Cubit<AppLockState> {
  AppLockCubit({
    required AppLockService appLockService,
    required BiometricAuthenticationService biometricAuthenticationService,
    AppLockLifecyclePolicy lifecyclePolicy = const AppLockLifecyclePolicy(),
    DateTime Function()? now,
  }) : _appLockService = appLockService,
       _biometricAuthenticationService = biometricAuthenticationService,
       _lifecyclePolicy = lifecyclePolicy,
       _now = now ?? DateTime.now,
       super(const AppLockState());

  final AppLockService _appLockService;
  final BiometricAuthenticationService _biometricAuthenticationService;
  final AppLockLifecyclePolicy _lifecyclePolicy;
  final DateTime Function() _now;
  DateTime? _backgroundedAt;

  Future<void> load() async {
    emit(
      state.copyWith(viewStatus: AppLockViewStatus.loading, clearError: true),
    );
    final status = await _appLockService.loadStatus(now: _now());
    final availability = await _biometricAuthenticationService
        .checkAvailability();
    emit(
      state.copyWith(
        viewStatus: AppLockViewStatus.ready,
        lockStatus: status,
        isLocked: status.enabled,
        biometricAvailability: availability,
        clearError: true,
      ),
    );
  }

  Future<void> reload({bool keepUnlocked = true}) async {
    final status = await _appLockService.loadStatus(now: _now());
    final availability = await _biometricAuthenticationService
        .checkAvailability();
    emit(
      state.copyWith(
        viewStatus: AppLockViewStatus.ready,
        lockStatus: status,
        isLocked: status.enabled && (!keepUnlocked || state.isLocked),
        biometricAvailability: availability,
        clearError: true,
      ),
    );
  }

  Future<void> setupPin(String pin) async {
    await _appLockService.setupPin(pin);
    final status = await _appLockService.loadStatus(now: _now());
    final availability = await _biometricAuthenticationService
        .checkAvailability();
    emit(
      state.copyWith(
        viewStatus: AppLockViewStatus.ready,
        lockStatus: status,
        isLocked: false,
        biometricAvailability: availability,
        clearError: true,
      ),
    );
  }

  Future<void> changePin({
    required String currentPin,
    required String newPin,
  }) async {
    await _appLockService.changePin(currentPin: currentPin, newPin: newPin);
    await reload();
  }

  Future<void> disable({required String currentPin}) async {
    await _appLockService.disable(currentPin: currentPin);
    emit(
      state.copyWith(
        viewStatus: AppLockViewStatus.ready,
        lockStatus: const AppLockStatus.disabled(),
        isLocked: false,
        clearError: true,
      ),
    );
  }

  Future<bool> setBiometricEnabled({
    required bool enabled,
    required String currentPin,
  }) async {
    final verification = await _appLockService.verifyPin(
      currentPin,
      now: _now(),
    );
    if (!verification.isSuccess) {
      emit(state.copyWith(errorMessage: verification.outcome.name));
      return false;
    }
    if (enabled) {
      final availability = await _biometricAuthenticationService
          .checkAvailability();
      if (!availability.isAvailable) {
        emit(
          state.copyWith(
            biometricAvailability: availability,
            errorMessage: availability.reason.name,
          ),
        );
        return false;
      }
      await _appLockService.setBiometricEnabled(true);
    } else {
      await _appLockService.setBiometricEnabled(false);
    }
    await reload();
    return true;
  }

  Future<PinVerificationResult> unlock(String pin) async {
    emit(
      state.copyWith(viewStatus: AppLockViewStatus.verifying, clearError: true),
    );
    final result = await _appLockService.verifyPin(pin, now: _now());
    final status = await _appLockService.loadStatus(now: _now());
    emit(
      state.copyWith(
        viewStatus: AppLockViewStatus.ready,
        lockStatus: status,
        isLocked: !result.isSuccess,
        errorMessage: result.isSuccess ? null : result.outcome.name,
        clearError: result.isSuccess,
      ),
    );
    return result;
  }

  Future<BiometricAuthenticationOutcome> unlockWithBiometrics({
    required String localizedReason,
  }) async {
    if (!state.canUseBiometrics) {
      return BiometricAuthenticationOutcome.notAvailable;
    }
    emit(
      state.copyWith(viewStatus: AppLockViewStatus.verifying, clearError: true),
    );
    final outcome = await _biometricAuthenticationService.authenticate(
      localizedReason: localizedReason,
    );
    final status = await _appLockService.loadStatus(now: _now());
    emit(
      state.copyWith(
        viewStatus: AppLockViewStatus.ready,
        lockStatus: status,
        isLocked: outcome != BiometricAuthenticationOutcome.success,
        errorMessage: outcome == BiometricAuthenticationOutcome.success
            ? null
            : outcome.name,
        clearError: outcome == BiometricAuthenticationOutcome.success,
      ),
    );
    return outcome;
  }

  void lock() {
    if (!state.lockStatus.enabled) {
      return;
    }
    emit(state.copyWith(isLocked: true, clearError: true));
  }

  void markBackgrounded() {
    _backgroundedAt = _now();
  }

  void markResumed() {
    final shouldLock = _lifecyclePolicy.shouldLockOnResume(
      status: state.lockStatus,
      backgroundedAt: _backgroundedAt,
      resumedAt: _now(),
    );
    _backgroundedAt = null;
    if (shouldLock) {
      lock();
    }
  }
}
