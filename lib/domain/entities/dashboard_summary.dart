import 'package:equatable/equatable.dart';

class DashboardPeriodTotals extends Equatable {
  const DashboardPeriodTotals({
    required this.income,
    required this.expense,
  });

  final double income;
  final double expense;

  double get net => income - expense;

  @override
  List<Object?> get props => [income, expense];
}

class DashboardSummary extends Equatable {
  const DashboardSummary({
    required this.today,
    required this.week,
    required this.month,
  });

  final DashboardPeriodTotals today;
  final DashboardPeriodTotals week;
  final DashboardPeriodTotals month;

  @override
  List<Object?> get props => [today, week, month];
}
