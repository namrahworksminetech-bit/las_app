class VerifyOtpResponse {
  final bool success;
  final String? message;
  final String? reqId; // ✅ important field

  VerifyOtpResponse({
    required this.success,
    this.message,
    this.reqId,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
      success: json['success'] ?? false,
      message: json['message'],
      reqId: json['data']?['req_id'], 
    );
  }

  factory VerifyOtpResponse.error(String message) {
    return VerifyOtpResponse(success: false, message: message);
  }
}
