class VerifyOtpResponse {
  final bool success;
  final String? token;
  final String? refreshToken;
  final String? name;
  final String? message;

  VerifyOtpResponse({
    required this.success,
    this.token,
    this.refreshToken,
    this.name,
    this.message,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return VerifyOtpResponse(
      success: json['status'] == 'success',
      token: data is Map<String, dynamic> ? data['token'] : null,
      refreshToken: data is Map<String, dynamic> ? data['refresh_token'] : null,
      name: data is Map<String, dynamic> ? data['name'] : null,
      message: json['message'],
    );
  }

  factory VerifyOtpResponse.error(String message) {
    return VerifyOtpResponse(success: false, message: message);
  }
}
