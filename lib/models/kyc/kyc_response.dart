class KycResponse {
  final String status;
  final KycData data;
  final String message;

  KycResponse({
    required this.status,
    required this.data,
    required this.message,
  });

  factory KycResponse.fromJson(Map<String, dynamic> json) => KycResponse(
        status: json['status'],
        data: KycData.fromJson(json['data']),
        message: json['message'],
      );
}

class KycData {
  final String url;

  KycData({required this.url});

  factory KycData.fromJson(Map<String, dynamic> json) => KycData(
        url: json['url'],
      );
}