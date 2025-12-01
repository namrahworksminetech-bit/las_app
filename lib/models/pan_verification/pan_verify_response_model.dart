class PanVerifyResponseModel {
  final bool success;
  final String? message;
  final String? reqId; // <-- Add this

  PanVerifyResponseModel({
    required this.success,
    this.message,
    this.reqId,
  });

  factory PanVerifyResponseModel.fromJson(Map<String, dynamic> json) {
    return PanVerifyResponseModel(
      success: json['status'] == 'success',
      message: json['message'],
      reqId: json['data'] != null ? json['data']['id'] as String? : null,
    );
  }

  factory PanVerifyResponseModel.error(String message) {
    return PanVerifyResponseModel(success: false, message: message);
  }
}
