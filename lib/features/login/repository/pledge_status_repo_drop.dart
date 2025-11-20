// features/new_user/repository/pledge_mf_repo.dart

import 'package:dio/dio.dart';
import 'package:las_app/models/funds/pledge_mf_response.dart';
import '../../../core/network/api_client.dart';


class PledgeMfRepository {
  final ApiClient _apiClient;

  PledgeMfRepository(this._apiClient);

  /// POST /lamf/customer/pledge-mf
  /// body: { "req_id": "<reqId>", "type": "verified" }
  /// headers: Content-Type: application/json, Authorization: Bearer <token>
  Future<PledgeMfResponse> notifyPledgeMf({
    required String reqId,
    required String authToken,
  }) async {
    try {
      final response = await _apiClient.post(
        'customer/pledge-mf',
        data: {
          'req_id': reqId,
          'type': 'verified',
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
      final msg = e.response?.data != null && e.response?.data['message'] != null
          ? e.response?.data['message'].toString()
          : e.message ?? 'Network error';
      return PledgeMfResponse.error('ERROR');
    } catch (e) {
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
