class LenderItem {
  final int id;
  final String? name;
  final String? logo;
  final String? lender_code;
  final double? loanInterest;
  final double? loanAmount;
  final int? eligibleFundsCount;

  LenderItem({
    required this.id,
    this.name,
    this.logo,
    this.loanInterest,
    this.loanAmount,
    this.eligibleFundsCount,
    this.lender_code,
  });

  factory LenderItem.fromJson(Map<String, dynamic> json) {
    return LenderItem(
      id: json['id'] ?? 0,
      name: json['name'],
      logo: json['logo'],
      lender_code: json['lender_code'],
      loanInterest: (json['loan_interest'] ?? json['roi'] ?? 0).toDouble(),
      loanAmount: (json['loan_amount'] ?? json['eligible_limit'] ?? 0)
          .toDouble(),
      eligibleFundsCount: (json['eligible_funds_count'] ?? 0).toInt(),
    );
  }
}
