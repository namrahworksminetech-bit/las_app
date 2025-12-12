import 'package:equatable/equatable.dart';

class PledgeableFund extends Equatable {
  final String fundName;
  final double fundValue;
  final String fundCode;
  final double lienEligibleUnits;
  final double nav;
  final double availableAmount;
  final double availableUnits;
  final String amcCode;
  final String schemeCode;
  final String folioNo;
  final String rtaName;
 final double? updatedFundAmount;
  final bool enabled;
  final bool active;
  const PledgeableFund({
    required this.fundName,
    required this.fundValue,
    required this.fundCode,
    required this.lienEligibleUnits,
    required this.nav,
    required this.availableAmount,
    required this.availableUnits,
    required this.amcCode,
    required this.schemeCode,
    required this.folioNo,
    required this.rtaName,
    this.updatedFundAmount,
       this.enabled = false,
    this.active = false,
  });

  /// --- JSON Parsing Helpers ---
  factory PledgeableFund.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    return PledgeableFund(
      fundName: json['fund_name'] ?? '',
      fundValue: _toDouble(json['fund_value']),
      fundCode: json['fund_code'] ?? '',
      lienEligibleUnits: _toDouble(json['lienEligibleUnits']),
      nav: _toDouble(json['nav']),
      availableAmount: _toDouble(json['availableAmount']),
      availableUnits: _toDouble(json['availableUnits']),
      amcCode: json['amcCode'] ?? '',
      schemeCode: json['schemeCode'] ?? '',
      folioNo: json['folioNo']?.toString() ?? '',
      rtaName: json['rtaName'] ?? '',
      updatedFundAmount: null,
        enabled: false,
      active: false,
    );
  }

  Map<String, dynamic> toJson() => {
    'fund_name': fundName,
    'fund_value': fundValue,
    'fund_code': fundCode,
    'lienEligibleUnits': lienEligibleUnits,
    'nav': nav,
    'availableAmount': availableAmount,
    'availableUnits': availableUnits,
    'amcCode': amcCode,
    'schemeCode': schemeCode,
    'folioNo': folioNo,
    'rtaName': rtaName,
  };

  /// --- Copy helper ---
  PledgeableFund copyWith({
    String? fundName,
    double? fundValue,
    String? fundCode,
    double? lienEligibleUnits,
    double? nav,
    double? availableAmount,
    double? availableUnits,
    String? amcCode,
    String? schemeCode,
    String? folioNo,
    String? rtaName,
    double? updatedFundAmount,
        bool? enabled,
    bool? active,
  }) {
    return PledgeableFund(
      fundName: fundName ?? this.fundName,
      fundValue: fundValue ?? this.fundValue,
      fundCode: fundCode ?? this.fundCode,
      lienEligibleUnits: lienEligibleUnits ?? this.lienEligibleUnits,
      nav: nav ?? this.nav,
      availableAmount: availableAmount ?? this.availableAmount,
      availableUnits: availableUnits ?? this.availableUnits,
      amcCode: amcCode ?? this.amcCode,
      schemeCode: schemeCode ?? this.schemeCode,
      folioNo: folioNo ?? this.folioNo,
      rtaName: rtaName ?? this.rtaName,
      updatedFundAmount: updatedFundAmount ?? this.updatedFundAmount,
        enabled: enabled ?? this.enabled,
      active: active ?? this.active,
    );
  }

  @override
  List<Object?> get props => [
    fundName,
    fundValue,
    fundCode,
    lienEligibleUnits,
    nav,
    availableAmount,
    availableUnits,
    amcCode,
    schemeCode,
    folioNo,
    rtaName,
    updatedFundAmount,
       enabled,
        active,
  ];

  factory PledgeableFund.empty() => const PledgeableFund(
    fundName: '',
    fundValue: 0.0,
    fundCode: '',
    lienEligibleUnits: 0.0,
    nav: 0.0,
    availableAmount: 0.0,
    availableUnits: 0.0,
    amcCode: '',
    schemeCode: '',
    folioNo: '',
    rtaName: '',
     enabled: false,
        active: false,
  );
}
