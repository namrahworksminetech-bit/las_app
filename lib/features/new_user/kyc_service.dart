import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:las_app/common_widgets/webview_screen.dart';
import 'package:las_app/core/network/api_client.dart';
import 'package:las_app/core/utils/location_service.dart';
import 'repository/kyc_repo.dart';

class KycRepository {
  static Future<void> startKyc(
    BuildContext context, {
    required String lenderCode,
    required String reqId,
    required String stepName,
    required VoidCallback onSuccess,
    VoidCallback? onKycComplete,
  }) async {
    try {
      print('🚀 Starting KYC for step: $stepName');

      // Get mandatory location - forces user to enable location service
      final location = await LocationService.getCurrentLocationMandatory(context);
      print('✅ Location obtained: ${location.latitude}, ${location.longitude}');

      // Get KYC repository instance
      final kycRepo = KycRepo(GetIt.instance<ApiClient>());

      // Start KYC
      final response = await kycRepo.startKyc(
        reqId: reqId,
        lenderCode: lenderCode,
        latitude: location.latitude,
        longitude: location.longitude,
      );

      print('✅ KYC started successfully');
      print('🔗 KYC URL: ${response.data.url}');

      // Navigate to WebView if URL is available
      if (response.data.url.isNotEmpty && context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WebViewScreen(
              url: response.data.url,
              title: stepName,
              onKycComplete: onKycComplete,
            ),
          ),
        );
        onSuccess();
      }
    } catch (e) {
      print('❌ Error starting KYC: $e');
    }
  }
}
