import 'dart:async';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:las_app/core/app_state_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:kyc_workflow/digio_config.dart';
import 'package:kyc_workflow/environment.dart';
import 'package:kyc_workflow/gateway_event.dart';
import 'package:kyc_workflow/kyc_workflow.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/network/api_client.dart';
import '../../../core/results/result.dart';
import 'package:flutter/material.dart';
import '../view/webview_screen.dart';
import 'package:get/get.dart';
import '../../../common_widgets/webview_screen.dart' as CommonWebView;
import '../../../common_widgets/c_snackbar.dart';
import '../kyc_helper.dart';

class DigioRepository {
  final ApiClient _apiClient;
  Timer? _delayedUpdateTimer;

  DigioRepository(this._apiClient);

  Future<Result<Map<String, dynamic>>> getDigioConfig({
    required String reqId,
    BuildContext? context,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      print('❌ Token missing!');
      throw Exception('Token missing! Please login again.');
    }
    try {
      final response = await _apiClient.post(
        '/customer/get-digio-config',
        data: {'req_id': reqId},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ API Response: ${response.data}');
        final data = response.data['data'];
        if (data != null) {
          print('📋 Customer ID: ${data['customer_identifier']}');
          print('📋 ID: ${data['id']}');
          print('📋 Access Token: ${data['access_token']}');
          print('📋 Environment: ${data['environment']}');

          data['req_id'] = reqId; // Add req_id to data
          await startKycWorkflow(data, context);
        }
        return Success(response.data);
      } else {
        return Failure('Failed to get Digio config');
      }
    } on DioException catch (e) {
      print("⏰ Dio timeout or error: ${e.type}");
      final msg =
          e.response?.data?['message'] ??
          e.message ??
          'Network error occurred.';

      // Show snackbar for connection errors
      if (context != null && context.mounted) {
        CSnackBar.show(context, msg, isError: true);
      }

      return Failure(msg);
    } catch (e) {
      print('❌ Exception: $e');

      // Show snackbar for general errors
      if (context != null && context.mounted) {
        CSnackBar.show(context, 'Error: $e', isError: true);
      }

      return Failure('Error: $e');
    }
  }

  Future<String?> startKycWorkflow(
    dynamic data, [
    BuildContext? context,
  ]) async {
    PermissionStatus status = await Permission.camera.request();

    if (status.isGranted) {
      Map<String, dynamic> digioDetails = data;

      var workflowResult;
      try {
        var digioConfig = DigioConfig();
        digioConfig.theme.primaryColor = "#32a83a";
        // digioConfig.logo = "https://www.gstatic.com/mobilesdk/160503_mobilesdk/logo/2x/firebase_28dp.png";
        if (digioDetails["environment"] == "production") {
          digioConfig.environment = Environment.PRODUCTION;
        } else {
          digioConfig.environment = Environment.SANDBOX;
        }
        final _kycWorkflowPlugin = KycWorkflow(digioConfig);
        _kycWorkflowPlugin.setGatewayEventListener((
          GatewayEvent? gatewayEvent,
        ) {
          print("gateway funnel event" + gatewayEvent.toString());
        });
        // Validate required fields
        final id = digioDetails["id"]?.toString();
        final customerIdentifier = digioDetails["customer_identifier"]
            ?.toString();
        final accessToken = digioDetails["access_token"]?.toString();

        if (id == null || customerIdentifier == null || accessToken == null) {
          print('❌ Missing required Digio parameters');
          return null;
        }

        workflowResult = await _kycWorkflowPlugin.start(
          id,
          customerIdentifier,
          accessToken,
          null,
        );
        print('workflowResult : ' + workflowResult.toString());

        // Call KYC status update API after delay
        if (workflowResult != null) {
          print('🔄 Calling _updateKycStatus...');
          await Future.delayed(const Duration(seconds: 2));
          final reqId = digioDetails["req_id"]?.toString();
          print('📋 ReqId from digioDetails: $reqId');
          if (reqId != null) {
            final cleanDocumentId = KycHelper.extractDocumentId(
              workflowResult.toString(),
            );
            _delayedUpdateTimer = Timer(Duration(seconds: 110), () async {
              final result = await updateKycStatus(context, cleanDocumentId);
              print('✅ _updateKycStatus result: $result');
              if (result is Success<String?> && result.value != null) {
                // Don't open WebView, let native SDK handle KYC
                print('✅ KYC status updated, native SDK will handle the flow');
              }
            });
          } else {
            print('❌ ReqId is null in digioDetails');
          }
        } else {
          print('❌ workflowResult is null');
        }
      } on PlatformException {
        workflowResult = 'Failed to get platform version.';
      }
    } else if (status.isDenied) {
      print("❌ Camera permission denied");
    } else if (status.isPermanentlyDenied) {
      print("⚠️ Camera permission permanently denied. Open settings.");
      openAppSettings();
    }
    return null;
  }

  Future<Result<String?>> updateKycStatus(
    BuildContext? context,
    String documentId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final appState = GetIt.instance<AppStateProvider>();
    final reqId = appState.reqId;
    if (token == null || token.isEmpty) {
      print('❌ Token missing for KYC status update!');
      return const Failure('Token missing');
    }

    try {
      final response = await _apiClient.post(
        '/customer/update-pennydrop-status',
        data: {'req_id': reqId, 'kyc_id': documentId, 'kyc_status': 'success'},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ KYC status updated successfully');
        final data = response.data['data'];
        if (data != null && data['link'] != null) {
          final link = data['link'] as String;
          Get.to(
            () => CommonWebView.WebViewScreen(
              url: link,
              title: 'Penny Drop Verification',
            ),
          );
          return Success(link);
        }
        return const Success(null);
      } else {
        print('❌ Failed to update KYC status');
        return const Failure('Failed to update KYC status');
      }
    } on DioException catch (e) {
      print("⏰ Dio timeout or error: ${e.type}");
      final msg =
          e.response?.data?['message'] ??
          e.message ??
          'Network error occurred.';

      // Show snackbar for connection errors
      if (context != null && context.mounted) {
        CSnackBar.show(context, msg, isError: true);
      }

      return Failure(msg);
    } catch (e) {
      print('❌ Exception: $e');

      // Show snackbar for general errors
      if (context != null && context.mounted) {
        CSnackBar.show(context, 'Error: $e', isError: true);
      }

      return Failure('Error: $e');
    }

    // on DioException catch (e) {
    //   print("❌ Dio error: ${e.response?.data}");
    //   return Failure(
    //     e.response?.data['message'] ?? e.message ?? 'Network error',
    //   );
    // } catch (e) {
    //   print('❌ Error updating KYC status: $e');
    //   return Failure('Error: $e');
    // }

    // try {
    //   const staticUrl =
    //       "https://uat-loan.valuenable.in/location-request/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImJiNjVkNTEyLWM0NjMtMTFmMC1hNWIwLTBhZmM4NTk2ZDYyZiIsImN1c3RvbWVySWQiOjEwNjM1LCJ1c2VyIjp7Im5hbWUiOiJBc2h3aW4gUGFuZGV5IiwiZW1haWwiOiJtYW5pc2hAdmFsdWVuYWJsZS5pbiIsInJvbGVzIjpbIlVTRVIiXX0sInNvdXJjZSI6ImxhbWYiLCJsZW5kZXIiOiIiLCJpYXQiOjE3NjM2MTA3MzksImV4cCI6MTc2MzYxNzkzOX0.j5j-Mg7ADK6qAHZpN8GfZreTxB9OUCaQV1BT8eJGXaI";
    //
    //   // Open in WebView
    //   Get.to(
    //     () => CommonWebView.WebViewScreen(
    //       url: staticUrl,
    //       title: 'Penny Drop Verification',
    //     ),
    //   );
    //
    //   return const Success(staticUrl);
    // } catch (e) {
    //   print('❌ Error updating KYC status: $e');
    //   return Failure('Error: $e');
    // }
  }

  void cancelDelayedUpdate() {
    _delayedUpdateTimer?.cancel();
    _delayedUpdateTimer = null;
    print('🚫 Delayed update timer cancelled');
  }

  static void openWebView(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WebViewScreen(url: url)),
    );
  }
}
