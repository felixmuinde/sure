class InsightsData {
  final String? isaStatus;
  final String? totalFinanced;
  final String? repaymentPercentage;
  final String? maximumFinancedAmount;
  final String? totalRepaidSoFar;
  final String? installmentsPaid;
  final String? maxInstallments;
  final String? currency;
  final String? institution;

  const InsightsData({
    this.isaStatus,
    this.totalFinanced,
    this.repaymentPercentage,
    this.maximumFinancedAmount,
    this.totalRepaidSoFar,
    this.installmentsPaid,
    this.maxInstallments,
    this.currency,
    this.institution,
  });

  factory InsightsData.fromJson(Map<String, dynamic> json) {
    final d = (json['insights'] as Map<String, dynamic>?) ?? json;
    return InsightsData(
      isaStatus:             d['isa_status']?.toString(),
      totalFinanced:         d['total_financed']?.toString(),
      repaymentPercentage:   d['repayment_percentage']?.toString(),
      maximumFinancedAmount: d['maximum_financed_amount']?.toString(),
      totalRepaidSoFar:      d['total_repaid_so_far']?.toString(),
      installmentsPaid:      d['installments_paid']?.toString(),
      maxInstallments:       d['max_installments']?.toString(),
      currency:              d['currency']?.toString(),
      institution:           d['institution']?.toString(),
    );
  }

  double get installmentsProgress {
    final paid = double.tryParse(installmentsPaid ?? '') ?? 0;
    final max  = double.tryParse(maxInstallments ?? '') ?? 0;
    return (max > 0) ? (paid / max).clamp(0.0, 1.0) : 0.0;
  }
}
