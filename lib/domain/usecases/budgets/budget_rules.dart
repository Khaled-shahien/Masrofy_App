/// Shared business rules for monthly budgets.
class BudgetRules {
  const BudgetRules._();

  /// A budget is approaching its limit when spending reaches 80%.
  static const approachingLimitRatio = 0.8;
}
