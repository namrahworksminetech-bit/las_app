class RtaOtpResponseModel {
  final String status;
  final List<dynamic> data;
  final String message;

  RtaOtpResponseModel({
    required this.status,
    required this.data,
    required this.message,
  });

  factory RtaOtpResponseModel.fromJson(Map<String, dynamic> json) {
    return RtaOtpResponseModel(
      status: json['status'] ?? '',
      data: json['data'] ?? [],
      message: json['message'] ?? '',
    );
  }
}