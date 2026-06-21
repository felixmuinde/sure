class BudgetCategoryInfo {
  final String id;
  final String name;
  final String? color;
  final String? lucideIcon;
  final String? parentId;

  const BudgetCategoryInfo({
    required this.id,
    required this.name,
    this.color,
    this.lucideIcon,
    this.parentId,
  });

  bool get isSubcategory => parentId != null;

  factory BudgetCategoryInfo.fromJson(Map<String, dynamic> json) {
    return BudgetCategoryInfo(
      id: json['id'].toString(),
      name: json['name'] as String,
      color: json['color'] as String?,
      lucideIcon: json['lucide_icon'] as String?,
      parentId: json['parent_id']?.toString(),
    );
  }
}

class BudgetCategory {
  final String id;
  final String budgetId;
  final String currency;
  final bool subcategory;
  final bool inheritsParentBudget;
  final String budgetedSpending;
  final int budgetedSpendingCents;
  final String? actualSpending;
  final int? actualSpendingCents;
  final String? availableToSpend;
  final int? availableToSpendCents;
  final BudgetCategoryInfo category;

  const BudgetCategory({
    required this.id,
    required this.budgetId,
    required this.currency,
    required this.subcategory,
    required this.inheritsParentBudget,
    required this.budgetedSpending,
    required this.budgetedSpendingCents,
    this.actualSpending,
    this.actualSpendingCents,
    this.availableToSpend,
    this.availableToSpendCents,
    required this.category,
  });

  bool get hasLimit => budgetedSpendingCents > 0;

  factory BudgetCategory.fromJson(Map<String, dynamic> json) {
    return BudgetCategory(
      id: json['id'].toString(),
      budgetId: json['budget_id'].toString(),
      currency: json['currency'] as String,
      subcategory: json['subcategory'] as bool? ?? false,
      inheritsParentBudget: json['inherits_parent_budget'] as bool? ?? false,
      budgetedSpending: json['budgeted_spending'] as String? ?? '\$0.00',
      budgetedSpendingCents: json['budgeted_spending_cents'] as int? ?? 0,
      actualSpending: json['actual_spending'] as String?,
      actualSpendingCents: json['actual_spending_cents'] as int?,
      availableToSpend: json['available_to_spend'] as String?,
      availableToSpendCents: json['available_to_spend_cents'] as int?,
      category: BudgetCategoryInfo.fromJson(
        json['category'] as Map<String, dynamic>,
      ),
    );
  }
}

class Budget {
  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final String name;
  final String currency;
  final bool initialized;
  final bool current;

  // Budget targets
  final String? budgetedSpending;
  final int? budgetedSpendingCents;
  final String? expectedIncome;
  final int? expectedIncomeCents;
  final String? allocatedSpending;
  final int? allocatedSpendingCents;

  // Actuals (only present on show endpoint)
  final String? actualSpending;
  final int? actualSpendingCents;
  final String? actualIncome;
  final int? actualIncomeCents;
  final String? availableToSpend;
  final int? availableToSpendCents;
  final String? availableToAllocate;
  final int? availableToAllocateCents;

  const Budget({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.name,
    required this.currency,
    required this.initialized,
    required this.current,
    this.budgetedSpending,
    this.budgetedSpendingCents,
    this.expectedIncome,
    this.expectedIncomeCents,
    this.allocatedSpending,
    this.allocatedSpendingCents,
    this.actualSpending,
    this.actualSpendingCents,
    this.actualIncome,
    this.actualIncomeCents,
    this.availableToSpend,
    this.availableToSpendCents,
    this.availableToAllocate,
    this.availableToAllocateCents,
  });

  // Fraction of budget spent (0.0 – ∞). Null when no budget is set.
  double? get spentFraction {
    if (budgetedSpendingCents == null || budgetedSpendingCents == 0) return null;
    return (actualSpendingCents ?? 0) / budgetedSpendingCents!;
  }

  bool get isOverBudget => (spentFraction ?? 0) > 1.0;
  bool get isNearLimit => (spentFraction ?? 0) >= 0.8 && !isOverBudget;

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'].toString(),
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      name: json['name'] as String? ?? '',
      currency: json['currency'] as String? ?? 'USD',
      initialized: json['initialized'] as bool? ?? false,
      current: json['current'] as bool? ?? false,
      budgetedSpending: json['budgeted_spending'] as String?,
      budgetedSpendingCents: json['budgeted_spending_cents'] as int?,
      expectedIncome: json['expected_income'] as String?,
      expectedIncomeCents: json['expected_income_cents'] as int?,
      allocatedSpending: json['allocated_spending'] as String?,
      allocatedSpendingCents: json['allocated_spending_cents'] as int?,
      actualSpending: json['actual_spending'] as String?,
      actualSpendingCents: json['actual_spending_cents'] as int?,
      actualIncome: json['actual_income'] as String?,
      actualIncomeCents: json['actual_income_cents'] as int?,
      availableToSpend: json['available_to_spend'] as String?,
      availableToSpendCents: json['available_to_spend_cents'] as int?,
      availableToAllocate: json['available_to_allocate'] as String?,
      availableToAllocateCents: json['available_to_allocate_cents'] as int?,
    );
  }
}
