import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../app_state_provider.dart';
import '../../features/kyc/repository/kyc_repository.dart';
import '../network/api_client.dart';

class AppLifecycleService extends WidgetsBindingObserver {
  static VoidCallback? _onKycComplete;
  static Map<String, dynamic>? _mfDetailsData;
  
  static void setKycCompleteCallback(VoidCallback callback, {Map<String, dynamic>? mfData}) {
    _onKycComplete = callback;
    _mfDetailsData = mfData;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _onKycComplete != null) {
      _checkKycStatus();
    }
  }

  void _checkKycStatus() async {
    try {
      final reqId = GetIt.instance<AppStateProvider>().reqId;
      if (reqId == null) return;

      final repository = KycRepository(GetIt.instance<ApiClient>());
      final response = await repository.checkKycStatus(
        reqId: reqId,
        kycStatus: 'completed',
        lanNo: _mfDetailsData?['lan_no'] ?? 'LAN123456789',
        loanCreationId: _mfDetailsData?['loan_creation_id'] ?? 'LC123456789',
        bankName: _mfDetailsData?['bank_name'] ?? 'State Bank of India',
      );
      
      if (response.status == 'success' && response.data.kycStatus == 'completed') {
        _onKycComplete?.call();
      }
      // If KYC not completed, user stays on current screen (FundSelectionView)
      _onKycComplete = null; // Clear callback after check
    } catch (e) {
      print('KYC status check failed: $e');
      _onKycComplete = null; // Clear callback on error
    }
  }
}