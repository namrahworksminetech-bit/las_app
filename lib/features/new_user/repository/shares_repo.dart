import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:las_app/core/network/api_client.dart';
import 'package:las_app/core/results/result.dart';
import 'package:las_app/core/app_state_provider.dart';

import '../../../core/network/api_constants.dart';

class SharesRepository {
  final ApiClient _apiClient;
  final AppStateProvider _appState;

  SharesRepository()
      : _apiClient = GetIt.instance<ApiClient>(),
        _appState = GetIt.instance<AppStateProvider>();

  String? uploadUrl;
  String? uploadKey;

  /// 1️⃣ Fetch Upload URL (pre-signed S3 URL)
  Future<Result<bool>> getUploadUrl(String fileType) async {
    const url = "${ApiConstants.baseUrl}laip/get-document-url";

    try {
      final response = await _apiClient.post(
        url,
        data: {"fileType": fileType},
      );

      final data = response.data?["data"];
      if (data == null) return Failure("No upload URL returned");

      uploadUrl = data["uploadUrl"];
      uploadKey = data["uploadKey"]; // ← this is the KEY backend expects later

      print("🔗 uploadUrl  = $uploadUrl");
      print("🔑 uploadKey  = $uploadKey");

      return Success(true);
    } catch (e) {
      return Failure("URL fetch failed → $e");
    }
  }

  /// 2️⃣ Upload file to S3 using PUT
  Future<Result<bool>> uploadFile({
    required String documentType,  // same as old documentType
    required String mimeType,
    required Uint8List bytes,
  }) async {
    if (uploadUrl == null) return Failure("Upload URL missing!");

    try {
      final dio = Dio();

      print("\n📤 PUT Upload starting...");
      print("UPLOAD_URL = $uploadUrl");
      print("UPLOAD_KEY = $uploadKey");
      print("MIME       = $mimeType");
      print("SIZE       = ${bytes.length} bytes\n");

      final response = await dio.put(
        uploadUrl!,
        data: Stream.fromIterable(bytes.map((e) => [e])),
        options: Options(
          headers: {
            "Content-Type": mimeType,
            "Content-Length": bytes.length.toString(),
          },
        ),
      );

      print("⬅ S3 RESPONSE: ${response.statusCode}");

      if (response.statusCode == 200) {
        print("✔ FILE UPLOADED SUCCESSFULLY");
        print("📌 FINAL KEY TO USE = $uploadKey\n");
        return Success(true);
      }

      return Failure("Upload failed → Status ${response.statusCode}");
    } catch (e) {
      print("❌ Upload Error → $e");
      return Failure("Upload error → $e");
    }
  }

  /// 3️⃣ Submit Share details – NOW TAKES KEY EXPLICITLY
  Future<Result<bool>> submitShare({
    required String broker,
    required String dpId,
    required String holdingKey, // 👈 pass key from Bloc
  }) async {
    const url = "${ApiConstants.baseUrl}laip/submit-share-detail";

    try {
      final token = _appState.token;

      print("📤 FINAL SUBMIT CALL");
      print("company                = $broker");
      print("participant            = $dpId");
      print("holding_statement_path = $holdingKey");

      final response = await _apiClient.post(
        url,
        data: {
          "company": broker,
          "participant": dpId,
          "holding_statement_path": holdingKey, // ✅ never null now
          "source": kIsWeb ? "web" : "app",
        },
        options: Options(
          headers: {
            if (token != null) "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );

      print("⬅ SUBMIT RESPONSE STATUS: ${response.statusCode}");
      print("⬅ SUBMIT RESPONSE DATA  : ${response.data}");

      if (response.data?["status"] == "success") {
        return Success(true);
      }

      return Failure(response.data?["message"] ?? "Submission failed");
    } catch (e) {
      return Failure("Submit error → $e");
    }
  }
}
