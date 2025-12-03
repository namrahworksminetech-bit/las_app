// import 'package:dio/dio.dart';
// import 'package:flutter/cupertino.dart';

// import 'model_dashboard.dart';

// class DashboardRepository {
//   Future<DashboardResult> getDashboard(reqId) async {
//     try {
//       final token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJtb2JpbGUiOiIrOTE5MDAwMDEwMDAwIiwidXNlcklkIjozMjA4LCJpYXQiOjE3NjMzODQwNjEsImV4cCI6MTc2MzM4NTg2MX0.XRbWDVq48YBbMEUFK-nAhnWQi6SQHyqjjs4Aq19q2y4';
//       // final response = await ApiClient().post(
//       //   '/customer-portal/user-dashboard',
//       //   data: {'req_id': reqId},
//       //   options: Options(
//       //     headers: {
//       //       'Authorization': 'Bearer $token',
//       //       'Content-Type': 'application/json',
//       //     },
//       //   ),
//       // );

//       // return DashboardResult.fromJson(response.data);
//       return DashboardResult.fromJson({
//         "status": "success",
//         "data": {
//           "name": "Mehta Abhishek Haresh ",
//           "available_credit_limit": "26728.00",
//           "withdrawn": "7450",
//           "interest_rate": "10.20",
//           "mf_pledges": 1,
//           "account_Number": "06521140002896",
//           "account_ifsc": "HDFC0000652",
//           "ClientBankName": "HDFC BANK LTD1",
//           "upcoming_repayment": {
//             "interest_payment": "AUTO DEBIT",
//             "due_date": "07 December, 2025",
//           },
//           "availableAmount": "19278.0000",
//           "DrawingPower": "35884.0000",
//           "lan": "63224604682564",
//           "fas": "218061",
//           "shortfallAmount": "0.00",
//         },
//         "message": "Customer Dashboard Data fetched successfully",
//       });
//     } on DioException catch (e) {
//       debugPrint('Error ::: ${e.error}');
//       debugPrint('Stack ::: ${e.stackTrace}');
//       return DashboardResult.fromJson(e.response?.data);
//     } catch (e) {
//       return DashboardResult.fromJson({});
//     }
//   }
// }
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';

import 'model_dashboard.dart';
import 'package:las_app/core/app_state_provider.dart';
import 'package:las_app/core/network/api_client.dart';

class DashboardRepository {
  final ApiClient _apiClient;
  final AppStateProvider _appState;

  DashboardRepository({
    ApiClient? apiClient,
    AppStateProvider? appState,
  })  : _apiClient = apiClient ?? GetIt.instance<ApiClient>(),
        _appState = appState ?? GetIt.instance<AppStateProvider>();

  Future<DashboardResult> getDashboard(reqId) async {
    try {
      /// Get token from AppState (same as RtaRepository)
      final token = _appState.token;

      if (token == null || token.isEmpty) {
        throw Exception('Missing auth token');
      }

      final response = await ApiClient().post(
        '/customer-portal/user-dashboard',
        data: {'req_id': reqId},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return DashboardResult.fromJson(response.data);

      /// TEMPORARY MOCK DATA (UNCHANGED)
      return DashboardResult.fromJson({
        "status": "success",
        "data": {
          "name": "Mehta Abhishek Haresh ",
          "available_credit_limit": "26728.00",
          "withdrawn": "7450",
          "interest_rate": "10.20",
          "mf_pledges": 1,
          "account_Number": "06521140002896",
          "account_ifsc": "HDFC0000652",
          "ClientBankName": "HDFC BANK LTD1",
          "upcoming_repayment": {
            "interest_payment": "AUTO DEBIT",
            "due_date": "07 December, 2025",
          },
          "availableAmount": "19278.0000",
          "DrawingPower": "35884.0000",
          "lan": "63224604682564",
          "fas": "218061",
          "shortfallAmount": "0.00",
        },
        "message": "Customer Dashboard Data fetched successfully",
      });
    } on DioException catch (e) {
      debugPrint('Error ::: ${e.error}');
      debugPrint('Stack ::: ${e.stackTrace}');
      return DashboardResult.fromJson(e.response?.data);
    } catch (e) {
      return DashboardResult.fromJson({});
    }
  }
}
