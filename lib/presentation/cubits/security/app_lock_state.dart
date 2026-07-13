import 'package:equatable/equatable.dart';

import '../../../core/security/app_lock_service.dart';
import '../../../core/security/biometric_authentication_service.dart';

enum AppLockViewStatus { initial, loading, ready, verifying, failure }

class AppLockState extends Equatable {
  const AppLockState({
    this.viewStatus = AppLockViewStatus.initial,
    this.lockStatus = const AppLockStatus.disabled(),
    this.isLocked = false,
    this.biometricAvailability = const BiometricAvailability.unsupported(),
    this.errorMessage,
  });

  final AppLockViewStatus viewStatus;
  final AppLockStatus lockStatus;
  final bool isLocked;
  final BiometricAvailability biometricAvailability;
  final String? errorMessage;

  bool get isEnabled => lockStatus.enabled;

  bool get canUseBiometrics =>
      lockStatus.enabled &&
      lockStatus.biometricEnabled &&
      biometricAvailability.isAvailable;

  AppLockState copyWith({
    AppLockViewStatus? viewStatus,
    AppLockStatus? lockStatus,
    bool? isLocked,
    BiometricAvailability? biometricAvailability,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AppLockState(
      viewStatus: viewStatus ?? this.viewStatus,
      lockStatus: lockStatus ?? this.lockStatus,
      isLocked: isLocked ?? this.isLocked,
      biometricAvailability:
          biometricAvailability ?? this.biometricAvailability,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    viewStatus,
    lockStatus,
    isLocked,
    biometricAvailability,
    errorMessage,
  ];
}
