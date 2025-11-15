import 'package:dio/dio.dart';
import 'package:las_app/core/network/api_client.dart';
import 'package:las_app/core/results/result.dart';

class PledgeStatusRepository {
  final ApiClient _apiClient;
  PledgeStatusRepository(this._apiClient);

  Future<Result<Map<String, dynamic>>> checkPledgeStatus({
    required String reqId,
    required String authToken,
  }) async {
    try {
      final response = await _apiClient.post(
        'customer/pledge-mf',
        data: {
          'req_id': reqId,
          'type': 'pending',   // ⬅️ REQUIRED FIELD
        },
        options: Options(headers: {
          'Authorization': 'Bearer $authToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        }),
      );

      if (response.data is Map<String, dynamic>) {
        return Success(response.data as Map<String, dynamic>);
      } else {
        return Failure('Invalid pledge status format');
      }
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? e.message ?? 'Network error';
      return Failure(message);
    } catch (e) {
      return Failure('Unexpected error: $e');
    }
  }
}
