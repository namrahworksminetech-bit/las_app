import 'package:las_app/models/funds/funds_detail_model.dart';
import 'package:las_app/models/funds/lender_model.dart';
import 'package:las_app/models/funds/pledgeable_model.dart';

class MfDetailsResponse {
  final List<LenderItem> lenders;
  final List<PledgeableFund> pledgeableFunds;
  final List<FundDetail> fundDetails;
  final double? pledgeableAmount;
  final double? nonPledgeableAmount;
  final double? dematAmount;

  
  final double? eligiblePortfolio;
  final double? maxEligibleLimit;

  const MfDetailsResponse({
    required this.lenders,
    required this.pledgeableFunds,
    required this.fundDetails,
    this.pledgeableAmount,
    this.nonPledgeableAmount,
    this.dematAmount,
    this.eligiblePortfolio,
    this.maxEligibleLimit,
  });

  factory MfDetailsResponse.fromJson(Map<String, dynamic> json) {
    final data =
        (json['data'] is Map<String, dynamic>) ? json['data'] : json;

    final lendersData = data['eligible_lenders'] ?? data['eligibleLenders'];
    final lenders = (lendersData is List)
        ? lendersData
            .map((e) => LenderItem.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <LenderItem>[];

    final fundsData =
        data['pledgeableFunds'] ?? data['pledgeable_funds'] ?? [];
    final pledgeableFunds = (fundsData is List)
        ? fundsData
            .map((e) => PledgeableFund.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <PledgeableFund>[];

    // ✅ Parse fundDetails from 'fund_details'
    final fundDetailsData = data['fund_details'] ?? data['FundDetails'] ?? [];
    final fundDetails = (fundDetailsData is List)
        ? fundDetailsData
            .map((e) => FundDetail.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <FundDetail>[];

    double _toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    return MfDetailsResponse(
      lenders: lenders,
      pledgeableFunds: pledgeableFunds,
      fundDetails: fundDetails, // ✅ Added
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
        'fund_details': fundDetails.map((e) => e.toJson()).toList(), // ✅ Added
        'pledgeableAmount': pledgeableAmount,
        'nonPledgeableAmount': nonPledgeableAmount,
        'demat_amount': dematAmount,
        'eligible_portfolio': eligiblePortfolio,
        'max_eligible_limit': maxEligibleLimit,
      };
}
