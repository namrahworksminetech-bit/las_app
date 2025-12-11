import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:las_app/core/network/api_client.dart';
import 'package:las_app/core/utils/location_service.dart';
import 'package:las_app/core/app_state_provider.dart';

import '../../../core/network/api_constants.dart';

class VideoKycRepository {
  final ApiClient _api;

  VideoKycRepository() : _api = GetIt.instance<ApiClient>();

  Future<String> startVcipApplication({required String reqId}) async {
    final appState = GetIt.instance<AppStateProvider>();

    final token = appState.token;
    if (token == null || token.isEmpty) {
      throw Exception("Missing auth token");
    }

    final location = await LocationService.getCurrentLocation();
    if (location == null) {
      throw Exception('Unable to obtain location');
    }

    final Map<String, dynamic> body = {
      "req_id": reqId,
      "lattitude": "${location.latitude}",
      "longitude": "${location.longitude}",
      "sourceMode": kIsWeb ? "web" : "app",
    };

    const String endpoint =
        "${ApiConstants.baseUrl}customer/apply-vcip-application";

    final result = await _api.post(
      endpoint,
      data: body,
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      ),
    );

    final resp = result.data;
    final data = resp?["data"];
    final message = resp?["message"];

    if (data != null &&
        data["url"] is String &&
        data["url"].toString().isNotEmpty) {
      return data["url"].toString();
    }

    throw Exception(message ?? "No URL returned from VCIP API");
  }
}
