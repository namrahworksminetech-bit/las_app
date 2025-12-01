import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/results/result.dart';

class PanVerifyRepository {
  final ApiClient _apiClient;

  PanVerifyRepository(this._apiClient);

  Future<Result<String>> getLenderCode({
    required String reqId,
    required String authToken,
  }) async {
    try {
      final response = await _apiClient.post(
        '/customer/verify-pan',
        data: {'req_id': reqId},
        options: Options(headers: {'Authorization': 'Bearer $authToken'}),
      );

      if (response.statusCode == 200) {
        final lenderCode = response.data['data']?['lender_code'] as String?;
        if (lenderCode != null) {
          return Success(lenderCode);
        } else {
          return Failure('Lender code not found');
        }
      } else {
        return Failure('Failed to get lender code');
      }
    } on DioException catch (e) {
      print("❌ Dio error: ${e.response?.data}");
      return Failure(
        e.response?.data['message'] ?? e.message ?? 'Network error',
      );
    } catch (e) {
      return Failure('Error: $e');
    }
  }
}
