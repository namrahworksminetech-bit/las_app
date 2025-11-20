import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/results/result.dart';

class PledgeStatusRepository {
  final ApiClient _apiClient;

  PledgeStatusRepository(this._apiClient);

  Future<Result<Map<String, dynamic>>> checkPledgeStatus({
    required String reqId,
    required String authToken,
  }) async {
    try {
      final response = await _apiClient.post(
        '/customer/pledge-mf',
        data: {'req_id': reqId, 'type': 'pledge'},
        options: Options(
          headers: {
            'Authorization': 'Bearer $authToken',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Success(response.data);
      } else {
        return Failure('Failed to check pledge status');
      }
    } catch (e) {
      return Failure('Error: $e');
    }
  }
}
