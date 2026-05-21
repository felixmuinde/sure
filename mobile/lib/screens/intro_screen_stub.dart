import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'chat_conversation_screen.dart';

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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _AssistantCtaCard(
            firstName: firstName,
            onTap: onStartChat,
            theme: theme,
          ),
          const SizedBox(height: 6),
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
          _IsaFinancingCard(theme: theme),
          const SizedBox(height: 12),
          _IsaInstalmentsCard(theme: theme),
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
      margin: EdgeInsets.zero,
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
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ChatConversationScreen(chatId: null),
                    ),
                  ),
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

enum IsaStatus {
  contractSigned,
  repaying,
  paused,
  serviceFeeMode,
  completed,
  defaulted,
}

extension IsaStatusDisplay on IsaStatus {
  String get label {
    switch (this) {
      case IsaStatus.contractSigned: return 'Contract Signed';
      case IsaStatus.repaying:       return 'Repaying';
      case IsaStatus.paused:         return 'Paused';
      case IsaStatus.serviceFeeMode: return 'Service Fee Mode';
      case IsaStatus.completed:      return 'Completed';
      case IsaStatus.defaulted:      return 'Defaulted';
    }
  }

  Color get color {
    switch (this) {
      case IsaStatus.contractSigned: return const Color(0xFF2196F3); // blue
      case IsaStatus.repaying:       return const Color(0xFF10A861); // green
      case IsaStatus.paused:         return const Color(0xFFFFA726); // amber
      case IsaStatus.serviceFeeMode: return const Color(0xFFFFA726); // amber
      case IsaStatus.completed:      return const Color(0xFF10A861); // green
      case IsaStatus.defaulted:      return const Color(0xFFE53935); // red
    }
  }

  IconData get icon {
    switch (this) {
      case IsaStatus.contractSigned: return Icons.verified_outlined;
      case IsaStatus.repaying:       return Icons.trending_up;
      case IsaStatus.paused:         return Icons.pause_circle_outline;
      case IsaStatus.serviceFeeMode: return Icons.work_off_outlined;
      case IsaStatus.completed:      return Icons.check_circle_outline;
      case IsaStatus.defaulted:      return Icons.warning_amber_outlined;
    }
  }
}

class _IsaFinancingCard extends StatelessWidget {
  const _IsaFinancingCard({required this.theme});

  final ThemeData theme;

  static const _green = Color(0xFF10A861);

  @override
  Widget build(BuildContext context) {
    // Placeholder values — will be replaced with real data
    // Based on Chancen Kenya ISA contract: max financing KES 268,240,
    // max repayment = financed amount × 2.6 (160% cap at year 8)
    const totalFinanced = 'KSh 268,240';
    const maxPayable = 'KSh 697,424';
    const amountPaid = 'KSh 45,000';
    const progress = 45000 / 697424; // ~6.5%
    const status = IsaStatus.contractSigned;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _green.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(_IsaIcons.financing, color: _green, size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  'ISA Financing',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: status.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(status.icon, size: 13, color: status.color),
                      const SizedBox(width: 4),
                      Text(
                        status.label,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: status.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Total Financed',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              totalFinanced,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: null,
              ),
            ),
            const SizedBox(height: 16),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                valueColor: const AlwaysStoppedAnimation<Color>(_green),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Amount paid towards maximum payable',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            Divider(height: 1, color: theme.dividerColor),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: 'Amount Paid\nTo Date',
                    value: amountPaid,
                    theme: theme,
                    align: CrossAxisAlignment.start,
                  ),
                ),
                VerticalDivider(width: 1, thickness: 1, color: theme.dividerColor),
                Expanded(
                  child: _StatItem(
                    label: 'Maximum\nAmount Payable',
                    value: maxPayable,
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

class _IsaInstalmentsCard extends StatelessWidget {
  const _IsaInstalmentsCard({required this.theme});

  final ThemeData theme;

  static const _green = Color(0xFF10A861);

  @override
  Widget build(BuildContext context) {
    // Placeholder values — will be replaced with real data
    // 108 instalments for final amounts KES 149,301–270,190 (Clause 5)
    const instalmentsPaid = 9;
    const maxInstalments = 108;
    const progress = 9 / 108;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const _CircularProgress(progress: progress),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _green.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(_IsaIcons.instalments, color: _green, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Instalments',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(height: 1, color: theme.dividerColor),
                  const SizedBox(height: 14),
                  _StatItem(
                    label: 'Paid So Far',
                    value: '$instalmentsPaid',
                    theme: theme,
                    align: CrossAxisAlignment.start,
                  ),
                  const SizedBox(height: 10),
                  _StatItem(
                    label: 'Maximum No. of Instalments',
                    value: '$maxInstalments',
                    theme: theme,
                    align: CrossAxisAlignment.start,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

abstract class _IsaIcons {
  static const financing = Icons.account_balance_outlined;
  static const instalments = Icons.calendar_month_outlined;
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
