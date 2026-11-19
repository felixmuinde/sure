import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/isa_transaction.dart';
import '../providers/auth_provider.dart';
import '../services/isa_transactions_service.dart';
import '../services/my_account_service.dart'
    show EmailVerificationRequiredException;
import '../theme/sure_colors.dart';
import '../theme/sure_spacing.dart';
import '../theme/sure_tokens.dart';
import '../widgets/money_text.dart';
import '../widgets/sure_button.dart';
import '../widgets/sure_card.dart';
import '../widgets/sure_icon.dart';
import '../widgets/sure_list_group.dart';
import '../widgets/verify_email_card.dart';

class IsaTransactionsScreen extends StatefulWidget {
  const IsaTransactionsScreen({super.key});

  @override
  State<IsaTransactionsScreen> createState() => _IsaTransactionsScreenState();
}

class _IsaTransactionsScreenState extends State<IsaTransactionsScreen> {
  final _service = IsaTransactionsService();

  List<IsaTransaction>? _transactions;
  bool _loading = true;
  String? _error;
  bool _verificationRequired = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _verificationRequired = false;
    });
    try {
      final token = await context.read<AuthProvider>().getValidAccessToken();
      if (token == null) {
        if (mounted) setState(() => _loading = false);
        return;
      }
      final result = await _service.fetchTransactions(token);
      if (mounted) {
        setState(() {
          _transactions = result;
          _loading = false;
        });
      }
    } on EmailVerificationRequiredException {
      if (mounted) {
        setState(() {
          _transactions = null;
          _verificationRequired = true;
          _loading = false;
        });
      }
    } on IsaTransactionsUnavailableException {
      if (mounted) {
        setState(() {
          _error = AppLocalizations.of(context).paymentsUnavailable;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = AppLocalizations.of(context).paymentsLoadError;
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody(context);
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_verificationRequired) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [VerifyEmailCard(onVerified: _load)],
      );
    }

    if (_error != null) {
      return _buildEmpty(context, message: _error!);
    }

    final txns = _transactions ?? [];
    if (txns.isEmpty) {
      return _buildEmpty(
        context,
        message: AppLocalizations.of(context).paymentsEmpty,
      );
    }

    return PaymentsList(
      transactions: txns,
      onRefresh: _load,
    );
  }

  Widget _buildEmpty(BuildContext context, {required String message}) {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        Center(
          child: Column(
            children: [
              SureIcon(
                SureIcons.receipt,
                size: 48,
                color: SureColors.of(context).palette.textSubdued,
              ),
              const SizedBox(height: SureSpacing.lg),
              Text(
                message,
                style: TextStyle(
                  color: SureColors.of(context).palette.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PaymentsList extends StatelessWidget {
  const PaymentsList({
    super.key,
    required this.transactions,
    required this.onRefresh,
  });

  final List<IsaTransaction> transactions;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final palette = SureColors.of(context).palette;
    final grouped = <IsaPaymentCategory, List<IsaTransaction>>{
      for (final category in IsaPaymentCategory.values) category: [],
    };
    for (final transaction in transactions) {
      grouped[transaction.category]!.add(transaction);
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          SureSpacing.xl,
          SureSpacing.xl,
          SureSpacing.xl,
          SureSpacing.huge,
        ),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Payments',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                tooltip: l.paymentsExplainerAction,
                onPressed: () => _showPaymentsExplainer(context),
                icon: SureIcon(
                  SureIcons.circleInfo,
                  size: SureIconSize.lg,
                  color: palette.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: SureSpacing.md),
          ..._section(
            context,
            category: IsaPaymentCategory.balanceReduction,
            transactions: grouped[IsaPaymentCategory.balanceReduction]!,
          ),
          ..._section(
            context,
            category: IsaPaymentCategory.chancenFunding,
            transactions: grouped[IsaPaymentCategory.chancenFunding]!,
          ),
          ..._section(
            context,
            category: IsaPaymentCategory.fees,
            transactions: grouped[IsaPaymentCategory.fees]!,
          ),
          ..._section(
            context,
            category: IsaPaymentCategory.penalties,
            transactions: grouped[IsaPaymentCategory.penalties]!,
          ),
          ..._section(
            context,
            category: IsaPaymentCategory.other,
            transactions: grouped[IsaPaymentCategory.other]!,
          ),
        ],
      ),
    );
  }

  List<Widget> _section(
    BuildContext context, {
    required IsaPaymentCategory category,
    required List<IsaTransaction> transactions,
  }) {
    if (transactions.isEmpty) return const [];

    return [
      SureListGroup(
        header: _sectionTitle(context, category),
        children: [
          for (final transaction in transactions)
            _PaymentRow(transaction: transaction),
        ],
      ),
      const SizedBox(height: SureSpacing.xxxl),
    ];
  }
}

Future<void> _showPaymentsExplainer(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) {
      final l = AppLocalizations.of(context);
      final palette = SureColors.of(context).palette;

      return Padding(
        padding: const EdgeInsets.fromLTRB(
          SureSpacing.xl,
          0,
          SureSpacing.xl,
          SureSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SureIcon(
              SureIcons.circleInfo,
              size: SureIconSize.xl,
              color: palette.info,
            ),
            const SizedBox(height: SureSpacing.lg),
            Text(
              l.paymentsExplainerTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: SureTokens.weightSemibold,
                  ),
            ),
            const SizedBox(height: SureSpacing.sm),
            Text(
              l.paymentsExplainerBody,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: palette.textSecondary,
                  ),
            ),
            const SizedBox(height: SureSpacing.xxl),
            SureButton(
              label: l.commonClose,
              onPressed: () => Navigator.pop(context),
              variant: SureButtonVariant.secondary,
              size: SureButtonSize.lg,
              fullWidth: true,
            ),
          ],
        ),
      );
    },
  );
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.transaction});

  final IsaTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final palette = SureColors.of(context).palette;

    return SureListRow(
      leading: _PaymentTypeIcon(category: transaction.category),
      title: _paymentTitle(context, transaction),
      subtitle: _formatDate(transaction.paymentDate),
      onTap: () => _showPaymentDetails(context, transaction),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _formatAmount(transaction),
            style: SureMoney.tabular(
              Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: SureTokens.weightSemibold,
                  ),
            ),
          ),
          const SizedBox(width: SureSpacing.md),
          SureIcon(
            SureIcons.chevronRight,
            size: SureIconSize.md,
            color: palette.textSubdued,
          ),
        ],
      ),
    );
  }
}

class _PaymentTypeIcon extends StatelessWidget {
  const _PaymentTypeIcon({required this.category});

  final IsaPaymentCategory category;

  @override
  Widget build(BuildContext context) {
    final palette = SureColors.of(context).palette;
    final (icon, foreground, background) = switch (category) {
      IsaPaymentCategory.balanceReduction => (
          SureIcons.trendingDown,
          palette.success,
          palette.success.withValues(alpha: 0.1),
        ),
      IsaPaymentCategory.chancenFunding => (
          SureIcons.handCoins,
          palette.info,
          palette.info.withValues(alpha: 0.1),
        ),
      IsaPaymentCategory.fees => (
          SureIcons.receipt,
          palette.textSecondary,
          palette.surfaceInset,
        ),
      IsaPaymentCategory.penalties => (
          SureIcons.circleAlert,
          palette.warning,
          palette.warning.withValues(alpha: 0.1),
        ),
      IsaPaymentCategory.other => (
          SureIcons.receipt,
          palette.textSecondary,
          palette.surfaceInset,
        ),
    };

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(SureTokens.radiusLg),
      ),
      child: SureIcon(icon, size: SureIconSize.md, color: foreground),
    );
  }
}

Future<void> _showPaymentDetails(
  BuildContext context,
  IsaTransaction transaction,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) {
      final l = AppLocalizations.of(context);
      final palette = SureColors.of(context).palette;

      return SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          SureSpacing.xl,
          0,
          SureSpacing.xl,
          SureSpacing.xl + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l.paymentsDetailTitle,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: SureTokens.weightSemibold,
                  ),
            ),
            const SizedBox(height: SureSpacing.xxl),
            Center(
              child: Column(
                children: [
                  _PaymentTypeIcon(category: transaction.category),
                  const SizedBox(height: SureSpacing.lg),
                  Text(
                    _formatAmount(transaction),
                    style: SureMoney.tabular(
                      Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: SureTokens.weightSemibold,
                          ),
                    ),
                  ),
                  const SizedBox(height: SureSpacing.xs),
                  Text(
                    _sectionTitle(context, transaction.category),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: palette.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SureSpacing.xxxl),
            SureCard(
              elevated: false,
              child: Text(
                _categoryDescription(context, transaction.category),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: palette.textSecondary,
                    ),
              ),
            ),
            const SizedBox(height: SureSpacing.xxxl),
            SureListGroup(
              children: [
                SureListRow(
                  title: l.paymentsDetailRecordedType,
                  trailing: Text(_paymentTitle(context, transaction)),
                ),
                SureListRow(
                  title: l.paymentsDetailDate,
                  trailing: Text(_formatDate(transaction.paymentDate)),
                ),
                SureListRow(
                  title: l.paymentsDetailCurrency,
                  trailing: Text(
                    transaction.currency.trim().isEmpty
                        ? l.paymentsUnknownValue
                        : transaction.currency,
                  ),
                ),
              ],
            ),
            const SizedBox(height: SureSpacing.xxxl),
            SureButton(
              label: l.commonClose,
              onPressed: () => Navigator.pop(context),
              variant: SureButtonVariant.secondary,
              size: SureButtonSize.lg,
              fullWidth: true,
            ),
          ],
        ),
      );
    },
  );
}

String _formatAmount(IsaTransaction transaction) {
  return NumberFormat.currency(
    symbol: transaction.currency.isEmpty ? '' : '${transaction.currency} ',
    decimalDigits: transaction.amount % 1 == 0 ? 0 : 2,
  ).format(transaction.amount);
}

String _formatDate(String raw) {
  if (raw.isEmpty) return '—';
  try {
    final date = DateTime.parse(raw);
    return DateFormat('dd MMM yyyy').format(date);
  } catch (_) {
    return raw;
  }
}

String _sectionTitle(BuildContext context, IsaPaymentCategory category) {
  final l = AppLocalizations.of(context);
  return switch (category) {
    IsaPaymentCategory.balanceReduction => l.paymentsBalanceReductionSection,
    IsaPaymentCategory.chancenFunding => l.paymentsChancenFundingSection,
    IsaPaymentCategory.fees => l.paymentsFeesSection,
    IsaPaymentCategory.penalties => l.paymentsPenaltiesSection,
    IsaPaymentCategory.other => l.paymentsOtherSection,
  };
}

String _paymentTitle(BuildContext context, IsaTransaction transaction) {
  final l = AppLocalizations.of(context);
  return switch (transaction.normalizedPaymentType) {
    'admin fee' => l.paymentsItemAdministrationFee,
    'application fee' || 'application fees' => l.paymentsItemApplicationFee,
    'deposit' => l.paymentsItemDeposit,
    'dropout penalty' || 'drop out penalty' => l.paymentsItemDropoutPenalty,
    'penalty fee' => l.paymentsItemPenaltyFee,
    'pei payment' => l.paymentsItemChancenFunding,
    'cobooth monthly flat payment' => l.paymentsItemMonthlyPayment,
    'cobooth payment' => l.paymentsItemBalancePayment,
    'commitment payment' => l.paymentsItemCommitmentPayment,
    'contribution fee' => l.paymentsItemContributionPayment,
    'drop out fee' => l.paymentsItemDropoutPayment,
    'repayment' => l.paymentsItemRepayment,
    'write off collection payment' => l.paymentsItemCollectionPayment,
    _ => l.paymentsOtherItem,
  };
}

String _categoryDescription(
  BuildContext context,
  IsaPaymentCategory category,
) {
  final l = AppLocalizations.of(context);
  return switch (category) {
    IsaPaymentCategory.balanceReduction =>
      l.paymentsBalanceReductionDescription,
    IsaPaymentCategory.chancenFunding => l.paymentsChancenFundingDescription,
    IsaPaymentCategory.fees => l.paymentsFeesDescription,
    IsaPaymentCategory.penalties => l.paymentsPenaltiesDescription,
    IsaPaymentCategory.other => l.paymentsOtherDescription,
  };
}
