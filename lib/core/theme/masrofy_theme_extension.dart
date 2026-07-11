import 'package:flutter/material.dart';

@immutable
class MasrofyThemeExtension extends ThemeExtension<MasrofyThemeExtension> {
  const MasrofyThemeExtension({
    required this.income,
    required this.expense,
    required this.warning,
    required this.success,
    required this.danger,
    required this.info,
  });

  final Color income;
  final Color expense;
  final Color warning;
  final Color success;
  final Color danger;
  final Color info;

  @override
  MasrofyThemeExtension copyWith({
    Color? income,
    Color? expense,
    Color? warning,
    Color? success,
    Color? danger,
    Color? info,
  }) {
    return MasrofyThemeExtension(
      income: income ?? this.income,
      expense: expense ?? this.expense,
      warning: warning ?? this.warning,
      success: success ?? this.success,
      danger: danger ?? this.danger,
      info: info ?? this.info,
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
      warning: Color.lerp(warning, other.warning, t)!,
      success: Color.lerp(success, other.success, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }
}
