import 'package:flutter/material.dart';

@immutable
class MasrofyThemeExtension extends ThemeExtension<MasrofyThemeExtension> {
  const MasrofyThemeExtension({
    required this.income,
    required this.expense,
    required this.savings,
    required this.warning,
    required this.success,
    required this.danger,
    required this.info,
    required this.budgetSafe,
    required this.budgetWarning,
    required this.budgetExceeded,
    required this.elevatedSurface,
    required this.cardBorder,
    required this.divider,
    required this.subtleText,
    required this.maskedAmount,
    required this.disabled,
  });

  final Color income;
  final Color expense;
  final Color savings;
  final Color warning;
  final Color success;
  final Color danger;
  final Color info;
  final Color budgetSafe;
  final Color budgetWarning;
  final Color budgetExceeded;
  final Color elevatedSurface;
  final Color cardBorder;
  final Color divider;
  final Color subtleText;
  final Color maskedAmount;
  final Color disabled;

  @override
  MasrofyThemeExtension copyWith({
    Color? income,
    Color? expense,
    Color? savings,
    Color? warning,
    Color? success,
    Color? danger,
    Color? info,
    Color? budgetSafe,
    Color? budgetWarning,
    Color? budgetExceeded,
    Color? elevatedSurface,
    Color? cardBorder,
    Color? divider,
    Color? subtleText,
    Color? maskedAmount,
    Color? disabled,
  }) {
    return MasrofyThemeExtension(
      income: income ?? this.income,
      expense: expense ?? this.expense,
      savings: savings ?? this.savings,
      warning: warning ?? this.warning,
      success: success ?? this.success,
      danger: danger ?? this.danger,
      info: info ?? this.info,
      budgetSafe: budgetSafe ?? this.budgetSafe,
      budgetWarning: budgetWarning ?? this.budgetWarning,
      budgetExceeded: budgetExceeded ?? this.budgetExceeded,
      elevatedSurface: elevatedSurface ?? this.elevatedSurface,
      cardBorder: cardBorder ?? this.cardBorder,
      divider: divider ?? this.divider,
      subtleText: subtleText ?? this.subtleText,
      maskedAmount: maskedAmount ?? this.maskedAmount,
      disabled: disabled ?? this.disabled,
    );
  }

  @override
  MasrofyThemeExtension lerp(
    ThemeExtension<MasrofyThemeExtension>? other,
    double t,
  ) {
    if (other is! MasrofyThemeExtension) {
      return this;
    }

    return MasrofyThemeExtension(
      income: Color.lerp(income, other.income, t)!,
      expense: Color.lerp(expense, other.expense, t)!,
      savings: Color.lerp(savings, other.savings, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      success: Color.lerp(success, other.success, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      info: Color.lerp(info, other.info, t)!,
      budgetSafe: Color.lerp(budgetSafe, other.budgetSafe, t)!,
      budgetWarning: Color.lerp(budgetWarning, other.budgetWarning, t)!,
      budgetExceeded: Color.lerp(budgetExceeded, other.budgetExceeded, t)!,
      elevatedSurface: Color.lerp(elevatedSurface, other.elevatedSurface, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      subtleText: Color.lerp(subtleText, other.subtleText, t)!,
      maskedAmount: Color.lerp(maskedAmount, other.maskedAmount, t)!,
      disabled: Color.lerp(disabled, other.disabled, t)!,
    );
  }
}
