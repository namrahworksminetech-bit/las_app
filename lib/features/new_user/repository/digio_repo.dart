import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:las_app/common_widgets/webview_screen.dart';
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
import 'package:get/get.dart';
import '../../../common_widgets/webview_screen.dart' as CommonWebView;
import '../../../common_widgets/c_snackbar.dart';
import '../kyc_helper.dart';

class DigioRepository {
  final ApiClient _apiClient;
  Timer? _pollingTimer;
  bool _isPollingActive = false;

  // in-memory cache to avoid duplicate concurrent penny-drop calls
  final Map<String, bool> _pennydropDoneCache = {};

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
        if (data != null && context != null) {
          print(
            '📋 Customer ID: ${data['customer_identifier'] ?? data['customer_id']}',
          );
          print('📋 ID: ${data['id']}');
          print('📋 Access Token: ${data['access_token']}');
          print('📋 Environment: ${data['environment']}');
          // Launch SDK workflow
          await startKycWorkflow(data, context);
        }
        return Success(response.data);
      } else {
        return Failure('Failed to get Digio config');
      }
    } on DioException catch (e) {
      print("⏰ Dio timeout or error: ${e.type}");
      final errorMsg = e.response?.data is Map
          ? e.response?.data['message']?.toString()
          : null;
      final msg = errorMsg ?? e.message ?? 'Network error occurred.';

      if (context != null && context.mounted) {
        CSnackBar.show(context, msg, isError: true);
      }

      return Failure(msg);
    } catch (e) {
      print('❌ Exception: $e');

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
    // Skip Digio SDK for web platform
    if (kIsWeb) {
      print('🌐 Web platform detected - skipping Digio SDK');
      return null;
    }

    PermissionStatus status = await Permission.camera.request();

    if (status.isGranted) {
      Map<String, dynamic> digioDetails = data;
      final reqId = digioDetails["req_id"]?.toString();

      if (reqId == null) return null;

      final prefs = await SharedPreferences.getInstance();
      
      // Always launch SDK fresh - don't check for existing docId
      String? cleanDocumentId;
      var workflowResult;

      try {
        var digioConfig = DigioConfig();
        digioConfig.theme.primaryColor = "#32a83a";
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

        final id = digioDetails["id"]?.toString();
        final customerIdentifier =
            digioDetails["customer_identifier"]?.toString() ??
            digioDetails["customer_id"]?.toString();
        final accessToken = digioDetails["access_token"]?.toString();

        if (id == null || customerIdentifier == null || accessToken == null) {
          print('❌ Missing required Digio parameters');
          return null;
        }

        print('🚀 Launching Digio SDK...');
        workflowResult = await _kycWorkflowPlugin.start(
          id,
          customerIdentifier,
          accessToken,
          null,
        );
        print('workflowResult : ' + workflowResult.toString());

        if (workflowResult != null && reqId != null) {
          cleanDocumentId = KycHelper.extractDocumentId(
            workflowResult.toString(),
          );
        }
      } on PlatformException catch (e) {
        print('❌ Platform exception: $e');
        workflowResult = 'Failed to get platform version.';
      }

      // Only start polling if KYC was actually completed
      if (cleanDocumentId != null && workflowResult != null) {
        String workflowStr = workflowResult.toString();
        if (workflowStr.contains('"message":"KYC process completed"')) {
          print('✅ KYC completed, saving docId and starting polling');
          await prefs.setString("docId$reqId", cleanDocumentId);
          startPollingKycStatus(context, cleanDocumentId);
        } else {
          print('⚠️ KYC not completed yet, not starting polling');
        }
      }
    } else if (status.isDenied) {
      print("❌ Camera permission denied");
    } else if (status.isPermanentlyDenied) {
      print("⚠️ Camera permission permanently denied. Open settings.");
      openAppSettings();
    }
    return null;
  }

  /// Update KYC status (penny-drop). Returns Success on 200/201.
  Future<Result<String?>> updateKycStatus(
    BuildContext? context,
    String documentId, {
    VoidCallback? onWebViewOpen,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final appState = GetIt.instance<AppStateProvider>();
    final reqId = appState.reqId;
    if (token == null || token.isEmpty) {
      print('❌ Token missing for KYC status update!');
      return const Failure('Token missing');
    }

    // If we've already recorded success for this reqId in-memory or persisted, skip early.
    if (reqId != null) {
      final persisted = prefs.getBool('pennydrop_done_$reqId') ?? false;
      if (persisted || (_pennydropDoneCache[reqId] == true)) {
        print(
          '🔁 Penny-drop already succeeded for reqId=$reqId, skipping updateKycStatus call.',
        );
        return const Success(null);
      }
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

        // Persist success flag so future polling won't call again
        if (reqId != null) {
          await prefs.setBool('pennydrop_done_$reqId', true);
          _pennydropDoneCache[reqId] = true;
        }

        if (data != null && data['link'] != null) {
          final link = data['link'] as String;
          onWebViewOpen?.call();
          // Opening the link in webview as before
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

      // Optionally show snackbar
      // if (context != null && context.mounted) {
      //   CSnackBar.show(context, msg, isError: true);
      // }

      return Failure(msg);
    } catch (e) {
      print('❌ Exception: $e');

      // if (context != null && context.mounted) {
      //   CSnackBar.show(context, 'Error: $e', isError: true);
      // }

      return Failure('Error: $e');
    }
  }

  /// Start polling Digio KYC status for given documentId. Will stop after success.
  void startPollingKycStatus(
    BuildContext? context, 
    String documentId, {
    VoidCallback? onPollingComplete,
  }) async {
    if (_isPollingActive) {
      print('⚠️ Polling already active, skipping');
      return;
    }

    // stop any previous polling then start fresh
    stopPolling();
    _isPollingActive = true;

    // Read reqId & clear in-memory cache to allow fresh polling
    final prefs = await SharedPreferences.getInstance();
    final appState = GetIt.instance<AppStateProvider>();
    final reqId = appState.reqId;
    if (reqId != null) {
      // Clear in-memory cache to allow fresh API call
      _pennydropDoneCache.remove(reqId);
      print('🧹 Cleared in-memory pennydrop cache for reqId=$reqId');
      
      final already = prefs.getBool('pennydrop_done_$reqId') ?? false;
      if (already) {
        print(
          '🔁 Pennydrop already done for reqId=$reqId — not starting polling.',
        );
        _isPollingActive = false;
        return;
      }
    }
    
    print('🔄 Starting penny drop polling for docId=$documentId');

    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      // double check stop condition
      if (!_isPollingActive) {
        timer.cancel();
        return;
      }

      if (reqId != null) {
        final alreadyNow = prefs.getBool('pennydrop_done_$reqId') ?? false;
        if (alreadyNow) {
          print(
            '🔁 Pennydrop persisted true during polling for reqId=$reqId — stopping.',
          );
          stopPolling();
          return;
        }
      }

      print(
        '🔄 DigioRepository: polling updateKycStatus for docId=$documentId',
      );

      final result = await updateKycStatus(context, documentId);

      // If updateKycStatus returned Success, stop polling immediately.
      bool success = false;
      result.when(
        success: (_) {
          success = true;
        },
        failure: (_) {
          success = false;
        },
      );

      if (success) {
        print('----pennydrop success -> stopping polling');
        stopPolling();
        onPollingComplete?.call();
      } else {
        print('----pennydrop not successful yet, continue polling');
      }
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _isPollingActive = false;
  }

  static void openWebView(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WebViewScreen(url: url)),
    );
  }
}
