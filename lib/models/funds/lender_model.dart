import 'package:las_app/models/funds/lender_eligible_funds_model.dart';

class LenderItem {
  final int id;
  final String? name;
  final String? logo;
  final double? loanInterest;
  final double? loanAmount;
  final double? maxEligibleLimit;
  final int? eligibleFundsCount;
  final List<EligibleFund>? eligibleFunds;

  LenderItem({
    required this.id,
    this.name,
    this.logo,
    this.loanInterest,
    this.loanAmount,
    this.eligibleFundsCount,
    this.eligibleFunds,
    this.maxEligibleLimit
  });

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String)
      return int.tryParse(v) ?? (double.tryParse(v)?.toInt() ?? 0);
    return 0;
  }

  factory LenderItem.fromJson(Map<String, dynamic> json) {
    // ✅ Parse eligibleFunds
    final eligibleFundsData =
        json['eligible_funds'] ?? json['eligibleFunds'] ?? [];

    return LenderItem(
      id: _toInt(json['id']),
      name: json['name'],
      logo: json['logo'],
      loanInterest: _toDouble(json['loan_interest'] ?? json['roi']),
      loanAmount: _toDouble(json['loan_amount'] ?? json['eligible_limit']),
      maxEligibleLimit: _toDouble(json['max_eligible_limit'] ?? json ['max_eligible_limit']),
      eligibleFundsCount: _toInt(
        json['eligible_funds_count'] ?? json['eligibleFundsCount'],
      ),
      eligibleFunds: (eligibleFundsData is List)
          ? eligibleFundsData
                .map((e) => EligibleFund.fromJson(Map<String, dynamic>.from(e)))
                .toList()
          : <EligibleFund>[],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'logo': logo,
    'loan_interest': loanInterest,
    'max_eligible_limit':maxEligibleLimit,
    'loan_amount': loanAmount,
    'eligible_funds_count': eligibleFundsCount,
    'eligible_funds':
        eligibleFunds?.map((e) => e.toJson()).toList() ?? [], // ✅ Added
  };
}
