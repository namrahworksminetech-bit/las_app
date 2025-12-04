DashboardResult dashboardFromJson(Map<String, dynamic> map) => DashboardResult.fromJson(map);

class DashboardResult {
  final String? status;
  final DashboardModel? data;
  final String? message;

  DashboardResult({
    this.status,
    this.data,
    this.message,
  });

  factory DashboardResult.fromJson(Map<String, dynamic> json) => DashboardResult(
    status: json["status"],
    data: json["data"] == null ? null : DashboardModel.fromJson(json["data"]),
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": data?.toJson(),
    "message": message,
  };
}

class DashboardModel {
  final String? reqId;
  final String? isCancelled;
  final String? isContinued;
  final String? isVcip;

  final String? name;
  final String? availableCreditLimit;
  final String? withdrawn;
  final String? interestRate;
  final int? mfPledges;
  final String? accountNumber;
  final String? accountIfsc;
  final String? clientBankName;
  final UpcomingRepayment? upcomingRepayment;
  final String? availableAmount;
  final String? drawingPower;
  final String? lan;
  final String? fas;
  final String? shortfallAmount;

  DashboardModel({
    this.reqId,
    this.isCancelled,
    this.isContinued,
    this.isVcip,
    this.name,
    this.availableCreditLimit,
    this.withdrawn,
    this.interestRate,
    this.mfPledges,
    this.accountNumber,
    this.accountIfsc,
    this.clientBankName,
    this.upcomingRepayment,
    this.availableAmount,
    this.drawingPower,
    this.lan,
    this.fas,
    this.shortfallAmount,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) => DashboardModel(
    reqId: json["req_id"],
    isCancelled: json["is_cancelled"],
    isContinued: json["is_continued"],
    isVcip: json["is_vcip"],
    name: json["name"],
    availableCreditLimit: json["available_credit_limit"],
    withdrawn: json["withdrawn"],
    interestRate: json["interest_rate"],
    mfPledges: json["mf_pledges"],
    accountNumber: json["account_Number"],
    accountIfsc: json["account_ifsc"],
    clientBankName: json["ClientBankName"],
    upcomingRepayment: json["upcoming_repayment"] == null ? null : UpcomingRepayment.fromJson(json["upcoming_repayment"]),
    availableAmount: json["availableAmount"],
    drawingPower: json["DrawingPower"],
    lan: json["lan"],
    fas: json["fas"],
    shortfallAmount: json["shortfallAmount"],
  );

  Map<String, dynamic> toJson() => {
    "req_id": reqId,
    "is_cancelled": isCancelled,
    "is_continued": isContinued,
    "is_vcip": isVcip,
    "name": name,
    "available_credit_limit": availableCreditLimit,
    "withdrawn": withdrawn,
    "interest_rate": interestRate,
    "mf_pledges": mfPledges,
    "account_Number": accountNumber,
    "account_ifsc": accountIfsc,
    "ClientBankName": clientBankName,
    "upcoming_repayment": upcomingRepayment?.toJson(),
    "availableAmount": availableAmount,
    "DrawingPower": drawingPower,
    "lan": lan,
    "fas": fas,
    "shortfallAmount": shortfallAmount,
  };
}

class UpcomingRepayment {
  final String? interestPayment;
  final String? dueDate;

  UpcomingRepayment({
    this.interestPayment,
    this.dueDate,
  });

  factory UpcomingRepayment.fromJson(Map<String, dynamic> json) => UpcomingRepayment(
    interestPayment: json["interest_payment"],
    dueDate: json["due_date"],
  );

  Map<String, dynamic> toJson() => {
    "interest_payment": interestPayment,
    "due_date": dueDate,
  };
}