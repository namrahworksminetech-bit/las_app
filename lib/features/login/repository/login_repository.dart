import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../models/authentication/otp_response_model.dart';
import '../../../models/authentication/otp_verify_response_model.dart';

class LoginRepository {
  final ApiClient _apiClient;

  LoginRepository(this._apiClient);

  // ------------------------ SEND OTP ------------------------
  Future<OtpResponseModel> sendOtp(String phoneNumber) async {
    try {
      final response = await _apiClient.post(
        '/customer/send-otp',
        data: {'phone_number': '+91$phoneNumber'},
        options: Options(
          sendTimeout: const Duration(minutes: 1),
          receiveTimeout: const Duration(minutes: 1),
        ),
      );

      if (response.statusCode == 200) {
        return OtpResponseModel.fromJson(response.data);
      } else {
        return OtpResponseModel.error('Unexpected status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // TIMEOUT CHECK
      if (e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionTimeout) {
        return OtpResponseModel.error('Server down, please try again later');
      }

      if (e.response?.statusCode == 403) {
        return OtpResponseModel.error('Forbidden');
      }

      final errorMsg = e.response?.data is Map ? e.response?.data['message']?.toString() : null;
      return OtpResponseModel.error(errorMsg ?? 'Network error: ${e.message}');
    } catch (e) {
      return OtpResponseModel.error('Unexpected error: $e');
    }
  }

  // ------------------------ VERIFY OTP ------------------------
  Future<VerifyOtpResponse> verifyOtp({
    required String phoneNumber,
    required String otpRef,
    required String otp,
  }) async {
    try {
      final response = await _apiClient.post(
        '/customer/login',
        data: {
          'phone_number': '+91$phoneNumber',
          'otp_ref': otpRef,
          'otp': otp,
        },
        options: Options(
          headers: {
            'x-public-ip': '27.107.213.154',
            'Content-Type': 'application/json',
          },
          sendTimeout: const Duration(minutes: 1),
          receiveTimeout: const Duration(minutes: 1),
        ),
      );

      print('VERIFYING OTP WITH:');
      print('  phone: $phoneNumber');
      print('  otpRef: $otpRef');
      print('  otp: $otp');

      print('✅ VERIFY OTP RESPONSE: ${response.data}');
      return VerifyOtpResponse.fromJson(response.data);
    } on DioException catch (e) {
      // TIMEOUT CHECK
      if (e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionTimeout) {
        return VerifyOtpResponse.error('Server down, please try again later');
      }

      final errorMsg = e.response?.data is Map ? e.response?.data['message']?.toString() : null;
      return VerifyOtpResponse.error(errorMsg ?? e.message ?? 'Network error');
    } catch (e) {
      return VerifyOtpResponse.error('Unexpected error: $e');
    }
  }
}
