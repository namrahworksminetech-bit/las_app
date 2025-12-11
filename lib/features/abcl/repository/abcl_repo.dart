import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:las_app/core/network/api_client.dart';
import 'package:las_app/core/results/result.dart';
import 'package:las_app/core/app_state_provider.dart';

import '../../../core/network/api_constants.dart';

class AbclRepository {
  final ApiClient _apiClient = GetIt.I<ApiClient>();
  final AppStateProvider _appState = GetIt.I<AppStateProvider>();

  Future<Result<bool>> submitAbcl(Map<String, dynamic> body) async {
    final reqId = _appState.reqId;
    final token = _appState.token;

    print("📌 FETCHED req_id → $reqId");
    print("📌 TOKEN → $token");

    if (reqId == null || reqId.isEmpty) {
      print("⛔ ERROR: req_id is missing — Login required.");
      return Failure("req_id missing — please login again");
    }

    // 🔹 Ensure req_id present in body
    body["req_id"] = reqId;

    print("📤 SUBMITTING ABCL FORM → $body");

    try {
      final response = await _apiClient.post(
        "${ApiConstants.baseUrl}customer-portal/abcl-eligibility",
        data: body,
        options: Options(
          validateStatus: (status) => true,      // prevents exception on 400
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json",
            if (token != null) "Authorization": "Bearer $token",
          },
        ),
      );

      print("📥 API RESPONSE → ${response.data}");
      print("STATUS → ${response.statusCode}");

      if (response.statusCode == 200 && response.data["status"] == "success") {
        print("🎉 ABCL SUBMITTED SUCCESSFULLY");
        return Success(true);
      } else {
        final error = response.data["message"] ?? "Submission failed";
        print("⚠ API FAILURE → $error");
        return Failure(error);
      }

    } catch (e) {
      print("❌ UNEXPECTED FAILURE → $e");
      return Failure("Network or server error → $e");
    }
  }
}


//for navigation 
    // BlocProvider(
    //           create: (_) => AbclBloc(),
    //         ),
    //       ],

    //       /// ⚠️ Page that needs both blocs
    //       child: const EligibilityDetailsForm(),