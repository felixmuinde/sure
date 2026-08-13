class StudentAccount {
  const StudentAccount({
    required this.email,
    required this.status,
    required this.totalFinanced,
    required this.repaymentsReceived,
    required this.maxAmount,
    required this.installmentsPaid,
    required this.maxInstallments,
    required this.currency,
  });

  final String email;
  final String status;
  final double totalFinanced;
  final double repaymentsReceived;
  final double maxAmount;
  final int installmentsPaid;
  final int maxInstallments;
  final String currency;

  factory StudentAccount.fromJson(Map<String, dynamic> json) {
    return StudentAccount(
      email: (json['email'] as String?) ?? '',
      status: (json['status'] as String?) ?? '',
      totalFinanced: _toDouble(json['total_financed']),
      repaymentsReceived: _toDouble(json['repayments_received']),
      maxAmount: _toDouble(json['max_amount']),
      installmentsPaid: _toInt(json['installments_paid']),
      maxInstallments: _toInt(json['max_installments']),
      currency: (json['currency'] as String?) ?? 'KES',
    );
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }
}
