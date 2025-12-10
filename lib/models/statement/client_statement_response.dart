class ClientStatementResponse {
  final String? status;
  final String? message;
  final ClientStatementData? data;

  ClientStatementResponse({
    this.status,
    this.message,
    this.data,
  });

  factory ClientStatementResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json["data"];

    return ClientStatementResponse(
      status: json["status"],
      message: json["message"],

      // FIX: handle when data = [] (List)
      data: (rawData is Map<String, dynamic>)
          ? ClientStatementData.fromJson(rawData)
          : null,
    );
  }
}

class ClientStatementData {
  final String? file;
  final String? statement;

  ClientStatementData({this.file, this.statement});

  factory ClientStatementData.fromJson(Map<String, dynamic> json) {
    return ClientStatementData(
      file: json["file"],
      statement: json["statement"],
    );
  }
}
