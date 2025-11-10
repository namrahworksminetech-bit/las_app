import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:las_app/core/app_state_provider.dart';
import 'package:las_app/core/injection_container.dart';
import 'package:las_app/core/network/api_client.dart';
import 'package:las_app/core/results/result.dart';
import 'package:las_app/models/pan_verification/pan_otp_response_model.dart';
import 'package:las_app/models/pan_verification/pan_verify_response_model.dart';

class PanRepository {
  final ApiClient _apiClient;
  final AppStateProvider _appState = getIt<AppStateProvider>();
  final _storage = const FlutterSecureStorage();

  PanRepository(this._apiClient);

  // Toggle this flag to switch between mock and live APIs easily
  static const bool useMock = true;

  // 🔹 Step 1: Verify PAN
  Future<Result<PanVerifyResponseModel>> verifyPan({
    required String reqId,
    required String pan,
    required String name,
    required String dob,
    required String email,
  }) async {
    try {
      final token = await _storage.read(key: 'token');
      if (token == null || token.isEmpty) {
        throw Exception('Token missing! Please login again.');
      }

      final formattedDob = dob.replaceAll('/', '-');
      final consentTimestamp = DateTime.now().millisecondsSinceEpoch.toString();

      final body = {
        'req_id': reqId,
        'pan': pan,
        'name': name,
        'dob': formattedDob,
        'email': email,
        'source': 'web',
        'consent_timestamp': consentTimestamp,
      };

      // 🟢 MOCK RESPONSE (fast test mode)
      if (useMock) {
        await Future.delayed(const Duration(seconds: 1));
        final mockResponse = {
          "status": "success",
          "data": {
            "id": "a3866a0c-b63b-11f0-adb1-0ac0d6a50e11",
            "mobile_verified": false,
            "name_verified": false,
            "dob_verified": false,
            "lender_code": null,
            "status": "pan_verified"
          },
          "message": "PAN Verified successfully"
        };
        return Success(PanVerifyResponseModel.fromJson(mockResponse));
      }

      // 🧾 Live API call (uncomment when server stabilizes)
      /*
      final response = await _apiClient.post(
        'customer/verify-pan',
        data: body,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      return Success(PanVerifyResponseModel.fromJson(response.data));
      */

    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? e.message ?? 'Network error';
      return Failure(message);
    } catch (e) {
      return Failure('Unexpected error: $e');
    }
    return Failure('No response generated from verifyPan');
  }

  // 🔹 Step 2: Generate PAN OTP
  Future<Result<PanGenerateOtpResponseModel>> generateOtp() async {
    final reqId = _appState.reqId;
    if (reqId == null || reqId.isEmpty) {
      return Failure("Missing reqId from AppStateProvider");
    }

    try {
      // 🟢 MOCK RESPONSE
      if (useMock) {
        await Future.delayed(const Duration(seconds: 1));
        final mockResponse = {
          "status": "success",
          "data": {
            "client_ref_no": "a3866a0c-b63b-11f0-adb1-0ac0d6a50e11",
          },
          "message": "OTP sent successfully"
        };
        return Success(PanGenerateOtpResponseModel.fromJson(mockResponse));
      }

      // 🧾 Live API call
      /*
      final response = await _apiClient.post(
        'customer/generate-otp',
        data: {'req_id': reqId},
      );
      return Success(PanGenerateOtpResponseModel.fromJson(response.data));
      */

    } on DioException catch (e) {
      return Failure(e.response?.data['message'] ?? e.message ?? 'Network error');
    } catch (e) {
      return Failure('Unexpected error: $e');
    }
    return Failure('No response generated from genertae otpPan');
  }

  // 🔹 Step 3: Verify PAN OTP
  Future<Result<PanVerifyResponseModel>> verifyOtp({
    required String otp,
  }) async {
    final reqId = _appState.reqId;
    if (reqId == null || reqId.isEmpty) {
      return Failure("Missing reqId from AppStateProvider");
    }

    try {
      final token = await _storage.read(key: 'token');
      print("🔐 Token before verify OTP: $token");

      if (token == null || token.isEmpty) {
        throw Exception('Token missing! Please login again.');
      }

      // 🟢 MOCK RESPONSE
      if (useMock) {
        await Future.delayed(const Duration(seconds: 1));
        final mockResponse = {
          "status": "success",
          "data": {
            "req_id": "a3866a0c-b63b-11f0-adb1-0ac0d6a50e11"
          },
          "message": "OTP verified successfully"
        };
        return Success(PanVerifyResponseModel.fromJson(mockResponse));
      }

      // 🧾 Live API call
      /*
      final response = await _apiClient.post(
        'customer/verify-otp',
        data: {
          'req_id': reqId,
          'otp': otp,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      return Success(PanVerifyResponseModel.fromJson(response.data));
      */

    } on DioException catch (e) {
      print("❌ Dio error: ${e.response?.data}");
      return Failure(e.response?.data['message'] ?? e.message ?? 'Network error');
    } catch (e) {
      print("❌ Unexpected error: $e");
      return Failure('Unexpected error: $e');
    }
    return Failure('No response generated from verify otp pan');
  }

  // ✅ Save token after OTP verification (Login)
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'token', value: token);
  }

  // ✅ Clear token if needed
  Future<void> clearToken() async {
    await _storage.delete(key: 'token');
  }
}
