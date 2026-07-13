import 'package:equatable/equatable.dart';
import 'package:local_auth/local_auth.dart';

enum BiometricAvailabilityReason {
  available,
  unsupported,
  notEnrolled,
  unavailable,
}

class BiometricAvailability extends Equatable {
  const BiometricAvailability({
    required this.reason,
    this.availableTypes = const [],
  });

  const BiometricAvailability.available(this.availableTypes)
    : reason = BiometricAvailabilityReason.available,
      super();

  const BiometricAvailability.unsupported()
    : reason = BiometricAvailabilityReason.unsupported,
      availableTypes = const [];

  const BiometricAvailability.notEnrolled()
    : reason = BiometricAvailabilityReason.notEnrolled,
      availableTypes = const [];

  const BiometricAvailability.unavailable()
    : reason = BiometricAvailabilityReason.unavailable,
      availableTypes = const [];

  final BiometricAvailabilityReason reason;
  final List<BiometricType> availableTypes;

  bool get isAvailable => reason == BiometricAvailabilityReason.available;

  @override
  List<Object?> get props => [reason, availableTypes];
}

enum BiometricAuthenticationOutcome {
  success,
  failed,
  cancelled,
  temporaryLockout,
  permanentLockout,
  notAvailable,
}

abstract interface class BiometricAuthenticationService {
  Future<BiometricAvailability> checkAvailability();

  Future<BiometricAuthenticationOutcome> authenticate({
    required String localizedReason,
  });
}

class LocalAuthBiometricAuthenticationService
    implements BiometricAuthenticationService {
  LocalAuthBiometricAuthenticationService({LocalAuthentication? auth})
    : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  @override
  Future<BiometricAvailability> checkAvailability() async {
    try {
      final supported =
          await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
      if (!supported) {
        return const BiometricAvailability.unsupported();
      }
      final biometrics = await _auth.getAvailableBiometrics();
      if (biometrics.isEmpty) {
        return const BiometricAvailability.notEnrolled();
      }
      return BiometricAvailability.available(biometrics);
    } on Object {
      return const BiometricAvailability.unavailable();
    }
  }

  @override
  Future<BiometricAuthenticationOutcome> authenticate({
    required String localizedReason,
  }) async {
    final availability = await checkAvailability();
    if (!availability.isAvailable) {
      return BiometricAuthenticationOutcome.notAvailable;
    }

    try {
      final didAuthenticate = await _auth.authenticate(
        localizedReason: localizedReason,
        biometricOnly: true,
        sensitiveTransaction: true,
        persistAcrossBackgrounding: true,
      );
      return didAuthenticate
          ? BiometricAuthenticationOutcome.success
          : BiometricAuthenticationOutcome.failed;
    } on LocalAuthException catch (error) {
      return switch (error.code) {
        LocalAuthExceptionCode.userCanceled ||
        LocalAuthExceptionCode.systemCanceled ||
        LocalAuthExceptionCode.timeout ||
        LocalAuthExceptionCode.userRequestedFallback =>
          BiometricAuthenticationOutcome.cancelled,
        LocalAuthExceptionCode.temporaryLockout =>
          BiometricAuthenticationOutcome.temporaryLockout,
        LocalAuthExceptionCode.biometricLockout =>
          BiometricAuthenticationOutcome.permanentLockout,
        LocalAuthExceptionCode.noBiometricsEnrolled ||
        LocalAuthExceptionCode.noBiometricHardware ||
        LocalAuthExceptionCode.noCredentialsSet ||
        LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable =>
          BiometricAuthenticationOutcome.notAvailable,
        _ => BiometricAuthenticationOutcome.failed,
      };
    } on Object {
      return BiometricAuthenticationOutcome.failed;
    }
  }
}

class InMemoryBiometricAuthenticationService
    implements BiometricAuthenticationService {
  InMemoryBiometricAuthenticationService({
    this.availability = const BiometricAvailability.unsupported(),
    this.outcome = BiometricAuthenticationOutcome.notAvailable,
  });

  BiometricAvailability availability;
  BiometricAuthenticationOutcome outcome;

  @override
  Future<BiometricAvailability> checkAvailability() async => availability;

  @override
  Future<BiometricAuthenticationOutcome> authenticate({
    required String localizedReason,
  }) async {
    return outcome;
  }
}
