import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:las_app/core/app_state_provider.dart';
import 'package:las_app/core/network/api_client.dart';
import 'package:las_app/core/results/result.dart';
import 'package:las_app/models/rta_otp/rta_otp_request_model.dart';
import 'package:las_app/models/rta_otp/rta_otp_response_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RtaOtpRepository {
  final ApiClient _apiClient;

  RtaOtpRepository(this._apiClient);

  Future<Result<RtaOtpResponseModel>> verifyRtaOtp({
    required String reqId,
    required String phone,
    required String rta,
    required String otp,
    String refNo = '',
  }) async {
    try {
      final request = RtaOtpRequestModel(
        reqId: reqId,
        otpDetails: [OtpDetail(phone: phone, rta: rta, otp: otp, refNo: refNo)],
      );
      final appState = GetIt.instance<AppStateProvider>();
      final authToken = appState.token;

      final response = await _apiClient.post(
        'customer/verify-rta-otp',
        data: request.toJson(),
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $authToken',
          },
        ),
      );

      return Success(RtaOtpResponseModel.fromJson(response.data));
    } on DioException catch (e) {
      if (e.response != null) {
        final responseData = e.response!.data;
        if (responseData is Map<String, dynamic>) {
          final message = responseData['message'] ?? 'Verification failed';
          return Failure(message);
        }
      }

      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return Failure('Connection timeout. Please try again.');
        case DioExceptionType.connectionError:
          return Failure('No internet connection. Please check your network.');
        default:
          return Failure('Network error occurred. Please try again.');
      }
    } catch (e) {
      return Failure('Something went wrong. Please try again.');
    }
  }
}
