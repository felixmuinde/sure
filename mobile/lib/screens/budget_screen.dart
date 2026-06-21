import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/budget.dart';
import '../providers/auth_provider.dart';
import '../providers/budget_provider.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final auth = context.read<AuthProvider>();
    final budget = context.read<BudgetProvider>();
    final token = await auth.getValidAccessToken();
    if (token != null && budget.budget == null && !budget.isLoading) {
      await budget.fetchCurrentBudget(accessToken: token);
    }
  }

  Future<void> _refresh() async {
    final auth = context.read<AuthProvider>();
    final budget = context.read<BudgetProvider>();
    final token = await auth.getValidAccessToken();
    if (token != null) {
      await budget.fetchCurrentBudget(accessToken: token);
    }
  }

  Future<void> _selectBudget(String budgetId) async {
    final auth = context.read<AuthProvider>();
    final budget = context.read<BudgetProvider>();
    final token = await auth.getValidAccessToken();
    if (token != null) {
      await budget.selectBudget(accessToken: token, budgetId: budgetId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<BudgetProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.budget == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.budget == null) {
            return _ErrorState(
              message: provider.errorMessage!,
              onRetry: _refresh,
            );
          }

          if (provider.budget == null) {
            return _EmptyState(onRefresh: _refresh);
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _MonthSelector(
                    budgets: provider.budgets,
                    selectedId: provider.budget!.id,
                    onSelect: _selectBudget,
                    isLoading: provider.isLoading,
                  ),
                ),
                SliverToBoxAdapter(
                  child: _SummaryCard(budget: provider.budget!),
                ),
                if (provider.parentCategories.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                      child: Text(
                        'Budget Allocations',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _CategoryList(categories: provider.parentCategories),
                  ),
                ],
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Month navigation ──────────────────────────────────────────────────────────

class _MonthSelector extends StatelessWidget {
  const _MonthSelector({
    required this.budgets,
    required this.selectedId,
    required this.onSelect,
    required this.isLoading,
  });

  final List<Budget> budgets;
  final String selectedId;
  final Future<void> Function(String id) onSelect;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (budgets.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final currentIndex = budgets.indexWhere((b) => b.id == selectedId);
    final selected = currentIndex >= 0 ? budgets[currentIndex] : budgets.first;
    final hasPrev = currentIndex < budgets.length - 1;
    final hasNext = currentIndex > 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: (hasPrev && !isLoading)
                ? () => onSelect(budgets[currentIndex + 1].id)
                : null,
            icon: const Icon(Icons.chevron_left),
            style: IconButton.styleFrom(
              foregroundColor: colorScheme.onSurface,
              disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                DateFormat('MMMM yyyy').format(selected.startDate),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: (hasNext && !isLoading)
                ? () => onSelect(budgets[currentIndex - 1].id)
                : null,
            icon: const Icon(Icons.chevron_right),
            style: IconButton.styleFrom(
              foregroundColor: colorScheme.onSurface,
              disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Summary card ──────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.budget});

  final Budget budget;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final fraction = budget.spentFraction;
    final hasSpendingBudget = fraction != null;

    Color progressColor;
    if (budget.isOverBudget) {
      progressColor = colorScheme.error;
    } else if (budget.isNearLimit) {
      progressColor = Colors.orange;
    } else {
      progressColor = colorScheme.primary;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Spent amount
            if (budget.actualSpending != null) ...[
              Text('Spent', style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
              const SizedBox(height: 4),
              Text(
                budget.actualSpending!,
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: budget.isOverBudget ? colorScheme.error : colorScheme.onSurface,
                ),
              ),
            ] else ...[
              Text(
                budget.budgetedSpending ?? '—',
                style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],

            // Progress bar
            if (hasSpendingBudget) ...[
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: fraction.clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: colorScheme.outlineVariant.withValues(alpha: 0.4),
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'of ${budget.budgetedSpending ?? '—'}',
                    style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  Text(
                    '${(fraction * 100).round()}% used',
                    style: textTheme.bodySmall?.copyWith(
                      color: progressColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ] else if (budget.budgetedSpending != null && budget.actualSpending != null) ...[
              const SizedBox(height: 4),
              Text(
                'of ${budget.budgetedSpending} budgeted',
                style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ],

            // Available to spend
            if (budget.availableToSpend != null) ...[
              const SizedBox(height: 12),
              Divider(height: 1, color: colorScheme.outlineVariant),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Available', style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                  Text(
                    budget.availableToSpend!,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: budget.isOverBudget ? colorScheme.error : colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],

            // Income row
            if (budget.actualIncome != null) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Income received', style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                  Text(
                    budget.actualIncome!,
                    style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Category list ─────────────────────────────────────────────────────────────

class _CategoryList extends StatelessWidget {
  const _CategoryList({required this.categories});

  final List<BudgetCategory> categories;

  Color _parseCategoryColor(String? hex) {
    if (hex == null || hex.isEmpty) return Colors.grey;
    final code = hex.replaceAll('#', '');
    if (code.length == 6) {
      return Color(int.parse('FF$code', radix: 16));
    }
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          indent: 16,
          endIndent: 16,
          color: colorScheme.outlineVariant,
        ),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final dotColor = _parseCategoryColor(cat.category.color);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    cat.category.name,
                    style: textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  cat.hasLimit ? cat.budgetedSpending : 'No limit',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cat.hasLimit ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Empty & error states ──────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 48,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No budgets yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a budget on the web app to start tracking your spending.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Could not load budget',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
