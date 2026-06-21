import 'package:flutter/foundation.dart';
import '../models/budget.dart';
import '../services/budget_service.dart';

class BudgetProvider with ChangeNotifier {
  final BudgetService _service = BudgetService();

  List<Budget> _budgets = [];
  Budget? _selectedBudget;
  List<BudgetCategory> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Budget> get budgets => _budgets;
  Budget? get budget => _selectedBudget;
  List<BudgetCategory> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Parent categories only (no sub-categories shown in list)
  List<BudgetCategory> get parentCategories =>
      _categories.where((c) => !c.subcategory).toList();

  Future<void> fetchCurrentBudget({required String accessToken}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Get recent budgets list
      final listResult = await _service.getBudgets(
        accessToken: accessToken,
        perPage: 12,
      );

      if (listResult['success'] != true) {
        _errorMessage = listResult['error'] as String?;
        _isLoading = false;
        notifyListeners();
        return;
      }

      _budgets = listResult['budgets'] as List<Budget>;

      if (_budgets.isEmpty) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      // 2. Load full details for the current month's budget, not just the first
      final current = _budgets.firstWhere(
        (b) => b.current,
        orElse: () => _budgets.first,
      );
      await _loadBudgetDetails(
        accessToken: accessToken,
        budgetId: current.id,
      );
    } catch (e) {
      _errorMessage = 'Something went wrong. Please try again.';
      debugPrint('BudgetProvider.fetchCurrentBudget error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectBudget({
    required String accessToken,
    required String budgetId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _loadBudgetDetails(accessToken: accessToken, budgetId: budgetId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadBudgetDetails({
    required String accessToken,
    required String budgetId,
  }) async {
    // Fetch budget details (with actuals) and categories in parallel
    final results = await Future.wait([
      _service.getBudget(accessToken: accessToken, budgetId: budgetId),
      _service.getBudgetCategories(
        accessToken: accessToken,
        budgetId: budgetId,
      ),
    ]);

    final budgetResult = results[0];
    final categoriesResult = results[1];

    if (budgetResult['success'] == true) {
      _selectedBudget = budgetResult['budget'] as Budget;
    } else {
      _errorMessage = budgetResult['error'] as String?;
    }

    if (categoriesResult['success'] == true) {
      _categories = categoriesResult['categories'] as List<BudgetCategory>;
    }
  }
}
