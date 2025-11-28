import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:las_app/core/network/api_client.dart';
import 'package:las_app/core/results/result.dart';
import 'package:las_app/core/app_state_provider.dart';

class InsuranceRepository {
  final ApiClient _apiClient;
  final AppStateProvider _appState;

  InsuranceRepository()
      : _apiClient = GetIt.instance<ApiClient>(),
        _appState = GetIt.instance<AppStateProvider>();

  String? uploadUrl;
  String? uploadKey;

  /// 1️⃣ Fetch insurer list
  Future<Result<List<Map<String, dynamic>>>> getInsurers() async {
    const url = "https://api-uat.valuenable.in/lamf/laip/get-company";

    try {
      final token = _appState.token;

      final response = await _apiClient.post(
        url,
        options: Options(
          headers: {
            if (token != null) "Authorization": "Bearer $token",
          },
        ),
      );

      final list = (response.data["data"] as List)
          .map((e) => {
                "name": e["name"],
                "code": e["code"],
              })
          .toList();

      return Success(list);
    } catch (e) {
      return Failure("Failed to fetch insurers → $e");
    }
  }

  /// 2️⃣ GET Upload URL for both unit + policy doc
  Future<Result<bool>> getUploadUrl(String fileType) async {
    const url = "https://api-uat.valuenable.in/lamf/laip/get-document-url";

    try {
      final response = await _apiClient.post(url, data: {"fileType": fileType});

      final data = response.data?["data"];
      if (data == null) return Failure("Invalid upload URL response");

      uploadUrl = data["uploadUrl"];
      uploadKey = data["uploadKey"];

      print("UPLOAD_URL: $uploadUrl");
      print("UPLOAD_KEY: $uploadKey");

      return Success(true);
    } catch (e) {
      return Failure("URL fetch failed → $e");
    }
  }

  /// 3️⃣ Upload file to S3
  Future<Result<String>> uploadFile({
    required Uint8List bytes,
    required String mimeType,
    required String fileType,
  }) async {
    if (uploadUrl == null) return Failure("Upload URL missing");

    try {
      final dio = Dio();

      final res = await dio.put(
        uploadUrl!,
        data: Stream.fromIterable(bytes.map((e) => [e])),
        options: Options(
          headers: {
            "Content-Type": mimeType,
            "Content-Length": bytes.length.toString(),
          },
        ),
      );

      if (res.statusCode == 200) {
        return Success(uploadKey!);
      }
      return Failure("Upload failed → ${res.statusCode}");
    } catch (e) {
      return Failure("Upload error → $e");
    }
  }

  /// 4️⃣ Final submit API
/// 4️⃣ Final submit API
Future<Result<bool>> submitInsurance({
  required String insurerCode,
  required String name,
  required String dob,
  required String policyNumber,
  required String unitFileKey,
  required String policyFileKey,
}) async {

  final appState = GetIt.instance<AppStateProvider>();   // ⬅ same like RTA repo
  final mobile = appState.mobileNumber;                  // ⬅ global saved number
  final token = appState.token;                          // ⬅ if needed for auth

  print("📲 Insurance Submit Mobile: $mobile");
  print("🔑 Insurance Submit Token: $token");

  // for now use fallback if null so we do not block submission
  final mobileToSend = mobile ?? "9999999999";

  try {
    final response = await _apiClient.post(
      "https://api-uat.valuenable.in/lamf/laip/submit-policy-detail",
      data: {
        "company_code": insurerCode,
        "name": name,
        "dob": dob,
        "mobile_number": mobileToSend,     // ⬅ ALWAYS sending value now
        "policy_number": policyNumber,
        "unit_statement_path": unitFileKey,
        "policy_document_path": policyFileKey,
      },
      options: Options(
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',   // like RTA repo
        },
      ),
    );

    print("🎉 SUBMIT SUCCESS: ${response.data}");
    return Success(true);

  } catch (e) {
    print("❌ SUBMIT FAILED: $e");
    return Failure("Submit failed → $e");
  }
}

}
