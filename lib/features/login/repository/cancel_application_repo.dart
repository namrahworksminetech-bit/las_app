// lib/features/dashboard/application_repository.dart
import 'package:dio/dio.dart';
import 'package:las_app/core/network/api_client.dart';
import 'package:las_app/core/results/result.dart';

class ApplicationRepository {
  final ApiClient _apiClient;

  ApplicationRepository(this._apiClient);

  /// POST /lamf/customer/cancel-application
  /// Body: { "req_id": "<reqId>" }
  /// Header: Authorization: Bearer <token>
  Future<Result<Map<String, dynamic>>> cancelApplication({
    required String reqId,
    required String authToken,
  }) async {
    try {
      final response = await _apiClient.post(
        '/customer/cancel-application',
        data: {'req_id': reqId},
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        }),
      );

      // Accept 2xx success
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final Map<String, dynamic> json =
            response.data is Map ? Map<String, dynamic>.from(response.data) : {};
        return Success(json);
      } else {
        final message = response.data is Map && response.data['message'] != null
            ? response.data['message'].toString()
            : 'Unexpected status: ${response.statusCode}';
        return Failure(message);
      }
    } on DioException catch (e) {
      final serverMsg = e.response?.data is Map && e.response?.data['message'] != null
          ? e.response?.data['message'].toString()
          : e.message ?? 'Network error';
      return Failure(serverMsg!);
    } catch (e) {
      return Failure('Unexpected error: $e');
    }
  }
}
