enum IsaPaymentCategory {
  balanceReduction,
  chancenFunding,
  fees,
  penalties,
  other,
}

class IsaTransaction {
  const IsaTransaction({
    required this.paymentType,
    required this.amount,
    required this.currency,
    required this.paymentDate,
  });

  final String paymentType;
  final double amount;
  final String currency;
  final String paymentDate;

  String get normalizedPaymentType => paymentType
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[_-]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ');

  IsaPaymentCategory get category =>
      _paymentCategories[normalizedPaymentType] ?? IsaPaymentCategory.other;

  static const _paymentCategories = <String, IsaPaymentCategory>{
    'cobooth monthly flat payment': IsaPaymentCategory.balanceReduction,
    'cobooth payment': IsaPaymentCategory.balanceReduction,
    'commitment fee': IsaPaymentCategory.balanceReduction,
    'commitment fees': IsaPaymentCategory.balanceReduction,
    'commitment payment': IsaPaymentCategory.balanceReduction,
    'contribution fee': IsaPaymentCategory.balanceReduction,
    'drop out fee': IsaPaymentCategory.balanceReduction,
    'repayment': IsaPaymentCategory.balanceReduction,
    'write off collection payment': IsaPaymentCategory.balanceReduction,
    'pei payment': IsaPaymentCategory.chancenFunding,
    'admin fee': IsaPaymentCategory.fees,
    'application fee': IsaPaymentCategory.fees,
    'application fees': IsaPaymentCategory.fees,
    'deposit': IsaPaymentCategory.fees,
    'dropout penalty': IsaPaymentCategory.penalties,
    'drop out penalty': IsaPaymentCategory.penalties,
    'penalty fee': IsaPaymentCategory.penalties,
  };

  factory IsaTransaction.fromJson(Map<String, dynamic> json) {
    return IsaTransaction(
      paymentType: (json['payment_type'] as String?) ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: (json['currency'] as String?) ?? '',
      paymentDate: (json['payment_date'] as String?) ?? '',
    );
  }
}
