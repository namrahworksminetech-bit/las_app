import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../models/authentication/otp_response_model.dart';
import '../../../models/authentication/otp_verify_response_model.dart';

class LoginRepository {
  final ApiClient _apiClient;

  LoginRepository(this._apiClient);

  Future<OtpResponseModel> sendOtp(String phoneNumber) async {
    try {
      final response = await _apiClient.post(
        '/customer/send-otp', // change to your actual OTP endpoint
        data: {'phone_number': phoneNumber},
      );

      if (response.statusCode == 200) {
        return OtpResponseModel.fromJson(response.data);
      } else {
        return OtpResponseModel.error('Unexpected status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        return OtpResponseModel.error('Forbidden');
      }
      return OtpResponseModel.error(
          e.response?.data['message'] ?? 'Network error: ${e.message}');
    } catch (e) {
      return OtpResponseModel.error('Unexpected error: $e');
    }
  }


  Future<VerifyOtpResponse> verifyOtp({
    required String phoneNumber,
    required String otpRef,
    required String otp,
  }) async {
    try {
      final response = await _apiClient.post(
        '/customer/login',
        data: {
          'phone_number': '+91${phoneNumber}',
          'otp_ref': otpRef,
          'otp': otp,
        },
        options: Options(headers: {
          'x-public-ip': '27.107.213.154',
          'Content-Type': 'application/json',
        }),
      );
print('VERIFYING OTP WITH:');
print('  phone: ${phoneNumber}');
print('  otpRef: ${otpRef}');
print('  otp: ${otp}');

      print('✅ VERIFY OTP RESPONSE: ${response.data}');
      return VerifyOtpResponse.fromJson(response.data);
    } on DioException catch (e) {
      return VerifyOtpResponse.error(
        e.response?.data['message'] ?? e.message ?? 'Network error',
      );
    } catch (e) {
      return VerifyOtpResponse.error('Unexpected error: $e');
    }
  }

}
