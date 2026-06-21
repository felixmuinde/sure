import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/budget.dart';
import 'api_config.dart';

class BudgetService {
  Future<Map<String, dynamic>> getBudgets({
    required String accessToken,
    int perPage = 12,
  }) async {
    try {
      final url = Uri.parse(
        '${ApiConfig.baseUrl}/api/v1/budgets?per_page=$perPage',
      );

      final response = await http
          .get(url, headers: ApiConfig.getAuthHeaders(accessToken))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final budgets = (data['budgets'] as List)
            .map((j) => Budget.fromJson(j as Map<String, dynamic>))
            .toList();
        return {'success': true, 'budgets': budgets};
      } else if (response.statusCode == 401) {
        return {'success': false, 'error': 'unauthorized'};
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'error': data['error'] ?? 'Failed to fetch budgets',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> getBudget({
    required String accessToken,
    required String budgetId,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/budgets/$budgetId');

      final response = await http
          .get(url, headers: ApiConfig.getAuthHeaders(accessToken))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return {'success': true, 'budget': Budget.fromJson(data)};
      } else if (response.statusCode == 401) {
        return {'success': false, 'error': 'unauthorized'};
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'error': data['error'] ?? 'Failed to fetch budget',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> getBudgetCategories({
    required String accessToken,
    required String budgetId,
    int perPage = 100,
  }) async {
    try {
      final url = Uri.parse(
        '${ApiConfig.baseUrl}/api/v1/budget_categories?budget_id=$budgetId&per_page=$perPage',
      );

      final response = await http
          .get(url, headers: ApiConfig.getAuthHeaders(accessToken))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final categories = (data['budget_categories'] as List)
            .map((j) => BudgetCategory.fromJson(j as Map<String, dynamic>))
            .toList();
        return {'success': true, 'categories': categories};
      } else if (response.statusCode == 401) {
        return {'success': false, 'error': 'unauthorized'};
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'error': data['error'] ?? 'Failed to fetch categories',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }
}
