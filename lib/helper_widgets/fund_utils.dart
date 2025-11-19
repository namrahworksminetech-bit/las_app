import 'package:las_app/models/funds/funds_detail_model.dart';

/// Format helpers for edit-loan-amount API
List<String> buildIsinModifyFromFunds(List<FundDetail> funds) {
  // server expects "<fund_code>:<folioNo>:<updatedFundAmount>"
  return funds.where((f) {
    // keep only those with required values present and a non-null updated amount
    return (f.fundCode.isNotEmpty && f.folioNo.isNotEmpty && f.updatedFundAmount != null);
  }).map((f) {
    // If API expects integer units, use toStringAsFixed(0). If decimals allowed, use toString()
    final amt = f.updatedFundAmount!;
    final amtStr = amt == amt.roundToDouble() ? amt.toStringAsFixed(0) : amt.toString();
    return '${f.fundCode}:${f.folioNo}:$amtStr';
  }).toList();
}
/// Build isin_add entries for edit-loan-amount API
/// Format per API: "<fund_code>:<folioNo>"
List<String> buildIsinAddFromFunds(List<FundDetail> funds) {
  return funds.where((f) {
    // require a non-empty fundCode and folioNo — API expects both
    return f.fundCode.trim().isNotEmpty && f.folioNo.trim().isNotEmpty;
  }).map((f) {
    final fundCode = f.fundCode.trim();
    final folio = f.folioNo.trim();
    return '$fundCode:$folio';
  }).toList();
}

/// Build isin_remove entries for edit-loan-amount API
/// Format per API: "<fund_code>:<folioNo>"
List<String> buildIsinRemoveFromFunds(List<FundDetail> funds) {
  // same format / validation as add
  return funds.where((f) {
    return f.fundCode.trim().isNotEmpty && f.folioNo.trim().isNotEmpty;
  }).map((f) {
    final fundCode = f.fundCode.trim();
    final folio = f.folioNo.trim();
    return '$fundCode:$folio';
  }).toList();
}