class OtpResponseModel {
  final bool success;
  final String? otpRef;
  final String? message;

  OtpResponseModel({
    required this.success,
    this.otpRef,
    this.message,
  });

  factory OtpResponseModel.fromJson(Map<String, dynamic> json) {
    return OtpResponseModel(
      success: json['status'] == 'success',
      otpRef: json['data']?['otp_ref'],
      message: json['message'],
    );
  }

  factory OtpResponseModel.error(String message) {
    return OtpResponseModel(success: false, message: message);
  }
}
