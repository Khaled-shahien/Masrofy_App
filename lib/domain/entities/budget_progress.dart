import 'package:equatable/equatable.dart';

import 'budget.dart';

/// Classifies budget consumption for user-facing status presentation.
enum BudgetStatus { safe, approaching, exceeded }

/// Calculated monthly progress for one category budget.
class BudgetProgress extends Equatable {
  const BudgetProgress({
    required this.budget,
    required this.spentAmount,
    required this.remainingAmount,
    required this.progressRatio,
    required this.status,
  });

  final Budget budget;
  final double spentAmount;
  final double remainingAmount;
  final double progressRatio;
  final BudgetStatus status;

  int get progressPercentage => (progressRatio * 100).round();

  @override
  List<Object?> get props => [
    budget,
    spentAmount,
    remainingAmount,
    progressRatio,
    status,
  ];
}
