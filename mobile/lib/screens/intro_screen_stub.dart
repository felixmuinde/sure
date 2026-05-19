import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class InsightsPreviewScreen extends StatefulWidget {
  const InsightsPreviewScreen({super.key, this.onStartChat});

  final VoidCallback? onStartChat;

  @override
  State<InsightsPreviewScreen> createState() => _InsightsPreviewScreenState();
}

class _InsightsPreviewScreenState extends State<InsightsPreviewScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _AccountSummaryView(onStartChat: widget.onStartChat);
  }
}

class _AccountSummaryView extends StatelessWidget {
  const _AccountSummaryView({this.onStartChat});

  final VoidCallback? onStartChat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final firstName =
        context.watch<AuthProvider>().user?.firstName ?? 'there';
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AssistantCtaCard(
            firstName: firstName,
            onTap: onStartChat,
            theme: theme,
          ),
          const SizedBox(height: 20),
          Text(
            'My Account',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Live data coming soon',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          _IsaCard(theme: theme),
        ],
      ),
    );
  }
}

class _AssistantCtaCard extends StatelessWidget {
  const _AssistantCtaCard({
    required this.firstName,
    required this.theme,
    this.onTap,
  });

  final String firstName;
  final ThemeData theme;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;
    final gradientStart =
        isDark ? const Color(0xFF1B2A1E) : const Color(0xFFE8F5EE);
    final gradientEnd =
        isDark ? const Color(0xFF1A1A2E) : const Color(0xFFEEF0FB);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [gradientStart, gradientEnd],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(
                  'assets/images/companion-logo.svg',
                  width: 48,
                  height: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Hi, $firstName!',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Ask me anything about your finances — I\'m here to help.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                  label: const Text('Start a conversation'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IsaCard extends StatelessWidget {
  const _IsaCard({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ISA Balance',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'KSh 15,000',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10A861).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Excellent',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: const Color(0xFF10A861),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const _CircularProgress(progress: 0.6),
              ],
            ),
            const SizedBox(height: 20),
            Divider(height: 1, color: theme.dividerColor),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: 'Tuition Paid',
                    value: 'KSh 9,000',
                    theme: theme,
                    align: CrossAxisAlignment.start,
                  ),
                ),
                VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: theme.dividerColor,
                ),
                Expanded(
                  child: _StatItem(
                    label: 'Repayments\nReceived',
                    value: 'KSh 6,000',
                    theme: theme,
                    align: CrossAxisAlignment.end,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.theme,
    required this.align,
  });

  final String label;
  final String value;
  final ThemeData theme;
  final CrossAxisAlignment align;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircularProgress extends StatelessWidget {
  const _CircularProgress({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 76,
      height: 76,
      child: CustomPaint(
        painter: _CircularProgressPainter(
          progress: progress,
          trackColor: theme.colorScheme.outlineVariant,
        ),
        child: Center(
          child: Text(
            '${(progress * 100).round()}%',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  _CircularProgressPainter({
    required this.progress,
    required this.trackColor,
  });

  final double progress;
  final Color trackColor;

  static const _strokeWidth = 8.0;
  static const _progressColor = Color(0xFF10A861);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - _strokeWidth / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = _strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    final progressPaint = Paint()
      ..color = _progressColor
      ..strokeWidth = _strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_CircularProgressPainter old) =>
      old.progress != progress || old.trackColor != trackColor;
}

// ---------------------------------------------------------------------------
// Spending Insights section
// ---------------------------------------------------------------------------

class _SpendingCategory {
  const _SpendingCategory({
    required this.name,
    required this.amount,
    required this.color,
  });
  final String name;
  final double amount;
  final Color color;
}

const _kSpendingCategories = [
  _SpendingCategory(name: 'Family Support', amount: 1100, color: Color(0xFF6172F3)),
  _SpendingCategory(name: 'Transport',      amount: 800,  color: Color(0xFFF97316)),
  _SpendingCategory(name: 'Groceries',      amount: 700,  color: Color(0xFF10A861)),
  _SpendingCategory(name: 'Matatu & Boda',  amount: 556,  color: Color(0xFFEAB308)),
  _SpendingCategory(name: 'Eating Out',     amount: 350,  color: Color(0xFFEF4444)),
  _SpendingCategory(name: 'Airtime',        amount: 350,  color: Color(0xFF8B5CF6)),
  _SpendingCategory(name: 'Clothing',       amount: 200,  color: Color(0xFF06B6D4)),
  _SpendingCategory(name: 'Uncategorised',  amount: 1457, color: Color(0xFF737373)),
];

class _SpendingInsightsCard extends StatelessWidget {
  const _SpendingInsightsCard({required this.theme});

  final ThemeData theme;

  double get _totalSpend =>
      _kSpendingCategories.fold(0.0, (sum, c) => sum + c.amount);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Spending Insights',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.dividerColor),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Sample data',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Based on average student spending in Nairobi',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 20),

            // Monthly summary row
            _MonthlySummaryRow(theme: theme),

            const SizedBox(height: 20),
            Divider(height: 1, color: theme.dividerColor),
            const SizedBox(height: 16),

            Text(
              'Where the money goes',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),

            // Donut chart
            _DonutChart(
              categories: _kSpendingCategories,
              totalSpend: _totalSpend,
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthlySummaryRow extends StatelessWidget {
  const _MonthlySummaryRow({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCell(
            label: 'Income',
            value: 'KSh 7,000',
            valueColor: const Color(0xFF10A861),
            theme: theme,
          ),
        ),
        Expanded(
          child: _SummaryCell(
            label: 'Expenses',
            value: 'KSh 5,513',
            valueColor: theme.colorScheme.error,
            theme: theme,
          ),
        ),
        Expanded(
          child: _SummaryCell(
            label: 'Surplus',
            value: 'KSh 1,488',
            valueColor: const Color(0xFF10A861),
            theme: theme,
          ),
        ),
      ],
    );
  }
}

class _SummaryCell extends StatelessWidget {
  const _SummaryCell({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.theme,
  });

  final String label;
  final String value;
  final Color valueColor;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Donut chart + legend
// ---------------------------------------------------------------------------

class _DonutChart extends StatelessWidget {
  const _DonutChart({
    required this.categories,
    required this.totalSpend,
    required this.theme,
  });

  final List<_SpendingCategory> categories;
  final double totalSpend;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 180,
          height: 180,
          child: CustomPaint(
            painter: _DonutPainter(
              categories: categories,
              totalSpend: totalSpend,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'KSh 5,513',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'total spent',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Two-column legend
        _DonutLegend(
          categories: categories,
          totalSpend: totalSpend,
          theme: theme,
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.categories, required this.totalSpend});

  final List<_SpendingCategory> categories;
  final double totalSpend;

  static const _strokeWidth = 22.0;
  static const _gap = 0.025; // radians gap between segments

  @override
  void paint(Canvas canvas, Size size) {
    if (totalSpend <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - _strokeWidth / 2;
    double startAngle = -math.pi / 2;

    for (final cat in categories) {
      final sweep =
          (cat.amount / totalSpend) * 2 * math.pi - _gap;
      if (sweep <= 0) continue;

      final paint = Paint()
        ..color = cat.color
        ..strokeWidth = _strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle + _gap / 2,
        sweep,
        false,
        paint,
      );

      startAngle += sweep + _gap;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) => false;
}

class _DonutLegend extends StatelessWidget {
  const _DonutLegend({
    required this.categories,
    required this.totalSpend,
    required this.theme,
  });

  final List<_SpendingCategory> categories;
  final double totalSpend;
  final ThemeData theme;

  String _fmt(double v) => v
      .toInt()
      .toString()
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');

  @override
  Widget build(BuildContext context) {
    // Split into two columns
    final left = <_SpendingCategory>[];
    final right = <_SpendingCategory>[];
    for (var i = 0; i < categories.length; i++) {
      (i.isEven ? left : right).add(categories[i]);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _LegendColumn(items: left, totalSpend: totalSpend, theme: theme, fmt: _fmt)),
        const SizedBox(width: 8),
        Expanded(child: _LegendColumn(items: right, totalSpend: totalSpend, theme: theme, fmt: _fmt)),
      ],
    );
  }
}

class _LegendColumn extends StatelessWidget {
  const _LegendColumn({
    required this.items,
    required this.totalSpend,
    required this.theme,
    required this.fmt,
  });

  final List<_SpendingCategory> items;
  final double totalSpend;
  final ThemeData theme;
  final String Function(double) fmt;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((cat) {
        final pct = totalSpend > 0
            ? (cat.amount / totalSpend * 100).round()
            : 0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: cat.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cat.name,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'KSh ${fmt(cat.amount)} · $pct%',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}