import 'package:intl/intl.dart';

import '../../../domain/entities/financial_transaction.dart';
import '../../../domain/entities/transaction_type.dart';

String formatMoney(
  num value, {
  String localeName = 'ar',
  String currencySymbol = 'ج.م',
}) {
  return NumberFormat.currency(
    locale: _intlLocale(localeName),
    symbol: currencySymbol,
    decimalDigits: 0,
  ).format(value);
}

String formatTransactionAmount(
  FinancialTransaction transaction, {
  String localeName = 'ar',
  String currencySymbol = 'ج.م',
}) {
  final sign = transaction.type == TransactionType.expense ? '-' : '+';
  final amount = formatMoney(
    transaction.amount,
    localeName: localeName,
    currencySymbol: currencySymbol,
  );
  return '$sign $amount';
}

String formatDay(DateTime date, {String localeName = 'ar'}) {
  return DateFormat.yMMMMEEEEd(_intlLocale(localeName)).format(date);
}

String formatShortDate(DateTime date, {String localeName = 'ar'}) {
  return DateFormat.MMMd(_intlLocale(localeName)).format(date);
}

bool isSameDay(DateTime left, DateTime right) {
  return left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}

bool isSameMonth(DateTime left, DateTime right) {
  return left.year == right.year && left.month == right.month;
}

bool isInCurrentWeek(DateTime date, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final weekStart = today.subtract(Duration(days: today.weekday - 1));
  final nextWeek = weekStart.add(const Duration(days: 7));
  final value = DateTime(date.year, date.month, date.day);
  return !value.isBefore(weekStart) && value.isBefore(nextWeek);
}

String _intlLocale(String localeName) {
  return switch (localeName) {
    'en' => 'en_US',
    _ => 'ar_EG',
  };
}
