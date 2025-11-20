class KycWebhookResponse {
  final String status;
  final String message;
  final KycWebhookData data;

  KycWebhookResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory KycWebhookResponse.fromJson(Map<String, dynamic> json) => KycWebhookResponse(
        status: json['status'],
        message: json['message'],
        data: KycWebhookData.fromJson(json['data']),
      );
}

class KycWebhookData {
  final String kycStatus;
  final String loanCreationId;
  final String bankName;
  final String reqId;

  KycWebhookData({
    required this.kycStatus,
    required this.loanCreationId,
    required this.bankName,
    required this.reqId,
  });

  factory KycWebhookData.fromJson(Map<String, dynamic> json) => KycWebhookData(
        kycStatus: json['kyc_status'],
        loanCreationId: json['loan_creation_id'],
        bankName: json['bank_name'],
        reqId: json['req_id'],
      );
}