// import 'package:flutter/material.dart';
// import 'package:get_it/get_it.dart';
// import '../app_state_provider.dart';
// import '../../features/new_user/repository/kyc_repo.dart';
// import '../network/api_client.dart';
//
// class AppLifecycleService extends WidgetsBindingObserver {
//   static VoidCallback? _onKycComplete;
//   static Map<String, dynamic>? _mfDetailsData;
//
//   static void setKycCompleteCallback(VoidCallback callback, {Map<String, dynamic>? mfData}) {
//     _onKycComplete = callback;
//     _mfDetailsData = mfData;
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed && _onKycComplete != null) {
//       _checkKycStatus();
//     }
//   }
//
//   void _checkKycStatus() async {
//     try {
//       final reqId = GetIt.instance<AppStateProvider>().reqId;
//       if (reqId == null) return;
//
//       final kycRepository = KycRepository(GetIt.instance<ApiClient>());
//       final response = await kycRepository.checkKycStatus(
//         reqId: reqId,
//         kycStatus: 'completed',
//         lanNo: _mfDetailsData?['lan_no'] ?? 'LAN123456789',
//         loanCreationId: _mfDetailsData?['loan_creation_id'] ?? 'LC123456789',
//         bankName: _mfDetailsData?['bank_name'] ?? 'State Bank of India',
//       );
//
//       if (response.status == 'success' && response.data.kycStatus == 'completed') {
//         _onKycComplete?.call();
//       }
//       _onKycComplete = null;
//     } catch (e) {
//       print('KYC status check failed: $e');
//       _onKycComplete = null;
//     }
//   }
//
//
// }
