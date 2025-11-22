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
    final existingDocId = prefs.getString('docId$reqId');

    print("-------------${existingDocId}");

    // If docId already exists, skip API call and directly start polling
    if (existingDocId != null) {
      print('📋 DocId already exists, starting polling directly');
      if (!_isPollingActive) {
        startPollingKycStatus(context, existingDocId);
      }
      return Success({'message': 'Using existing docId'});
    }

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
    PermissionStatus status = await Permission.camera.request();

    if (status.isGranted) {
      Map<String, dynamic> digioDetails = data;
      final reqId = digioDetails["req_id"]?.toString();

      if (reqId == null) return null;

      final prefs = await SharedPreferences.getInstance();
      String? cleanDocumentId = prefs.getString('docId$reqId');

      print("cleanDocumentId---------------------------$cleanDocumentId");

      var workflowResult;

      if (cleanDocumentId == null) {
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

          if (workflowResult != null && reqId != null) {
            cleanDocumentId = KycHelper.extractDocumentId(
              workflowResult.toString(),
            );
            await prefs.setString("docId$reqId", cleanDocumentId);
          }
        } on PlatformException {
          workflowResult = 'Failed to get platform version.';
        }
      }

      if (cleanDocumentId != null) {
        print("sucessss--------------");
        startPollingKycStatus(context, cleanDocumentId);
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

    // If we've already recorded success for this reqId in-memory or persisted, skip early.
    if (reqId != null) {
      final persisted = prefs.getBool('pennydrop_done_$reqId') ?? false;
      if (persisted || (_pennydropDoneCache[reqId] == true)) {
        print('🔁 Penny-drop already succeeded for reqId=$reqId, skipping updateKycStatus call.');
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

  /// Start polling Digio KYC status for given documentId. Will stop after success.
  void startPollingKycStatus(BuildContext? context, String documentId) async {
    if (_isPollingActive) return;

    // stop any previous polling then start fresh
    stopPolling();
    _isPollingActive = true;

    // Read reqId & persistent flag first to avoid unnecessary calls
    final prefs = await SharedPreferences.getInstance();
    final appState = GetIt.instance<AppStateProvider>();
    final reqId = appState.reqId;
    if (reqId != null) {
      final already = prefs.getBool('pennydrop_done_$reqId') ?? false;
      if (already) {
        print('🔁 Pennydrop already done for reqId=$reqId — not starting polling.');
        _isPollingActive = false;
        return;
      }
    }

    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      // double check stop condition
      if (!_isPollingActive) {
        timer.cancel();
        return;
      }

      // Check again persisted flag to guard against race conditions
      if (reqId != null) {
        final alreadyNow = prefs.getBool('pennydrop_done_$reqId') ?? false;
        if (alreadyNow) {
          print('🔁 Pennydrop persisted true during polling for reqId=$reqId — stopping.');
          stopPolling();
          return;
        }
      }

      print('🔄 DigioRepository: polling updateKycStatus for docId=$documentId');

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
