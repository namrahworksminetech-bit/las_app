// features/new_user/repository/pledge_mf_repo.dart

import 'package:dio/dio.dart';
import 'package:las_app/models/funds/pledge_mf_response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';


class PledgeMfRepository {
  final ApiClient _apiClient;

  PledgeMfRepository(this._apiClient);

  static const _kReqIdKey = 'req_id';

  /// POST /lamf/customer/pledge-mf
  /// body: { "req_id": "<reqId>", "type": "verified" }
  /// headers: Content-Type: application/json, Authorization: Bearer <token>
  ///
  /// If [reqId] is empty, repo will try to read a stored req_id from SharedPreferences.
  Future<PledgeMfResponse> notifyPledgeMf({
    required String reqId,
    required String authToken,
  }) async {
    try {
      // If caller passed an empty reqId, try to load from SharedPreferences
      String finalReqId = reqId?.trim() ?? '';
      if (finalReqId.isEmpty) {
        try {
          final prefs = await SharedPreferences.getInstance();
          final stored = prefs.getString(_kReqIdKey) ?? '';
          finalReqId = stored.trim();
        } catch (e) {
          // ignore prefs errors; we'll validate below
          print('Warning: failed to read req_id from SharedPreferences: $e');
        }
      }

      // Validate before calling server
      if (finalReqId.isEmpty) {
        return PledgeMfResponse.error('Missing req_id; cannot call pledge-mf');
      }

      final response = await _apiClient.post(
        'customer/pledge-mf',
        data: {
          'req_id': finalReqId,
          'type': 'verified', // or 'status' depending on your usage
        },
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        }),
      );

      // Accept success range 200-299
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final Map<String, dynamic> json =
            response.data is Map ? Map<String, dynamic>.from(response.data) : {};
        return PledgeMfResponse.fromJson(json);
      } else {
        final message = response.data is Map && response.data['message'] != null
            ? response.data['message'].toString()
            : 'Unexpected status: ${response.statusCode}';
        return PledgeMfResponse.error(message);
      }
    } on DioException catch (e) {
      // Extract server message if available
      final serverMsg = e.response?.data is Map && e.response?.data['message'] != null
          ? e.response?.data['message'].toString()
          : null;
      final msg = serverMsg ?? e.message ?? 'Network error';
      print('DioException in notifyPledgeMf: $msg');
      return PledgeMfResponse.error(msg);
    } catch (e) {
      print('Unexpected error in notifyPledgeMf: $e');
      return PledgeMfResponse.error('Unexpected error: $e');
    }
  }
}
// features/new_user/repository/pledge_mf_repo.dart
// features/new_user/repository/pledge_mf_repo.dart

// import 'package:dio/dio.dart';
// import 'package:las_app/models/funds/pledge_mf_response.dart';
// import '../../../core/network/api_client.dart';

// class PledgeMfRepository {
//   final ApiClient _apiClient;

//   PledgeMfRepository(this._apiClient);

//   /// MOCK VERSION
//   /// Does NOT call backend. Always returns mf_fetched for testing.
//   Future<PledgeMfResponse> notifyPledgeMf({
//     required String reqId,
//     required String authToken,
//   }) async {
//     await Future.delayed(const Duration(milliseconds: 400)); // simulate API delay

//     // 🔥 Mock Success Response (exact structure you shared)
//     final mockJson = {
//       "status": "success",
//       "data": {
//         "data": [],
//         "status": [
//           "kyc_done"    // <--- this is what triggers the portfolio fetch flow
//         ],
//         "isVcip": 0
//       },
//       "message": "Kyc in progress"
//     };

//     return PledgeMfResponse.fromJson(mockJson);
//   }
// }
