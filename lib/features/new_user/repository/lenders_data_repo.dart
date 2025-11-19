import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:las_app/core/app_state_provider.dart';
import 'package:las_app/core/network/api_client.dart';
import 'package:las_app/core/results/result.dart';
import 'package:las_app/models/funds/mf_details_response_model.dart';

class LenderRepository {
  final ApiClient _apiClient;

  LenderRepository(this._apiClient);
Future<Result<MfDetailsResponse>> fetchLendersAndPortfolio({
  required String reqId,
  bool useMock = false, // 🔥 mock toggle added
}) async {
  try {
    final appState = GetIt.instance<AppStateProvider>();
    final authToken = appState.token;

    if (authToken == null || authToken.isEmpty) {
      return Failure("Missing auth token. Please login again.");
    }

 

    // 🧾 LIVE API CALL
    final response = await _apiClient.post(
      'customer/get-mf-details',
      data: {'req_id': reqId},
      options: Options(
        headers: {
          'Authorization': 'Bearer $authToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    final decoded = response.data;

    if (decoded is Map<String, dynamic>) {
      final mfDetails = MfDetailsResponse.fromJson(decoded);

      print("✅ Lenders parsed: ${mfDetails.lenders.length}");
      print("✅ Pledgeable funds parsed: ${mfDetails.pledgeableFunds.length}");

      return Success(mfDetails);
    } else {
      return Failure("Invalid response format from server.");
    }
  } on DioException catch (e) {
    print("⏰ Dio timeout or error: ${e.type}");
    final msg = e.response?.data?['message'] ??
        e.message ??
        'Network error occurred.';
    return Failure(msg);
  } catch (e) {
    print("❌ Unexpected error: $e");
    return Failure('Unexpected error: $e');
  }
}


  Future<Result<MfDetailsResponse>> editLoanAmount({
  required String reqId,
  required double loanAmount,
  required String lenderId,
  required List<String> isinAdd,
  required List<String> isinRemove,
  required List<String> isinModify,
}) async {
  try {
    final appState = GetIt.instance<AppStateProvider>();
    final authToken = appState.token;

    if (authToken == null || authToken.isEmpty) {
      return Failure("Missing auth token. Please login again.");
    }

    final body = {
      "req_id": reqId,
      "loan_amount": loanAmount,
      "lender_id": lenderId.toString(),
      "isin_add": isinAdd,
      "isin_remove": isinRemove,
      "isin_modify": isinModify,
    };

    final bodyJson = jsonEncode(body);
    print("📤 Edit Loan Amount Request JSON: $bodyJson");
    print("📤 Headers: Authorization Bearer present: ${authToken.length > 8}");

    final response = await _apiClient.post(
      "https://api-dev.valuenable.in/lamf/customer/edit-loan-amount",
      data: bodyJson,
      options: Options(
        headers: {
          'Authorization': 'Bearer $authToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    print("📥 HTTP code: ${response.statusCode}");
    print("📥 Raw response data: ${response.data}");

    // response.data might already be a Map or a JSON string
    Map<String, dynamic> decoded;
    if (response.data is String) {
      decoded = jsonDecode(response.data);
    } else if (response.data is Map<String, dynamic>) {
      decoded = response.data as Map<String, dynamic>;
    } else {
      // fallback
      decoded = {};
    }

    // Treat any 2xx as success
    if (response.statusCode == null || response.statusCode! < 200 || response.statusCode! >= 300) {
      final msg = decoded['message'] ?? 'Invalid request (status ${response.statusCode})';
      print("⚠️ Server responded with ${response.statusCode}: $msg");
      return Failure(msg);
    }

    if ((decoded['status']?.toString().toLowerCase() ?? '') == 'success') {
      final mfDetails = MfDetailsResponse.fromJson(decoded);
      return Success(mfDetails);
    } else {
      final msg = decoded['message'] ?? 'Unknown API error';
      print("⚠️ API returned failure: $msg");
      return Failure(msg);
    }
  } on DioException catch (e) {
    print("⏰ Dio timeout or error: ${e.type} - ${e.message}");
    final msg = e.response?.data?['message'] ?? e.message ?? 'Network error';
    return Failure(msg);
  } catch (e, st) {
    print("💥 Unexpected error: $e\n$st");
    return Failure('Unexpected error: $e');
  }
}
}
  