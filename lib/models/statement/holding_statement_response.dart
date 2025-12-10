class HoldingStatementResponse {
  final String? status;
  final String? message;
  final HoldingData? data;

  HoldingStatementResponse({this.status, this.message, this.data});

  factory HoldingStatementResponse.fromJson(Map<String, dynamic> json) =>
      HoldingStatementResponse(
        status: json["status"],
        message: json["message"],
        data: json["data"] != null ? HoldingData.fromJson(json["data"]) : null,
      );
}

class HoldingData {
  final String? file;

  HoldingData({this.file});

  factory HoldingData.fromJson(Map<String, dynamic> json) =>
      HoldingData(
        file: json["file"],
      );
}
