class FundDetail {
  final String fundName;
  final String fundCode;
  final String folioNo; 
  final double nav;
  final double? availableUnits;
  final double? availableAmount;
  final String amcCode;
  final String schemeCode;
  final String rtaName;

  FundDetail({
    required this.fundName,
    required this.fundCode,
    required this.folioNo,
    required this.nav,
    this.availableUnits,
    this.availableAmount,
    this.amcCode = '',
    this.schemeCode = '',
    this.rtaName = '',
  });

  factory FundDetail.fromJson(Map<String, dynamic> json) {
    return FundDetail(
      fundName: json['fund_name'] ?? '',
      fundCode: json['fund_code'] ?? '',
      folioNo: json['folioNo']?.toString() ?? '',
      nav: double.tryParse(json['nav']?.toString() ?? '') ?? 0.0,
      availableUnits: double.tryParse(json['availableUnits']?.toString() ?? '') ?? 0.0,
      availableAmount: double.tryParse(json['availableAmount']?.toString() ?? '') ?? 0.0,
      amcCode: json['amcCode'] ?? '',
      schemeCode: json['schemeCode'] ?? '',
      rtaName: json['rtaName'] ?? '',
    );
  }
Map<String, dynamic> toJson() => {
        'fund_name': fundName,
        'fund_code': fundCode,
        'folioNo': folioNo,
        'nav': nav,
        'availableUnits': availableUnits ?? 0.0,
        'availableAmount': availableAmount ?? 0.0,
        'amcCode': amcCode ?? '',
        'schemeCode': schemeCode ?? '',
        'rtaName': rtaName ?? '',
      };
  // empty fallback
  factory FundDetail.empty() => FundDetail(
        fundName: '',
        fundCode: '',
        folioNo: '',
        nav: 0.0,
        availableUnits: 0.0,
        availableAmount: 0.0,
      );
}
