import 'package:dio/dio.dart';
import 'package:las_app/core/network/api_client.dart';

class DashboardRepository {
  // Future<OtpResponseModel> getDashboard() async {
  //   try {
  //     final response = await ApiClient().post(
  //       '/customer/send-otp',
  //       data: {'phone_number': phoneNumber},
  //     );
  //
  //     if (response.statusCode == 200) {
  //       return OtpResponseModel.fromJson(response.data);
  //     } else {
  //       return OtpResponseModel.error(
  //         'Unexpected status: ${response.statusCode}',
  //       );
  //     }
  //   } on DioException catch (e) {
  //     if (e.response?.statusCode == 403) {
  //       return OtpResponseModel.error('Forbidden');
  //     }
  //     return OtpResponseModel.error(
  //       e.response?.data['message'] ?? 'Network error: ${e.message}',
  //     );
  //   } catch (e) {
  //     return OtpResponseModel.error('Unexpected error: $e');
  //   }
  // }
}
