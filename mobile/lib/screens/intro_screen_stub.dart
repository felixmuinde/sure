import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
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
  Widget build(BuildContext context) {
    super.build(context);
    return const _AccountSummaryView();
  }
}

class _AccountSummaryView extends StatelessWidget {
  const _AccountSummaryView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final firstName = context.watch<AuthProvider>().user?.firstName ?? 'there';
    final bg = theme.brightness == Brightness.light ? Colors.white : Colors.black;
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
          const SizedBox(height: 24),
          // ── My Account header ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Account',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  'Live data — Coming soon',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // ── Section cards ─────────────────────────────────────────────
          _SectionCard(
            label: 'Financing',
            theme: theme,
            children: [
              _StatItem(label: 'Maximum financed amount', value: 'Coming Soon', theme: theme, align: CrossAxisAlignment.start, tooltip: 'Total cost of education which Chancen can cover for you.'),
              const SizedBox(height: 14),
              _StatItem(label: 'Chancen amount paid to date', value: 'Coming Soon', theme: theme, align: CrossAxisAlignment.start, tooltip: 'How much Chancen has paid towards your education so far.'),
              const SizedBox(height: 14),
              _StatItem(label: 'Total commitment fees paid to date', value: 'Coming Soon', theme: theme, align: CrossAxisAlignment.start, tooltip: 'How much you have paid to date in Commitment Fees. Anything you pay now will reduce how much you owe in future repayments.'),
              const SizedBox(height: 14),
              _StatItem(label: 'Next commitment fee payment due', value: 'Coming Soon', theme: theme, align: CrossAxisAlignment.start, tooltip: 'Your next Commitment Fee instalment due. You can decide to increase this to lower your future repayments.'),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            label: 'Contract Conditions',
            theme: theme,
            children: [
              _StatItem(label: 'Repayment % of income per instalment', value: 'Coming Soon', theme: theme, align: CrossAxisAlignment.start, tooltip: 'What percentage of your net income will go towards repaying your ISA on a monthly basis.'),
              const SizedBox(height: 14),
              _StatItem(label: 'Total number of instalments', value: 'Coming Soon', theme: theme, align: CrossAxisAlignment.start, tooltip: 'The total number of instalments to be paid to fulfil your ISA contract.'),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            label: 'Repayment Summary',
            theme: theme,
            children: [
              _StatItem(label: 'Total repaid to date', value: 'Coming Soon', theme: theme, align: CrossAxisAlignment.start, tooltip: 'How much you have repaid to date towards your education.'),
              const SizedBox(height: 14),
              _StatItem(label: 'Number of instalments paid to date', value: 'Coming Soon', theme: theme, align: CrossAxisAlignment.start, tooltip: 'How many instalments you have paid to date towards your education.'),
              const SizedBox(height: 14),
              _StatItem(label: 'Outstanding instalments', value: 'Coming Soon', theme: theme, align: CrossAxisAlignment.start, tooltip: 'How many instalments you have remaining to be paid.'),
              const SizedBox(height: 14),
              _StatItem(label: 'Maximum amount payable (this year)', value: 'Coming Soon', theme: theme, align: CrossAxisAlignment.start, tooltip: 'How much you would have to repay this year to fully repay your ISA and exit your contract.'),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            label: 'Repayment Status',
            theme: theme,
            children: [
              _StatItem(label: 'Next payment due date', value: 'Coming Soon', theme: theme, align: CrossAxisAlignment.start, tooltip: 'The date by which you need to make your next repayment.'),
              const SizedBox(height: 14),
              _RepaymentStatusItem(theme: theme),
            ],
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.label,
    required this.theme,
    required this.children,
  });

  final String label;
  final ThemeData theme;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final accentColor = theme.brightness == Brightness.light ? _kDarkGreen : _kGreen;
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
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
          collapsedShape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
          title: Text(
            label,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: accentColor,
            ),
          ),
          iconColor: accentColor,
          collapsedIconColor: accentColor,
          children: children,
        ),
      ),
    );
  }
}

class _RepaymentStatusItem extends StatelessWidget {
  const _RepaymentStatusItem({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    // Placeholder — will reflect live status once data is connected.
    const statusColor = Color(0xFF10A861);
    const statusMessage = 'Congratulations on meeting the repayment due date!';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Tooltip(
        message: statusMessage,
        triggerMode: TooltipTriggerMode.tap,
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(color: statusColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              'Normal',
              style: theme.textTheme.bodySmall?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.info_outline, size: 12, color: theme.colorScheme.onSurfaceVariant),
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
    this.tooltip,
  });

  final String label;
  final String value;
  final ThemeData theme;
  final CrossAxisAlignment align;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final labelText = Text(
      label,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        height: 1.4,
      ),
    );
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: align,
        children: [
          tooltip != null
              ? Tooltip(
                  message: tooltip!,
                  triggerMode: TooltipTriggerMode.tap,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      labelText,
                      const SizedBox(width: 4),
                      Icon(
                        Icons.info_outline,
                        size: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                )
              : labelText,
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

