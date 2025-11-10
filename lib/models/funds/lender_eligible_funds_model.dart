class EligibleFund {
  final String fundName;
  final String fundCode;
  final String unitsPledge;
  final String folioNo;
 
  EligibleFund({
    required this.fundName,
    required this.fundCode,
    required this.unitsPledge,
    required this.folioNo,
  });

  factory EligibleFund.fromJson(Map<String, dynamic> json) {
    return EligibleFund(
      fundName: json['fund_name'] ?? '',
      fundCode: json['fund_code'] ?? '',
      unitsPledge: json['units_pledge'] ?? '0',
      folioNo: json['folio_no'] ?? '',
    );
  }
    Map<String, dynamic> toJson() => {
        'fund_name': fundName,
        'fund_code': fundCode,
        'units_pledge': unitsPledge,
        'folio_no': folioNo,
      };
}

  