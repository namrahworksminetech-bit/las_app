import 'package:las_app/core/utils/enums.dart';

class TabModel {
  String name;
  EmType type;

  TabModel(this.name, this.type);
}

RepayResult repayFromJson(Map<String, dynamic> map) =>
    RepayResult.fromJson(map);

class RepayResult {
  final String? status;
  final List<RepayModel>? data;
  final String? message;

  RepayResult({this.status, this.data, this.message});

  factory RepayResult.fromJson(Map<String, dynamic> json) => RepayResult(
    status: json["status"],
    data: json["data"] == null
        ? []
        : List<RepayModel>.from(json["data"]!.map((x) => RepayModel.fromJson(x))),
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
    "message": message,
  };
}

class RepayModel {
  final String? accountNumber;
  final String? ifscCode;
  final String? beneficiaryName;
  final String? bankName;
  final String? branchName;
  final String? type;
  final dynamic bankLogo;

  RepayModel({
    this.accountNumber,
    this.ifscCode,
    this.beneficiaryName,
    this.bankName,
    this.branchName,
    this.type,
    this.bankLogo,
  });

  factory RepayModel.fromJson(Map<String, dynamic> json) => RepayModel(
    accountNumber: json["account_Number"],
    ifscCode: json["IFSC_Code"],
    beneficiaryName: json["beneficiary_Name"],
    bankName: json["bank_Name"],
    branchName: json["branch_Name"],
    type: json["type"],
    bankLogo: json["bank_logo"],
  );

  Map<String, dynamic> toJson() => {
    "account_Number": accountNumber,
    "IFSC_Code": ifscCode,
    "beneficiary_Name": beneficiaryName,
    "bank_Name": bankName,
    "branch_Name": branchName,
    "type": type,
    "bank_logo": bankLogo,
  };
}
