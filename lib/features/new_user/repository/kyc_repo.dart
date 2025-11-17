import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';
import '../../../models/kyc/kyc_response.dart';
import '../../../models/kyc/kyc_webhook_response.dart';

class KycRepo {
  final ApiClient _apiClient;

  KycRepo(this._apiClient);

  Future<KycResponse> startKyc({
    required String reqId,
    required String lenderCode,
    required double latitude,
    required double longitude,
    String sourceMode = 'WEB',
    int autoDisbursementConsent = 1,
  }) async {
    print('📞 KycRepository.startKyc called');
    print('📋 reqId: $reqId');
    print('📋 lenderCode: $lenderCode');
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      print('❌ Token missing!');
      throw Exception('Token missing! Please login again.');
    }
    
    print('🔑 Token found: ${token.substring(0, 10)}...');
    print('📞 Making API call to customer/start-kyc');

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
    
    print('✅ API Response received: ${response.statusCode}');
    print('📋 Response data: ${response.data}');
    
    return KycResponse.fromJson(response.data);
  }

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
}
