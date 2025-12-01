import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:las_app/core/network/api_client.dart';
import 'package:las_app/core/results/result.dart';

class AbclRepository {
  final ApiClient _apiClient = GetIt.I<ApiClient>();

  // 🔹 Permanent static reqId (as you requested)
  static const String staticReqId = "4edf04f6-ce95-11f0-9af3-0216e5a43c21";

  Future<Result<bool>> submitAbcl(Map<String, dynamic> body) async {
    body["req_id"] = staticReqId;   // always inject req_id here

    print("\n📤 SUBMITTING ABCL FORM");
    print("REQ_ID → $staticReqId");
    print("BODY → $body\n");

    try {
      final response = await _apiClient.post(
        "https://api-uat.valuenable.in/lamf/customer-portal/abcl-eligibility",
        data: body,
        options: Options(
          validateStatus: (status) => true, // prevent crash on 400
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
          },
        ),
      );

      print("📥 RESPONSE → ${response.data}");
      print("HTTP STATUS → ${response.statusCode}\n");

      if (response.statusCode == 200 && response.data["status"] == "success") {
        print("🎉 ABCL FORM SUBMITTED SUCCESSFULLY");
        return Success(true);
      } else {
        print("⚠ FAILURE → ${response.data["message"]}");
        return Failure(response.data["message"] ?? "Submission failed");
      }

    } catch (e) {
      print("❌ ERROR → $e");
      return Failure("Unexpected failure → $e");
    }
  }
}
