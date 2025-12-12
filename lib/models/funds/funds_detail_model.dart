class FundDetail {
  final String fundName;
  final String fundCode; // used instead of ISIN
  final String folioNo;
  final double nav;
  final double? availableUnits;
  final double? availableAmount;
  final String amcCode;
  final String schemeCode;
  final String rtaName;
final int isEligible;

  // NEW: the amount/units user may edit (used for modify entries)
  final double? updatedFundAmount;

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
    this.updatedFundAmount,
      this.isEligible = 0,  
  });

  factory FundDetail.fromJson(Map<String, dynamic> json) {
    return FundDetail(
      fundName: json['fund_name'] ?? '',
      fundCode: json['fund_code'] ?? '',
      folioNo: (json['folioNo'] ?? json['folio_no'])?.toString() ?? '',
      nav: double.tryParse((json['nav'] ?? '').toString()) ?? 0.0,
      availableUnits:
          double.tryParse((json['availableUnits'] ?? json['available_units'] ?? '').toString()) ?? 0.0,
      availableAmount:
          double.tryParse((json['availableAmount'] ?? json['available_amount'] ?? '').toString()) ?? 0.0,
      amcCode: json['amcCode'] ?? '',
      schemeCode: json['schemeCode'] ?? '',
      rtaName: json['rtaName'] ?? '',
     isEligible: int.tryParse((json['is_eligible'] ?? '0').toString()) ?? 0,


      updatedFundAmount: json['updatedFundAmount'] != null
          ? double.tryParse(json['updatedFundAmount'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'fund_name': fundName,
        'fund_code': fundCode,
        'folioNo': folioNo,
        'nav': nav,
        'availableUnits': availableUnits ?? 0.0,
        'availableAmount': availableAmount ?? 0.0,
        'amcCode': amcCode,
        'schemeCode': schemeCode,
        'rtaName': rtaName,
        'is_eligible': isEligible,

        if (updatedFundAmount != null) 'updatedFundAmount': updatedFundAmount,
      };


  FundDetail copyWith({
    String? fundName,
    String? fundCode,
    String? folioNo,
    double? nav,
    double? availableUnits,
    double? availableAmount,
    String? amcCode,
    String? schemeCode,
    String? rtaName,
    double? updatedFundAmount,
  }) {
    return FundDetail(
      fundName: fundName ?? this.fundName,
      fundCode: fundCode ?? this.fundCode,
      folioNo: folioNo ?? this.folioNo,
      nav: nav ?? this.nav,
      availableUnits: availableUnits ?? this.availableUnits,
      availableAmount: availableAmount ?? this.availableAmount,
      amcCode: amcCode ?? this.amcCode,
      schemeCode: schemeCode ?? this.schemeCode,
      rtaName: rtaName ?? this.rtaName,
      updatedFundAmount: updatedFundAmount ?? this.updatedFundAmount,
    );
  }

  // empty fallback
  factory FundDetail.empty() => FundDetail(
        fundName: '',
        fundCode: '',
        folioNo: '',
        nav: 0.0,
      );
}
