import 'package:las_app/models/funds/funds_detail_model.dart';
import 'package:las_app/models/funds/lender_eligible_funds_model.dart';
import 'package:las_app/models/funds/pledgeable_model.dart';

/// Utility class that merges lender-specific eligible funds
/// with the full list of available fund details.
class FundsMerger {

  
  /// Match keys:
  /// - `fund_code` ↔ `fundCode`
  /// - `folio_no` ↔ `folioNo`
  static List<PledgeableFund> merge({
    required List<EligibleFund> eligibleFunds,
    required List<PledgeableFund> fundDetails,
  }) {
    final List<PledgeableFund> merged = [];

    for (final eligible in eligibleFunds) {
      //  Find matching fund detail entry
      final match = fundDetails.firstWhere(
        (d) =>
            d.fundCode == eligible.fundCode &&
            d.folioNo == eligible.folioNo,
        orElse: () => PledgeableFund.empty(),
      );

//nno match? skip
      if (match.fundCode.isEmpty) continue;

      final double units = double.tryParse(eligible.unitsPledge) ?? 0.0;
      final double nav = match.nav;
      final double fundValue = units * nav;

      merged.add(PledgeableFund(
        fundName: eligible.fundName.isNotEmpty
            ? eligible.fundName
            : match.fundName,
        fundCode: eligible.fundCode,
        folioNo: eligible.folioNo,
        lienEligibleUnits: units,
        nav: nav,
        fundValue: fundValue,
        availableUnits: match.availableUnits ?? 0,
        availableAmount: match.availableAmount ?? 0,
        amcCode: match.amcCode,
        schemeCode: match.schemeCode,
        rtaName: match.rtaName,
      ));
    }

    //  Sort — active (pledgeable) funds first
    merged.sort((a, b) {
      final aActive = a.lienEligibleUnits > 0;
      final bActive = b.lienEligibleUnits > 0;
      if (aActive && !bActive) return -1;
      if (!aActive && bActive) return 1;
      return 0;
    });

    return merged;
  }
}
