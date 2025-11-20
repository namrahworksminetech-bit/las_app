// lib/features/new_user/repository/rta_repository.dart
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'package:las_app/core/app_state_provider.dart';
import 'package:las_app/core/network/api_client.dart';

class RtaRepository {
  final ApiClient _apiClient;
  final AppStateProvider _appState;

  RtaRepository({ApiClient? apiClient, AppStateProvider? appState})
      : _apiClient = apiClient ?? GetIt.instance<ApiClient>(),
        _appState = appState ?? GetIt.instance<AppStateProvider>();

  /// Verifies RTA OTP and returns req_id on success.
  Future<String> verifyRtaOtp({
    required String phone,
    required String otp,
    String rta = 'MFCENTRAL',
    String refNo = '',
  }) async {
    final token = _appState.token;
    final reqId = _appState.reqId;

    if (token == null || token.isEmpty) {
      throw Exception('Missing auth token');
    }
    if (reqId == null || reqId.isEmpty) {
      throw Exception('Missing req_id in AppState');
    }

    final url = 'https://api-dev.valuenable.in/lamf/customer/verify-rta-otp';

    final Map<String, dynamic> body = {
      "req_id": reqId,
      "otp_details": [
        {
          "phone": phone, // ensure +91 prefix already applied
          "rta": rta,
          "otp": otp,
          "ref_no": refNo,
        }
      ]
    };

    try {
      final response = await _apiClient.post(
        url,
        data: body,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          sendTimeout: const Duration(minutes: 1),
          receiveTimeout: const Duration(minutes: 1),
        ),
      );

      final respData = response.data;
      if (respData == null) {
        throw Exception('Empty response from server');
      }

      final status = respData['status']?.toString().toLowerCase();
      final message = respData['message'] ?? '';
      final data = respData['data'];

      if ((status == 'success' ||
              response.statusCode == 200 ||
              response.statusCode == 201) &&
          data != null &&
          data['req_id'] != null) {
        return data['req_id'].toString();
      }

      throw Exception(message.isNotEmpty ? message : 'OTP verification failed');
    } on DioException catch (e) {
      final serverMsg = e.response?.data?['message'];
      if (e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Server down, please try again later');
      }
      throw Exception(serverMsg ?? e.message ?? 'Network error');
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
