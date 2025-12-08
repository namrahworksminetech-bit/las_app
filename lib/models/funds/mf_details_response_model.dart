import 'package:las_app/models/funds/funds_detail_model.dart';
import 'package:las_app/models/funds/lender_model.dart';
import 'package:las_app/models/funds/pledgeable_model.dart';

class MfDetailsResponse {
  final List<LenderItem> lenders;

  final List<PledgeableFund> pledgeableFunds;
  final List<PledgeableFund> nonPledgeableFunds;
  final List<PledgeableFund> dematFunds;

  final List<FundDetail> fundDetails;

  final double? pledgeableAmount;
  final double? nonPledgeableAmount;
  final double? dematAmount;

  final double? eligiblePortfolio;
  final double? maxEligibleLimit;

  const MfDetailsResponse({
    required this.lenders,
    required this.pledgeableFunds,
    required this.nonPledgeableFunds,
    required this.dematFunds,
    required this.fundDetails,
    this.pledgeableAmount,
    this.nonPledgeableAmount,
    this.dematAmount,
    this.eligiblePortfolio,
    this.maxEligibleLimit,
  });

  factory MfDetailsResponse.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] is Map<String, dynamic>) ? json['data'] : json;

    double _toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    // -------------------------------
    // PARSE LISTS
    // -------------------------------

    final lendersList = data['eligible_lenders'] ?? data['eligibleLenders'] ?? [];
    final pledgeableList = data['pledgeableFunds'] ?? [];
    final nonPledgeableList = data['nonPledgeableFunds'] ?? [];
    final dematList = data['dematFunds'] ?? [];

    final fundDetailsList =
        data['fund_details'] ?? data['FundDetails'] ?? [];

    return MfDetailsResponse(
      lenders: (lendersList as List)
          .map((e) => LenderItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),

      pledgeableFunds: (pledgeableList as List)
          .map((e) => PledgeableFund.fromJson(Map<String, dynamic>.from(e)))
          .toList(),

      nonPledgeableFunds: (nonPledgeableList as List)
          .map((e) => PledgeableFund.fromJson(Map<String, dynamic>.from(e)))
          .toList(),

      dematFunds: (dematList as List)
          .map((e) => PledgeableFund.fromJson(Map<String, dynamic>.from(e)))
          .toList(),

      fundDetails: (fundDetailsList as List)
          .map((e) => FundDetail.fromJson(Map<String, dynamic>.from(e)))
          .toList(),

      pledgeableAmount: _toDouble(data['pledgeableAmount']),
      nonPledgeableAmount: _toDouble(data['nonPledgeableAmount']),
      dematAmount: _toDouble(data['demat_amount']),

      eligiblePortfolio:
          _toDouble(data['total_portfolio'] ?? data['eligible_portfolio']),

      maxEligibleLimit: _toDouble(data['max_eligible_limit']),
    );
  }

  Map<String, dynamic> toJson() => {
        'eligible_lenders': lenders.map((e) => e.toJson()).toList(),

        'pledgeableFunds': pledgeableFunds.map((e) => e.toJson()).toList(),
        'nonPledgeableFunds': nonPledgeableFunds.map((e) => e.toJson()).toList(),
        'dematFunds': dematFunds.map((e) => e.toJson()).toList(),

        'fund_details': fundDetails.map((e) => e.toJson()).toList(),

        'pledgeableAmount': pledgeableAmount,
        'nonPledgeableAmount': nonPledgeableAmount,
        'demat_amount': dematAmount,

        'eligible_portfolio': eligiblePortfolio,
        'max_eligible_limit': maxEligibleLimit,
      };
}
