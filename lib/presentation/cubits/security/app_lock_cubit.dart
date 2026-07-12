import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/security/app_lock_service.dart';
import 'app_lock_state.dart';

class AppLockCubit extends Cubit<AppLockState> {
  AppLockCubit({
    required AppLockService appLockService,
    AppLockLifecyclePolicy lifecyclePolicy = const AppLockLifecyclePolicy(),
    DateTime Function()? now,
  }) : _appLockService = appLockService,
       _lifecyclePolicy = lifecyclePolicy,
       _now = now ?? DateTime.now,
       super(const AppLockState());

  final AppLockService _appLockService;
  final AppLockLifecyclePolicy _lifecyclePolicy;
  final DateTime Function() _now;
  DateTime? _backgroundedAt;

  Future<void> load() async {
    emit(
      state.copyWith(viewStatus: AppLockViewStatus.loading, clearError: true),
    );
    final status = await _appLockService.loadStatus(now: _now());
    emit(
      state.copyWith(
        viewStatus: AppLockViewStatus.ready,
        lockStatus: status,
        isLocked: status.enabled,
        clearError: true,
      ),
    );
  }

  Future<void> reload({bool keepUnlocked = true}) async {
    final status = await _appLockService.loadStatus(now: _now());
    emit(
      state.copyWith(
        viewStatus: AppLockViewStatus.ready,
        lockStatus: status,
        isLocked: status.enabled && (!keepUnlocked || state.isLocked),
        clearError: true,
      ),
    );
  }

  Future<void> setupPin(String pin) async {
    await _appLockService.setupPin(pin);
    final status = await _appLockService.loadStatus(now: _now());
    emit(
      state.copyWith(
        viewStatus: AppLockViewStatus.ready,
        lockStatus: status,
        isLocked: false,
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
