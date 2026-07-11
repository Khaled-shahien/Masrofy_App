import 'package:equatable/equatable.dart';

import '../../../domain/entities/wallet_balance_summary.dart';

enum WalletBalancesStatus { initial, loading, ready, failure }

class WalletBalancesState extends Equatable {
  const WalletBalancesState({
    this.status = WalletBalancesStatus.initial,
    this.summaries = const [],
    this.isSaving = false,
    this.errorMessage,
  });

  final WalletBalancesStatus status;
  final List<WalletBalanceSummary> summaries;
  final bool isSaving;
  final String? errorMessage;

  WalletBalancesState copyWith({
    WalletBalancesStatus? status,
    List<WalletBalanceSummary>? summaries,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
  }) {
    return WalletBalancesState(
      status: status ?? this.status,
      summaries: summaries ?? this.summaries,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    summaries,
    isSaving,
    errorMessage,
  ];
}
