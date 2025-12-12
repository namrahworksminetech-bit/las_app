import 'package:las_app/models/funds/funds_detail_model.dart';
import 'package:las_app/models/funds/lender_eligible_funds_model.dart';
import 'package:las_app/models/funds/pledgeable_model.dart';

class FundsMerger {
  static List<PledgeableFund> mergeFullList({
    required List<EligibleFund> eligibleFunds,
    required List<FundDetail> fundDetails,
  }) {
    final List<PledgeableFund> merged = [];

    for (final detail in fundDetails) {
      // Check if fund is eligible
      final eligible = eligibleFunds.firstWhere(
        (e) =>
            e.fundCode == detail.fundCode &&
            e.folioNo == detail.folioNo,
        orElse: () => EligibleFund(
          fundName: "",
          fundCode: "",
          unitsPledge: "0",
          folioNo: "",
        ),
      );

      final bool isEligible = eligible.fundCode.isNotEmpty;

      // Calculate units & fund value
      final double units =
          isEligible ? double.tryParse(eligible.unitsPledge) ?? 0 : 0;
      final double fundValue = units * detail.nav;

      merged.add(
        PledgeableFund(
          fundName: detail.fundName,
          fundCode: detail.fundCode,
          folioNo: detail.folioNo,
          lienEligibleUnits: units,
          nav: detail.nav,
          fundValue: fundValue,
          availableAmount: fundValue,
          availableUnits: detail.availableUnits ?? 0,
          amcCode: detail.amcCode,
          schemeCode: detail.schemeCode,
          rtaName: detail.rtaName,
          enabled: isEligible,
          active: isEligible && fundValue > 0,
        ),
      );
    }
    

    // Sort: Active first → Enabled → Others
    merged.sort((a, b) {
      if (a.active && !b.active) return -1;
      if (!a.active && b.active) return 1;
      if (a.enabled && !b.enabled) return -1;
      if (!a.enabled && b.enabled) return 1;
      return 0;
    });

    return merged;
  }
}
