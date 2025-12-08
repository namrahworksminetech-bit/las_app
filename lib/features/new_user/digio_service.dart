import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kyc_workflow/digio_config.dart';
import 'package:kyc_workflow/environment.dart';
import 'package:kyc_workflow/gateway_event.dart';
import 'package:kyc_workflow/kyc_workflow.dart';
import 'package:kyc_workflow/service_mode.dart';
import '../../../core/results/result.dart';

class DigioService {
  static final DigioService _instance = DigioService._internal();
  factory DigioService() => _instance;
  DigioService._internal();

  KycWorkflow? _kycWorkflowPlugin;
  bool _isProcessing = false;
  String? _lastEventId;

  Future<Result<void>> initializeSDK(String environment) async {
    // Skip SDK initialization for web platform
    if (kIsWeb) {
      print('🌐 Web platform detected - skipping Digio SDK initialization');
      return const Success(null);
    }

    if (_kycWorkflowPlugin != null) {
      return const Success(null);
    }

    try {
      var digioConfig = DigioConfig();
      digioConfig.theme.primaryColor = "#32a83a";
      digioConfig.logo =
          "https://www.gstatic.com/mobilesdk/160503_mobilesdk/logo/2x/firebase_28dp.png";
      digioConfig.environment = environment == 'production'
          ? Environment.PRODUCTION
          : Environment.SANDBOX;
      digioConfig.serviceMode = ServiceMode.OTP;

      _kycWorkflowPlugin = KycWorkflow(digioConfig);
      _kycWorkflowPlugin!.setGatewayEventListener((GatewayEvent? gatewayEvent) {
        if (gatewayEvent?.event != null &&
            gatewayEvent?.event != _lastEventId) {
          _lastEventId = gatewayEvent?.event;
          print("gateway funnel event ${gatewayEvent?.event}");
        }
      });

      return const Success(null);
    } catch (e) {
      return Failure('Failed to initialize KYC SDK: $e');
    }
  }

  Future<Result<String>> startKYC({
    required String customerId,
    required String identifier,
    required String accessToken,
  }) async {
    // Skip KYC start for web platform
    if (kIsWeb) {
      print('🌐 Web platform detected - skipping Digio KYC start');
      return const Success('Web platform - KYC skipped');
    }

    if (_isProcessing) {
      return const Failure('KYC process already in progress');
    }

    try {
      if (_kycWorkflowPlugin == null) {
        return const Failure('KYC SDK not initialized');
      }

      _isProcessing = true;
      HashMap<String, String> additionalData = HashMap<String, String>();

      print('🚀 Calling Digio SDK start...');
      print('📋 Customer ID: $customerId');
      print('📋 Identifier: $identifier');
      
      final result = await _kycWorkflowPlugin!.start(
        customerId,
        identifier,
        accessToken,
        additionalData,
      );

      print('✅ Digio SDK completed with result: $result');
      
      // Wait a bit to ensure SDK has fully closed
      await Future.delayed(const Duration(milliseconds: 500));
      
      return Success(result.toString());
    } catch (e) {
      print('❌ Digio SDK error: $e');
      return Failure('Failed to start KYC: $e');
    } finally {
      _isProcessing = false;
      print('🏁 SDK processing flag cleared');
    }
  }
}
