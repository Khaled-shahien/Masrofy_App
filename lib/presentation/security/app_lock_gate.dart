import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/security/app_lock_service.dart';
import '../../core/theme/app_design_tokens.dart';
import '../../l10n/generated/app_localizations.dart';
import '../cubits/security/app_lock_cubit.dart';
import '../cubits/security/app_lock_state.dart';

class AppLockGate extends StatefulWidget {
  const AppLockGate({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<AppLockGate> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cubit = context.read<AppLockCubit>();
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        cubit.markBackgrounded();
      case AppLifecycleState.resumed:
        cubit.markResumed();
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppLockCubit, AppLockState>(
      builder: (context, state) {
        if (state.viewStatus == AppLockViewStatus.loading) {
          return const Scaffold(
            body: Center(child: Icon(Icons.lock_outline, size: 48)),
          );
        }
        return AnimatedSwitcher(
          duration: AppDurations.standard,
          switchInCurve: AppCurves.standard,
          switchOutCurve: AppCurves.standard,
          child: state.isLocked
              ? _AppLockScreen(key: const ValueKey('locked'), state: state)
              : KeyedSubtree(
                  key: const ValueKey('unlocked'),
                  child: widget.child,
                ),
        );
      },
    );
  }
}

class _AppLockScreen extends StatefulWidget {
  const _AppLockScreen({required this.state, super.key});

  final AppLockState state;

  @override
  State<_AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<_AppLockScreen> {
  final TextEditingController _pinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final state = widget.state;
    final now = DateTime.now();
    final isLockedOut = state.lockStatus.isLockedOut(now);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: AppRadii.pill,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Icon(
                          Icons.lock_outline,
                          size: 52,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      l10n.appLockUnlockTitle,
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      l10n.appLockUnlockBody,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextField(
                      key: const ValueKey('app-lock-pin-field'),
                      controller: _pinController,
                      enabled: !isLockedOut,
                      autofocus: true,
                      obscureText: true,
                      textDirection: TextDirection.ltr,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.appLockPinLabel,
                        prefixIcon: const Icon(Icons.pin_outlined),
                      ),
                      onSubmitted: (_) => _unlock(context),
                    ),
                    AnimatedSwitcher(
                      duration: AppDurations.fast,
                      child: state.errorMessage != null || isLockedOut
                          ? Padding(
                              key: ValueKey(isLockedOut),
                              padding: const EdgeInsets.only(
                                top: AppSpacing.sm,
                              ),
                              child: Text(
                                isLockedOut
                                    ? l10n.appLockLockedOutMessage
                                    : l10n.appLockIncorrectPin,
                                style: TextStyle(color: colorScheme.error),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    FilledButton.icon(
                      key: const ValueKey('app-lock-unlock-button'),
                      onPressed: isLockedOut ? null : () => _unlock(context),
                      icon: const Icon(Icons.lock_open_outlined),
                      label: Text(l10n.appLockUnlockAction),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _unlock(BuildContext context) async {
    final pin = _pinController.text.trim();
    if (pin.isEmpty) {
      return;
    }
    final result = await context.read<AppLockCubit>().unlock(pin);
    if (!mounted) {
      return;
    }
    if (result.outcome != PinVerificationOutcome.success) {
      _pinController.clear();
    }
  }
}
