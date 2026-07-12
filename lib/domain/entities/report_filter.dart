import 'package:equatable/equatable.dart';

import 'transaction_type.dart';
import 'wallet_type.dart';

enum ReportPeriodType { today, thisWeek, thisMonth, previousMonth, custom }

/// Inclusive start and exclusive end date range for report calculations.
class ReportDateRange extends Equatable {
  const ReportDateRange({
    required this.start,
    required this.endExclusive,
  });

  final DateTime start;
  final DateTime endExclusive;

  int get dayCount {
    final days = endExclusive.difference(start).inDays;
    return days <= 0 ? 1 : days;
  }

  ReportDateRange get previousEquivalent {
    final duration = endExclusive.difference(start);
    final previousEnd = start;
    return ReportDateRange(
      start: previousEnd.subtract(duration),
      endExclusive: previousEnd,
    );
  }

  bool contains(DateTime date) {
    final value = DateTime(date.year, date.month, date.day);
    return !value.isBefore(start) && value.isBefore(endExclusive);
  }

  @override
  List<Object?> get props => [start, endExclusive];
}

/// Immutable filter used to calculate local financial reports.
class ReportFilter extends Equatable {
  const ReportFilter({
    this.periodType = ReportPeriodType.thisMonth,
    this.customStart,
    this.customEnd,
    this.categoryId,
    this.wallet,
    this.transactionType,
  });

  final ReportPeriodType periodType;
  final DateTime? customStart;
  final DateTime? customEnd;
  final String? categoryId;
  final WalletType? wallet;
  final TransactionType? transactionType;

  ReportDateRange resolveDateRange(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    return switch (periodType) {
      ReportPeriodType.today => ReportDateRange(
        start: today,
        endExclusive: today.add(const Duration(days: 1)),
      ),
      ReportPeriodType.thisWeek => _weekRange(today),
      ReportPeriodType.thisMonth => _monthRange(today.year, today.month),
      ReportPeriodType.previousMonth =>
        today.month == 1
            ? _monthRange(today.year - 1, 12)
            : _monthRange(today.year, today.month - 1),
      ReportPeriodType.custom => _customRange(today, customStart, customEnd),
    };
  }

  ReportFilter copyWith({
    ReportPeriodType? periodType,
    DateTime? customStart,
    DateTime? customEnd,
    String? categoryId,
    WalletType? wallet,
    TransactionType? transactionType,
    bool clearCustomRange = false,
    bool clearCategory = false,
    bool clearWallet = false,
    bool clearTransactionType = false,
  }) {
    return ReportFilter(
      periodType: periodType ?? this.periodType,
      customStart: clearCustomRange ? null : customStart ?? this.customStart,
      customEnd: clearCustomRange ? null : customEnd ?? this.customEnd,
      categoryId: clearCategory ? null : categoryId ?? this.categoryId,
      wallet: clearWallet ? null : wallet ?? this.wallet,
      transactionType: clearTransactionType
          ? null
          : transactionType ?? this.transactionType,
    );
  }

  @override
  List<Object?> get props => [
    periodType,
    customStart,
    customEnd,
    categoryId,
    wallet,
    transactionType,
  ];
}

ReportDateRange _weekRange(DateTime today) {
  final start = today.subtract(Duration(days: today.weekday - 1));
  return ReportDateRange(
    start: start,
    endExclusive: start.add(const Duration(days: 7)),
  );
}

ReportDateRange _monthRange(int year, int month) {
  return ReportDateRange(
    start: DateTime(year, month),
    endExclusive: month == 12 ? DateTime(year + 1) : DateTime(year, month + 1),
  );
}

ReportDateRange _customRange(
  DateTime fallback,
  DateTime? customStart,
  DateTime? customEnd,
) {
  final fallbackStart = DateTime(fallback.year, fallback.month, fallback.day);
  final startValue = customStart == null
      ? fallbackStart
      : DateTime(customStart.year, customStart.month, customStart.day);
  final endValue = customEnd == null
      ? startValue
      : DateTime(customEnd.year, customEnd.month, customEnd.day);
  final start = startValue.isAfter(endValue) ? endValue : startValue;
  final inclusiveEnd = startValue.isAfter(endValue) ? startValue : endValue;
  return ReportDateRange(
    start: start,
    endExclusive: inclusiveEnd.add(const Duration(days: 1)),
  );
}
