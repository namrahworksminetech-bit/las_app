import 'package:las_app/models/funds/lender_model.dart';

class MfDetailsResponse {

  final List<LenderItem> lenders;
  final double? pledgeableAmount;
  final double? eligiblePortfolio;
  final double? maxEligibleLimit;

  MfDetailsResponse({
    required this.lenders,
    this.pledgeableAmount,
    this.eligiblePortfolio,
    this.maxEligibleLimit,
  });

  factory MfDetailsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;

    final lendersData = (data['eligible_lenders'] as List<dynamic>?)
            ?.map((e) => LenderItem.fromJson(e))
            .toList() ??
        [];

    return MfDetailsResponse(
      lenders: lendersData,
      pledgeableAmount: (data['pledgeableAmount'] ?? 0).toDouble(),
      eligiblePortfolio: (data['eligible_portfolio'] ?? 0).toDouble(),
      maxEligibleLimit: (data['max_eligible_limit'] ?? 0).toDouble(),
    );
    
  }

}
