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
