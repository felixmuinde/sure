import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/my_account_provider.dart';
import 'chat_conversation_screen.dart';

const Color _kGreen  = Color(0xFF84BD00);
const Color _kDarkGreen = Color(0xFF1F4834);
const Color _kPurple = Color(0xFF986EF9);

class InsightsPreviewScreen extends StatefulWidget {
  const InsightsPreviewScreen({super.key});

  @override
  State<InsightsPreviewScreen> createState() => _InsightsPreviewScreenState();
}

class _InsightsPreviewScreenState extends State<InsightsPreviewScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthProvider>();
      final apiKey = await auth.getValidAccessToken();
      if (apiKey != null && apiKey.isNotEmpty && mounted) {
        context.read<MyAccountProvider>().load(apiKey);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return const _AccountSummaryView();
  }
}

class _AccountSummaryView extends StatelessWidget {
  const _AccountSummaryView();

  String _fmt(double amount, String currency, bool loading) {
    if (loading) return '—';
    return NumberFormat.currency(symbol: '$currency ', decimalDigits: 0).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final firstName = context.watch<AuthProvider>().user?.firstName ?? 'there';
    final myAccount = context.watch<MyAccountProvider>();
    final account = myAccount.account;
    final loading = myAccount.isLoading;
    final bg = theme.brightness == Brightness.light ? Colors.white : Colors.black;

    final currency = account?.currency ?? 'KES';
    final totalFinanced = account != null ? _fmt(account.totalFinanced, currency, loading) : '—';
    final repaymentsReceived = account != null ? _fmt(account.repaymentsReceived, currency, loading) : '—';
    final isaStatus = account != null ? IsaStatus.fromString(account.status) : null;

    return ColoredBox(
      color: bg,
      child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _GreetingCard(firstName: firstName, theme: theme),
          const SizedBox(height: 8),
          _AskAnythingTile(theme: theme),
          const SizedBox(height: 20),
          _SectionHeaderTile(theme: theme),
          const SizedBox(height: 16),
          _IsaFinancingCard(
            theme: theme,
            amountPaid: repaymentsReceived,
            totalFinanced: totalFinanced,
            isaStatus: isaStatus,
            loading: loading,
          ),
          const SizedBox(height: 12),
          _IsaInstalmentsCard(
            theme: theme,
            instalmentsPaid: account?.installmentsPaid ?? 0,
            maxInstalments: account?.maxInstallments ?? 0,
            loading: loading,
          ),
        ],
      ),
    ),
    );
  }
}

class _GreetingCard extends StatelessWidget {
  const _GreetingCard({required this.firstName, required this.theme});

  final String firstName;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.light ? Colors.white : Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi, $firstName!',
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Your partner from learning to earning.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AskAnythingTile extends StatelessWidget {
  const _AskAnythingTile({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _kPurple.withValues(alpha: 0.25),
            blurRadius: 0,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: Card(
      margin: EdgeInsets.zero,
      color: theme.brightness == Brightness.light ? Colors.white : Colors.black,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const ChatConversationScreen(chatId: null),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _kPurple.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: _kPurple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ask me anything',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: _kPurple,
                      ),
                    ),
                    Text(
                      'Get instant answers about your ISA',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}

class _SectionHeaderTile extends StatelessWidget {
  const _SectionHeaderTile({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.light ? Colors.white : Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      child: Text(
        'My Account',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
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
  defaulted;

  static IsaStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'contract_signed':
      case 'graduated':
        return IsaStatus.contractSigned;
      case 'repaying':
        return IsaStatus.repaying;
      case 'paused':
        return IsaStatus.paused;
      case 'service_fee_mode':
        return IsaStatus.serviceFeeMode;
      case 'completed':
        return IsaStatus.completed;
      case 'defaulted':
        return IsaStatus.defaulted;
      default:
        return IsaStatus.repaying;
    }
  }
}

extension IsaStatusDisplay on IsaStatus {
  String get label {
    switch (this) {
      case IsaStatus.contractSigned: return 'Graduated';
      case IsaStatus.repaying:       return 'Repaying';
      case IsaStatus.paused:         return 'Paused';
      case IsaStatus.serviceFeeMode: return 'Service Fee Mode';
      case IsaStatus.completed:      return 'Completed';
      case IsaStatus.defaulted:      return 'Defaulted';
    }
  }

  Color get color {
    switch (this) {
      case IsaStatus.contractSigned: return _kDarkGreen;
      case IsaStatus.repaying:       return const Color(0xFF10A861);
      case IsaStatus.paused:         return const Color(0xFFFFA726);
      case IsaStatus.serviceFeeMode: return const Color(0xFFFFA726);
      case IsaStatus.completed:      return const Color(0xFF10A861);
      case IsaStatus.defaulted:      return const Color(0xFFE53935);
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
  const _IsaFinancingCard({
    required this.theme,
    required this.amountPaid,
    required this.totalFinanced,
    required this.loading,
    this.isaStatus,
  });

  final ThemeData theme;
  final String amountPaid;
  final String totalFinanced;
  final bool loading;
  final IsaStatus? isaStatus;

  @override
  Widget build(BuildContext context) {
    final status = isaStatus ?? IsaStatus.repaying;
    final statusColor = (status == IsaStatus.contractSigned && theme.brightness == Brightness.dark)
        ? _kGreen
        : status.color;

    return Container(
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.light ? Colors.white : Colors.black,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (theme.brightness == Brightness.light ? _kDarkGreen : _kGreen).withValues(alpha: 0.18),
            blurRadius: 0,
            offset: const Offset(4, 4),
          ),
        ],
      ),
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
                    color: _kGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(_IsaIcons.financing, color: _kGreen, size: 18),
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
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(status.icon, size: 13, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        status.label,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: statusColor,
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
              'Repayments Received',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              amountPaid,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 20),
            Divider(height: 1, color: theme.dividerColor),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _StatItem(
                    label: 'Repayments\nReceived',
                    value: amountPaid,
                    theme: theme,
                    align: CrossAxisAlignment.start,
                  ),
                ),
                VerticalDivider(width: 1, thickness: 1, color: theme.dividerColor),
                Expanded(
                  child: _StatItem(
                    label: 'Total\nFinanced',
                    value: totalFinanced,
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
  const _IsaInstalmentsCard({
    required this.theme,
    required this.instalmentsPaid,
    required this.maxInstalments,
    required this.loading,
  });

  final ThemeData theme;
  final int instalmentsPaid;
  final int maxInstalments;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final progress = maxInstalments > 0 ? instalmentsPaid / maxInstalments : 0.0;
    final progressLabel = loading ? '—' : '$instalmentsPaid\n/ $maxInstalments';

    return Container(
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.light ? Colors.white : Colors.black,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (theme.brightness == Brightness.light ? _kDarkGreen : _kGreen).withValues(alpha: 0.18),
            blurRadius: 0,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            _CircularProgress(progress: progress, color: _kGreen, label: progressLabel),
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
                          color: _kGreen.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(_IsaIcons.instalments, color: _kGreen, size: 18),
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
                    value: loading ? '—' : '$instalmentsPaid',
                    theme: theme,
                    align: CrossAxisAlignment.start,
                  ),
                  const SizedBox(height: 10),
                  _StatItem(
                    label: 'Maximum No. of Instalments',
                    value: loading ? '—' : '$maxInstalments',
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
  const _CircularProgress({required this.progress, this.color = _kGreen, this.label = ''});

  final double progress;
  final Color color;
  final String label;

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
          progressColor: color,
        ),
        child: Center(
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
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
    required this.progressColor,
  });

  final double progress;
  final Color trackColor;
  final Color progressColor;

  static const _strokeWidth = 8.0;

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
      ..color = progressColor
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
