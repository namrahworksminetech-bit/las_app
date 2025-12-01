class VerifyOtpResponse {
  final bool success;
  final String? token;
  final String? refreshToken;
  final String? name;
  final String? message;
  final String? reqId; // ✅ add this

  VerifyOtpResponse({
    required this.success,
    this.token,
    this.refreshToken,
    this.name,
    this.message,
    this.reqId,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
     String? extractedReqId;
    final reqIdValue = data['req_id'];
    if (reqIdValue is List && reqIdValue.isNotEmpty) {
      extractedReqId = reqIdValue.first;
    } else if (reqIdValue is String) {
      extractedReqId = reqIdValue;
    }

    return VerifyOtpResponse(
      success: json['status'] == 'success',
      token: data is Map<String, dynamic> ? data['token'] : null,
      refreshToken: data is Map<String, dynamic> ? data['refresh_token'] : null,
      name: data is Map<String, dynamic> ? data['name'] : null,
      reqId: extractedReqId,
      message: json['message'],
    );
  }

  factory VerifyOtpResponse.error(String message) {
    return VerifyOtpResponse(success: false, message: message);
  }
}
