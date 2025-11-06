import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/network/api_client.dart';
import '../../../models/kyc/kyc_response.dart';
import '../../../models/kyc/kyc_webhook_response.dart';

class KycRepository {
  final ApiClient _apiClient;
  final _storage = const FlutterSecureStorage();

  KycRepository(this._apiClient);

  Future<KycWebhookResponse> checkKycStatus({
    required String reqId,
    required String kycStatus,
    required String lanNo,
    required String loanCreationId,
    required String bankName,
  }) async {
    await _apiClient.loadToken();
    
    final response = await _apiClient.post(
      'customer/webhook-kyc-status',
      data: {
        'req_id': reqId,
        'kyc_status': kycStatus,
        'lan_no': lanNo,
        'loan_creation_id': loanCreationId,
        'bank_name': bankName,
      },
    );
    return KycWebhookResponse.fromJson(response.data);
  }

  Future<KycResponse> startKyc({
    required String reqId,
    required String lenderCode,
    required double latitude,
    required double longitude,
    String sourceMode = 'WEB',
    int autoDisbursementConsent = 1,
  }) async {
    // Ensure token is loaded before making request
    final token = await _storage.read(key: 'token');
    if (token == null || token.isEmpty) {
      throw Exception('Token missing! Please login again.');
    }

    final response = await _apiClient.post(
      'customer/start-kyc',
      data: {
        'req_id': reqId,
        'lender_code': lenderCode,
        'latitude': latitude,
        'longitude': longitude,
        'sourceMode': sourceMode,
        'auto_disbursement_consent': autoDisbursementConsent,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );
    return KycResponse.fromJson(response.data);
  }
}
