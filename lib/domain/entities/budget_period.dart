import 'package:equatable/equatable.dart';

/// A calendar month used for monthly budget calculations.
class BudgetPeriod extends Equatable {
  const BudgetPeriod({
    required this.year,
    required this.month,
  }) : assert(month >= 1 && month <= 12, 'month must be between 1 and 12');

  factory BudgetPeriod.fromDate(DateTime date) {
    return BudgetPeriod(year: date.year, month: date.month);
  }

  final int year;
  final int month;

  DateTime get start => DateTime(year, month);

  DateTime get endExclusive =>
      month == 12 ? DateTime(year + 1) : DateTime(year, month + 1);

  BudgetPeriod get previous {
    return month == 1
        ? BudgetPeriod(year: year - 1, month: 12)
        : BudgetPeriod(year: year, month: month - 1);
  }

  BudgetPeriod get next {
    return month == 12
        ? BudgetPeriod(year: year + 1, month: 1)
        : BudgetPeriod(year: year, month: month + 1);
  }

  bool contains(DateTime date) {
    final value = DateTime(date.year, date.month, date.day);
    return !value.isBefore(start) && value.isBefore(endExclusive);
  }

  @override
  List<Object?> get props => [year, month];
}
