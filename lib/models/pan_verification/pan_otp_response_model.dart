class PanGenerateOtpResponseModel {
  final bool success;
  final String? message;
  final String? clientRefNo;

  PanGenerateOtpResponseModel({required this.success, this.message, this.clientRefNo});

  factory PanGenerateOtpResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return PanGenerateOtpResponseModel(
      success: json['status'] == 'success',
      message: json['message'],
      clientRefNo: data?['client_ref_no'],
    );
  }

  factory PanGenerateOtpResponseModel.error(String message) {
    return PanGenerateOtpResponseModel(success: false, message: message);
  }
}
