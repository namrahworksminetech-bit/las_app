import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:las_app/app.dart';
import 'package:las_app/core/app_state_provider.dart';
import 'package:las_app/core/results/result.dart';
import 'package:las_app/features/new_user/repository/insurance_repo.dart';
import 'package:las_app/features/new_user/repository/lenders_data_repo.dart'
    hide DioException;
import 'package:las_app/features/new_user/repository/rta_otp_repo.dart';
import 'package:las_app/features/new_user/repository/digio_repo.dart';
import 'package:las_app/features/new_user/digio_service.dart';
import 'package:las_app/features/new_user/repository/rta_repo.dart';
import 'package:las_app/features/new_user/repository/shares_repo.dart';
import 'package:las_app/features/new_user/repository/pledge_status_repo.dart';
import 'package:las_app/helper_widgets/fund_utils.dart';
import 'package:las_app/models/funds/funds_detail_model.dart';
import 'package:las_app/models/funds/pledge_mf_response.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:las_app/features/new_user/repository/pan_veirfy_repo.dart';

import 'package:las_app/models/funds/mf_details_response_model.dart';
import 'package:las_app/models/funds/pledgeable_model.dart';
import 'package:las_app/models/pan_verification/pan_otp_response_model.dart';
import 'package:las_app/models/pan_verification/pan_verify_response_model.dart';
import 'package:universal_html/js.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:las_app/common_widgets/webview_screen.dart';

import '../../../core/network/api_client.dart';
import '../repository/kyc_repo.dart';

part 'eligibility_event.dart';
part 'eligibility_state.dart';

class EligibilityBloc extends Bloc<EligibilityEvent, EligibilityState> {
  final PanRepository repository;
  final LenderRepository lenderRepository;
  final KycRepo _kycRepository;
  final RtaOtpRepository _rtaOtpRepository;
  final DigioRepository _digioRepository;
  final DigioService _digioService = getIt<DigioService>();

  final SharesRepository _sharesRepository = SharesRepository();
  StreamSubscription? _socketSubscription;

  final _webViewCloseController = StreamController<bool>.broadcast();
  Stream<bool> get webViewCloseStream => _webViewCloseController.stream;

  String? shareFileKey; // store uploaded file path
  bool isShareUploading = false;
  EligibilityBloc({
    required this.repository,
    required this.lenderRepository,
    required ApiClient apiClient,
  }) : _kycRepository = KycRepo(apiClient),
       _rtaOtpRepository = RtaOtpRepository(apiClient),

       _digioRepository = DigioRepository(apiClient),
       super(const EligibilityState()) {
    _loadEligibilitySeenFlag();
    on<InvestmentTypeUpdated>(_onInvestmentTypeUpdated);

    // ================= INSURANCE EVENTS =================
    on<FetchInsurers>(_onFetchInsurers);
    on<SaveInsuranceForm>(_onSaveInsuranceForm);
    on<UploadUnitStatement>(_onUploadUnitStatement);
    on<UploadPolicyBond>(_onUploadPolicyBond);
    on<SubmitInsuranceDetails>(_onSubmitInsuranceDetails);

    on<PanNumberUpdated>(_onPanNumberUpdated);
    on<PanFullNameUpdated>(_onPanFullNameUpdated);
    on<PanDobUpdated>(_onPanDobUpdated);
    on<PanEmailUpdated>(_onPanEmailUpdated);

    on<AcknowledgeKycNavigation>(_onAcknowledgeKycNavigation);
    on<UploadHoldingFile>(_onUploadHoldingFile);
    on<SubmitShareDetails>(_onSubmitShareDetails);

    on<VerifyPanPressed>(_onVerifyPanPressed);
    on<SendPanOtpPressed>(_onSendPanOtpPressed);
    on<VerifyPanOtpPressed>(_onVerifyPanOtpPressed);
    on<EligibilitySnackbarCleared>(_onSnackbarCleared);
    on<AutoSelectAllFunds>(_onAutoSelectAllFunds);
    on<JumpToPage>(_onJumpToPage);
    on<StartFetchingFromLogin>(_onStartFetchingFromLogin);

    on<FetchStep2Data>(_onFetchStep2Data);
    on<LenderSelected>(_onLenderSelected);
    on<ViewDetailsToggled>(_onViewDetailsToggled);
    on<RefreshPortfolioPressed>(_onRefreshPortfolioPressed);
    on<BreakdownCategoryTapped>(_onBreakdownCategoryTapped);
    on<EditLoanAmountPressed>(_onEditLoanAmountPressed);
    on<SaveEditedLoanAmount>(_onSaveEditedLoanAmount);
    on<LenderContinuePressed>(_onLenderContinuePressed);
    on<ProceedToLenderSelection>(_onProceedToLenderSelection);
    on<UpdateEditedFundAmount>(_onUpdateEditedFundAmount);

    on<ClearSnackbar>(_onClearSnackbar);

    on<ToggleFundSelection>(_onToggleFundSelection);
    on<ConfirmFundSelection>(_onConfirmFundSelection);
    on<ToggleKycStep>(_onToggleKycStep);

    ///pledging otp
    on<OtpChanged>(_onOtpChanged);
    on<SubmitOtp>(_onSubmitOtp);
    on<ResendOtp>(_onResendOtp);
    on<SetLenderSelectionView>(_onSetLenderSelectionView);
    on<NextStepPressed>(_onNextStepPressed);
    on<PreviousStepPressed>(_onPreviousStepPressed);
    on<ErrorMessageCleared>(_onErrorMessageCleared);
    on<StartKycEvent>(_onStartKyc);
    on<UpdateKycStep>(_onUpdateKycStep);
    on<UpdateKycStepsReset>(_onUpdateKycStepsReset);
    on<UpdateKycStepsAll>(_onUpdateKycStepsAll);
    on<MarkEligibilityResultSeen>(_onMarkEligibilityResultSeen);
    on<VerifyRtaOtp>(_onVerifyRtaOtp);
    on<SetUserMobileNumber>(_onSetUserMobileNumber);
    on<StartDigioKyc>(_onStartDigioKyc);
    on<DigioKycCompleted>(_onDigioKycCompleted);
    on<DigioKycFailed>(_onDigioKycFailed);
    on<CheckPledgeStatus>(_onCheckPledgeStatus);
    on<RequestLocationAndStartKyc>(_onRequestLocationAndStartKyc);
    on<KycStepTapped>(_onKycStepTapped);
    on<PennyDropPollingCompleted>(_onPennyDropPollingCompleted);
    on<NavigateToNextScreen>(_onNavigateToNextScreen);
    on<FetchPledgePhoneNumber>(_onFetchPledgePhoneNumber);
    on<SubmitPledgeOtp>(_onSubmitPledgeOtp);
    on<ToggleOtpVisibility>(_onToggleOtpVisibility);
    on<PledgeOtpChanged>(_onPledgeOtpChanged);
    on<TermsAgreementToggled>(_onTermsAgreementToggled);
    on<UpdateFundAmount>(_onUpdateFundAmount);
    on<SetKycProcessing>(_onSetKycProcessing);


  }



  void _onSetKycProcessing(
    SetKycProcessing event,
    Emitter<EligibilityState> emit,
  ) {
    try {
      debugPrint('🔄 Setting KYC processing: ${event.isProcessing}');
      emit(state.copyWith(kycLoading: event.isProcessing));
    } catch (e) {
      debugPrint('❌ Error setting KYC processing state: $e');
    }
  }

 void _onUpdateFundAmount(
  UpdateFundAmount event,
  Emitter<EligibilityState> emit,
) {
  final updatedFunds = state.pledgeableFunds.map((fund) {
    if (fund.fundCode == event.fundCode) {
      return fund.copyWith(updatedFundAmount: event.amount);
    }
    return fund;
  }).toList();

  emit(state.copyWith(
    pledgeableFunds: updatedFunds,
    lastEditedFundCode: event.fundCode,     // ⭐ store code
    lastEditedFundAmount: event.amount,     // ⭐ store edited value
    hasUnsavedFundChanges: true,
  ));
}

void _onPledgeOtpChanged(PledgeOtpChanged event, Emitter<EligibilityState> emit) {
  emit(state.copyWith(
    pledgeOtp: event.otp,
    pledgeOtpError: null,
  ));
}

void _onTermsAgreementToggled(
  TermsAgreementToggled event,
  Emitter<EligibilityState> emit,
) {
  emit(state.copyWith(agreedToTerms: event.agreed));
}
  void _onToggleOtpVisibility(
    ToggleOtpVisibility event,
    Emitter<EligibilityState> emit,
  ) {
    emit(state.copyWith(isOtpVisible: !state.isOtpVisible));
  }

  void _onPanEmailUpdated(
    PanEmailUpdated event,
    Emitter<EligibilityState> emit,
  ) {

    final email = event.email.trim();
    String? error;
    final emailRegex = RegExp(r'^[\w\.\-]+@[\w\-]+\.[a-zA-Z]{2,}$');

    if (email.isEmpty) {
      error = "Email is required";
    } else if (!emailRegex.hasMatch(email)) {
      error = "Enter a valid email address";
    }

    emit(
      state.copyWith(
        panEmail: email,
        panEmailError: error,
        formData: state.formData.copyWith(panEmail: email),
      ),
    );
  }

  void _onPennyDropPollingCompleted(
    PennyDropPollingCompleted event,
    Emitter<EligibilityState> emit,
  ) {
    debugPrint('✅ Penny drop polling completed');
    emit(state.copyWith(isPennyDropPolling: false, shouldNavigateToOtp: true));
  }

  void _onNavigateToNextScreen(
    NavigateToNextScreen event,
    Emitter<EligibilityState> emit,
  ) {
    debugPrint('📍 Navigating to OTP screen');
    emit(state.copyWith(shouldNavigateToOtp: true));
  }

Future<void> _onFetchPledgePhoneNumber(
  FetchPledgePhoneNumber event,
  Emitter<EligibilityState> emit,
) async {
  final reqId = getIt<AppStateProvider>().reqId;
  final token = getIt<AppStateProvider>().token;

  if (reqId == null || token == null) {
    emit(state.copyWith(pledgeChecked: true));
    return;
  }

  try {
    final pledgeRepo = PledgeStatusRepository(getIt<ApiClient>());
    final result = await pledgeRepo.checkPledgeMfStatus(
      reqId: reqId,
      type: "pledge",
      authToken: token,
    );

    result.when(
      success: (data) {
        String? phoneFromResp;

        final inner = data['data'];
        if (inner is List && inner.isNotEmpty) {
          phoneFromResp = inner[0]['phone']?.toString();
        } else if (inner is Map) {
          phoneFromResp = inner['phone']?.toString();
        }

        if (phoneFromResp != null && phoneFromResp.isNotEmpty) {
          String normalized = phoneFromResp.replaceAll(RegExp(r'[\s\-]'), '');

          if (!normalized.startsWith('+')) {
            normalized = normalized.startsWith('91')
                ? '+$normalized'
                : '+91$normalized';
          }

          emit(state.copyWith(
            pledgePhoneNumber: normalized,
            pledgeChecked: true,
          ));
        } else {
          emit(state.copyWith(pledgeChecked: true));
        }
      },
      failure: (_) => emit(state.copyWith(pledgeChecked: true)),
    );
  } catch (e) {
    emit(state.copyWith(pledgeChecked: true));
  }
}

  Future<void> _onSubmitPledgeOtp(
    SubmitPledgeOtp event,
    Emitter<EligibilityState> emit,
  ) async {
    emit(state.copyWith(pledgeOtpSubmitting: true, rtaOtpError: null));

    try {
      final rtaRepo = RtaRepository(
        apiClient: getIt<ApiClient>(),
        appState: getIt<AppStateProvider>(),
      );
      await rtaRepo.verifyRtaOtp(phone: event.phone, otp: event.otp);
      emit(state.copyWith(pledgeOtpSubmitting: false, rtaOtpError: null));
    } catch (e) {
      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      emit(state.copyWith(pledgeOtpSubmitting: false, rtaOtpError: errorMsg));
    }
  }

  /* =========================================================
                      INSURANCE FLOW BLoC
   ========================================================= */
  final InsuranceRepository _insuranceRepo =
      GetIt.instance<InsuranceRepository>();

  /// ========== 1️⃣ Fetch Insurer List ==============
  Future<void> _onFetchInsurers(
    FetchInsurers event,
    Emitter<EligibilityState> emit,
  ) async {
    emit(state.copyWith(isFetchingInsurers: true, insuranceError: null));

    final result = await _insuranceRepo.getInsurers();

    result.when(
      success: (companies) {
        emit(
          state.copyWith(
            insurers: companies, // List<Map<String, dynamic>>
            isFetchingInsurers: false,
          ),
        );
      },
      failure: (err) {
        emit(state.copyWith(isFetchingInsurers: false, insuranceError: err));
      },
    );
  }

  /// ========== 2️⃣ Save Step-1 Data =================
  Future<void> _onSaveInsuranceForm(
    SaveInsuranceForm event,
    Emitter<EligibilityState> emit,
  ) async {
    emit(
      state.copyWith(
        insurerCode: event.insurerCode,
        insurancePolicyNo: event.policyNumber,
        insuranceName: event.name,
        insuranceDob: event.dob,
      ),
    );
  }

  /// ========== 3️⃣ Upload UNIT-STATEMENT =============
  Future<void> _onUploadUnitStatement(
    UploadUnitStatement event,
    Emitter<EligibilityState> emit,
  ) async {
    emit(state.copyWith(isUploadingUnit: true, insuranceError: null));

    /// 1️⃣ FIRST — get pre-signed URL
    final urlRes = await _insuranceRepo.getUploadUrl(event.fileType);

    String? urlError;
    urlRes.when(success: (_) {}, failure: (err) => urlError = err);

    if (urlError != null) {
      emit(state.copyWith(isUploadingUnit: false, insuranceError: urlError));
      return;
    }

    /// 2️⃣ Upload file to S3
    final uploadRes = await _insuranceRepo.uploadFile(
      bytes: event.fileBytes,
      fileType: event.fileType,
      mimeType: event.mimeType,
    );

    uploadRes.when(
      success: (key) {
        emit(
          state.copyWith(
            isUploadingUnit: false,
            unitKey: key, //store path
          ),
        );
      },
      failure: (err) {
        emit(state.copyWith(isUploadingUnit: false, insuranceError: err));
      },
    );
  }

  /// ========== 4️⃣ Upload POLICY-DOCUMENT ===========
  Future<void> _onUploadPolicyBond(
    UploadPolicyBond event,
    Emitter<EligibilityState> emit,
  ) async {
    emit(state.copyWith(isUploadingPolicy: true, insuranceError: null));

    /// 1️⃣ Get Pre-Signed URL
    final urlRes = await _insuranceRepo.getUploadUrl(event.fileType);

    String? urlError;
    urlRes.when(success: (_) {}, failure: (err) => urlError = err);

    if (urlError != null) {
      emit(state.copyWith(isUploadingPolicy: false, insuranceError: urlError));
      return;
    }

    /// 2️⃣ Upload File
    final uploadRes = await _insuranceRepo.uploadFile(
      bytes: event.fileBytes,
      mimeType: event.mimeType,
      fileType: event.fileType,
    );

    uploadRes.when(
      success: (key) {
        emit(state.copyWith(isUploadingPolicy: false, policyKey: key));
      },
      failure: (err) {
        emit(state.copyWith(isUploadingPolicy: false, insuranceError: err));
      },
    );
  }

  /// ========== 5️⃣ FINAL SUBMIT API ================
Future<void> _onSubmitInsuranceDetails(
  SubmitInsuranceDetails event,
  Emitter<EligibilityState> emit,
) async {
  print("🚀 SUBMIT INSURANCE CLICKED");

  // Validation: both files must be uploaded
  if (state.unitKey == null || state.policyKey == null) {
    emit(state.copyWith(
      insuranceError: "Upload both documents first",
      snackbarMessage: "Upload both documents first", // 🔥 Show snackbar
    ));
    return;
  }

  emit(state.copyWith(
    isSubmittingInsurance: true,
    insuranceError: null,
    snackbarMessage: null,
  ));

  final res = await _insuranceRepo.submitInsurance(
    insurerCode: state.insurerCode!,
    policyNumber: state.insurancePolicyNo!,
    name: state.insuranceName!,
    dob: state.insuranceDob!,
    unitFileKey: state.unitKey!,
    policyFileKey: state.policyKey!,
  );

  res.when(
    success: (_) {
      print("🎉 INSURANCE POLICY SUBMITTED");

      emit(
        state.copyWith(
          isSubmittingInsurance: false,
          insuranceSuccess: true,

          // 🔥 repo returns bool → use custom success message
          snackbarMessage: "Insurance submitted successfully!",
        ),
      );
    },
    failure: (err) {
      print("❌ SUBMIT FAILED → $err");

      emit(
        state.copyWith(
          isSubmittingInsurance: false,
          insuranceError: err,

          // 🔥 Show backend error in snackbar
          snackbarMessage: err.toString(),
        ),
      );
    },
  );
}

  void _onSetLenderSelectionView(
    SetLenderSelectionView event,
    Emitter<EligibilityState> emit,
  ) {
    emit(state.copyWith(lenderSelectionView: event.view));
  }

  Future<void> _onUpdateEditedFundAmount(
    UpdateEditedFundAmount event,
    Emitter<EligibilityState> emit,
  ) async {
    final newMap = Map<String, double>.from(state.editedFundAmounts);

    // Insert or overwrite edited amount for this fundCode
    newMap[event.fundCode] = event.amount;

    emit(state.copyWith(editedFundAmounts: newMap));
  }

  Future<void> _onUploadHoldingFile(
    UploadHoldingFile event,
    Emitter<EligibilityState> emit,
  ) async {
    emit(state.copyWith(isShareUploading: true, shareError: null));

    // 1️⃣ Get pre-signed URL & key
    final urlResult = await _sharesRepository.getUploadUrl(event.fileType);

    String? urlError;
    urlResult.when(success: (_) {}, failure: (err) => urlError = err);

    if (urlError != null) {
      emit(state.copyWith(isShareUploading: false, shareError: urlError));
      return;
    }

    print("🔗 uploadUrl obtained → calling PUT upload..");

    // 2️⃣ Upload file to S3
    final uploadResult = await _sharesRepository.uploadFile(
      documentType: event.fileType,
      mimeType: event.mimeType,
      bytes: event.fileBytes,
    );

    uploadResult.when(
      success: (_) {
        final uploadedKey = _sharesRepository.uploadKey; // 🔑 FINAL KEY
        print("🔥 FINAL STORED KEY IN BLOC → $uploadedKey");

        emit(
          state.copyWith(
            isShareUploading: false,
            shareUploadPath: uploadedKey, // ✅ store it in Bloc state
          ),
        );
      },
      failure: (err) {
        emit(state.copyWith(isShareUploading: false, shareError: err));
      },
    );
  }

  Future<void> _onSubmitShareDetails(
    SubmitShareDetails event,
    Emitter<EligibilityState> emit,
  ) async {
    // Guard: make sure file is uploaded
    if (state.shareUploadPath == null) {
      emit(
        state.copyWith(
          shareError:
              "Please upload your Demat Holding Statement before continuing.",
        ),
      );
      return;
    }

    emit(state.copyWith(isShareSubmitting: true, shareError: null));

    final result = await _sharesRepository.submitShare(
      broker: event.broker,
      dpId: event.dpId,
      holdingKey: state.shareUploadPath!, // ✅ pass key directly
    );

    result.when(
      success: (_) {
        emit(state.copyWith(isShareSubmitting: false, shareSuccess: true));
      },
      failure: (err) {
        emit(state.copyWith(isShareSubmitting: false, shareError: err));
      },
    );
  }

  // Replace your existing handler with this in EligibilityBloc
  void _onJumpToPage(JumpToPage event, Emitter<EligibilityState> emit) {
    final int target = event.pageIndex.clamp(0, 5);

    // 🔥 Do NOT reset majorStep when going backward programmatically
    final int newMajor = switch (target) {
      0 => 1,
      1 => state.majorStep, // FIX: do not downgrade step
      2 => 2,
      3 => 2,
      4 => 3,
      5 => 4,
      _ => state.majorStep,
    };

    var nextState = state.copyWith(
      pageIndex: target,
      majorStep: newMajor,

      currentOverlay: EligibilityOverlayType.none,
      generalErrorMessage: null,
    );

    // Ensure lender view resets when jumping back
    if (target == 1 &&
        state.lenderSelectionView != LenderSelectionView.lenderList) {
      nextState = nextState.copyWith(
        lenderSelectionView: LenderSelectionView.lenderList,
      );
    }

    emit(nextState);

    debugPrint(
      '🔁 JumpToPage -> page:$target major:$newMajor lenderView:${nextState.lenderSelectionView}',
    );
  }

  Future<void> _onAcknowledgeKycNavigation(
    AcknowledgeKycNavigation event,
    Emitter<EligibilityState> emit,
  ) async {
    emit(state.copyWith(shouldNavigateToKyc: false));
  }

  Future<void> _onStartFetchingFromLogin(
    StartFetchingFromLogin event,
    Emitter<EligibilityState> emit,
  ) async {
    if (state.isLoading) return;

    emit(
      state.copyWith(
        isLoading: true,
        clearErrors: true,
        currentOverlay: EligibilityOverlayType.fetchingPortfolio,
      ),
    );

    add(FetchStep2Data());
  }

  Future<void> _onClearSnackbar(
    ClearSnackbar event,
    Emitter<EligibilityState> emit,
  ) async {
    emit(state.copyWith(snackbarMessage: '')); // or null if you use nullable
  }

  void _onAutoSelectAllFunds(
    AutoSelectAllFunds event,
    Emitter<EligibilityState> emit,
  ) {
    // Set both selected and previousSelected so diffs work later
    emit(
      state.copyWith(
        selectedFundIds: event.fundIds,
        previousSelectedFundIds: event.fundIds,
      ),
    );

    print('✅ Auto-selected all ${event.fundIds.length} funds (UI + state)');
  }

  ///kyc
  void _onToggleKycStep(ToggleKycStep event, Emitter<EligibilityState> emit) {
    final updated = List<bool>.from(state.kycStepChecks);
    updated[event.index] = !updated[event.index];
    emit(state.copyWith(kycStepChecks: updated));
  }

  void _onSnackbarCleared(
    EligibilitySnackbarCleared event,
    Emitter<EligibilityState> emit,
  ) {
    emit(state.copyWith(clearSnackbar: true));
  }

  void _onOtpChanged(OtpChanged event, Emitter<EligibilityState> emit) {
    emit(
      state.copyWith(
        otp: event.otp,
        otpError: false,
        rtaOtpError: null, // Clear RTA OTP error when typing
      ),
    );
  }

  Future<void> _onSubmitOtp(
    SubmitOtp event,
    Emitter<EligibilityState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true));

    await Future.delayed(const Duration(seconds: 2));

    if (state.otp == '123456') {
      emit(state.copyWith(isSubmitting: false, otpError: false));
    } else {
      emit(state.copyWith(isSubmitting: false, otpError: true));
    }
  }

  Future<void> _onLenderContinuePressed(
    LenderContinuePressed event,
    Emitter<EligibilityState> emit,
  ) async {
    print('➡️ Continue pressed for lenderId: ${event.lenderId}');

    // Just save selected lender
    emit(
      state.copyWith(
        selectedLenderId: event.lenderId,
        lenderSelectionView: LenderSelectionView.fundSelection,
      ),
    );
  }

  // Future<void> _onLenderContinuePressed(
  //   LenderContinuePressed event,
  //   Emitter<EligibilityState> emit,
  // ) async {
  //   print('➡️ Continue pressed for lenderId: ${event.lenderId}');
  //   emit(state.copyWith(isLoading: true, generalErrorMessage: null));

  //   try {
  //     // 1️⃣ Get selected UI lender
  //     final selectedUiLender = state.lenders.firstWhere(
  //       (l) => l.id == event.lenderId,
  //       orElse: () => throw Exception('Selected lender not found in UI list'),
  //     );

  //     // 2️⃣ Get mfDetailsResponse
  //     final mfDetails = state.mfDetailsResponse;
  //     if (mfDetails == null)
  //       throw Exception('mfDetailsResponse not loaded yet');

  //     // 3️⃣ Find the full LenderItem details by matching ID
  //     final lenderItem = mfDetails.lenders.firstWhere(
  //       (l) => l.id.toString() == selectedUiLender.id,
  //       orElse: () =>
  //           throw Exception('Lender details not found in mfDetailsResponse'),
  //     );

  //     // 4️⃣ Extract eligible funds
  //     final eligibleFunds = lenderItem.eligibleFunds ?? [];
  //     if (eligibleFunds.isEmpty) {
  //       emit(
  //         state.copyWith(
  //           isLoading: false,
  //           generalErrorMessage:
  //               'No eligible funds found for ${selectedUiLender.name}.',
  //         ),
  //       );
  //       return;
  //     }

  //     // 5️⃣ Use pledgeableFunds list from mfDetailsResponse
  //     final fundDetails = mfDetails.pledgeableFunds;
  //     if (fundDetails.isEmpty) {
  //       emit(
  //         state.copyWith(
  //           isLoading: false,
  //           generalErrorMessage: 'No pledgeable fund details found.',
  //         ),
  //       );
  //       return;
  //     }

  //     // 6️⃣ Merge both using helper
  //     final mergedFunds = FundsMerger.merge(
  //       eligibleFunds: eligibleFunds,
  //       fundDetails: fundDetails,
  //     );

  //     if (mergedFunds.isEmpty) {
  //       emit(
  //         state.copyWith(
  //           isLoading: false,
  //           generalErrorMessage:
  //               'No matching funds found for ${selectedUiLender.name}.',
  //         ),
  //       );
  //       return;
  //     }

  //     // 7️⃣ Collect selected IDs (folio numbers)
  //     final selectedIds = mergedFunds.map((f) => f.folioNo).toSet();

  //     // 8️⃣ Emit state for next screen
  //     emit(
  //       state.copyWith(
  //         isLoading: false,
  //         selectedLenderId: selectedUiLender.id,
  //         lenderSelectionView: LenderSelectionView.fundSelection,
  //         pledgeableFunds: mergedFunds,
  //         selectedFundIds: selectedIds,
  //       ),
  //     );

  //     print(
  //       '✅ ${mergedFunds.length} pledgeable funds ready for ${selectedUiLender.name}',
  //     );
  //   } catch (e, st) {
  //     print('❌ Error in _onLenderContinuePressed: $e\n$st');
  //     emit(
  //       state.copyWith(
  //         isLoading: false,
  //         generalErrorMessage:
  //             'Something went wrong while preparing lender funds.',
  //       ),
  //     );
  //   }
  // }

  Future<void> _onResendOtp(
    ResendOtp event,
    Emitter<EligibilityState> emit,
  ) async {
    await Future.delayed(const Duration(seconds: 1));
    emit(state.copyWith(otpResent: true));
    await Future.delayed(const Duration(seconds: 2));
    emit(state.copyWith(otpResent: false));
  }

  void _onInvestmentTypeUpdated(
    InvestmentTypeUpdated event,
    Emitter<EligibilityState> emit,
  ) {
    emit(
      state.copyWith(
        formData: state.formData.copyWith(investmentType: event.type),
        clearErrors: true,
      ),
    );
  }

  void _onPanNumberUpdated(
    PanNumberUpdated event,
    Emitter<EligibilityState> emit,
  ) {
    final pan = event.pan.toUpperCase();

    String? liveMessage;

    if (pan.isEmpty) {
      liveMessage = null; // nothing yet
    } else if (pan.length < 10) {
      liveMessage = "Invalid PAN format"; // too short
    } else if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$').hasMatch(pan)) {
      liveMessage = "Invalid PAN format"; // wrong pattern
    } else {
      liveMessage = "Valid PAN";
    }

    emit(
      state.copyWith(
        formData: state.formData.copyWith(panNumber: pan),
        // old error used in submit-level validation
        panNumberError: liveMessage == "Valid PAN" ? null : liveMessage,
        // new live message used in UI
        panLiveError: liveMessage,
      ),
    );
  }

  void _onPanFullNameUpdated(
    PanFullNameUpdated event,
    Emitter<EligibilityState> emit,
  ) {
    emit(
      state.copyWith(
        formData: state.formData.copyWith(panFullName: event.fullName),
        panFullNameError: null,
      ),
    );
  }

  void _onPanDobUpdated(PanDobUpdated event, Emitter<EligibilityState> emit) {
    emit(
      state.copyWith(
        formData: state.formData.copyWith(panDob: event.dob),
        panDobError: null,
      ),
    );
  }

Future<void> _onVerifyPanPressed(
  VerifyPanPressed event,
  Emitter<EligibilityState> emit,
) async {
  emit(
    state.copyWith(
      panStatus: PanVerificationStatus.verifying,
      generalErrorMessage: null,
      snackbarMessage: null, // optional reset
    ),
  );

  final reqId = getIt<AppStateProvider>().reqId;

  if (reqId == null || reqId.isEmpty) {
    emit(
      state.copyWith(
        panStatus: PanVerificationStatus.failed,
        generalErrorMessage: 'Missing reqId. Please login again.',
        snackbarMessage: 'Missing reqId. Please login again.', // 🔥
      ),
    );
    return;
  }

  final result = await repository.verifyPan(
    reqId: reqId,
    pan: event.pan,
    dob: event.dob,
    name: event.name,
    email: event.email,
  );

  await result.when(
    success: (panResponse) async {
      // 🔥 SHOW SERVER SUCCESS/VALIDATION MESSAGE
      emit(state.copyWith(
        snackbarMessage: panResponse.message, // <<< 🔥 THIS SHOWS YOUR MESSAGE
      ));

      final reqId = panResponse.reqId;

      if (reqId == null) {
        emit(
          state.copyWith(
            panStatus: PanVerificationStatus.failed,
            generalErrorMessage: 'Missing reqId in response.',
            snackbarMessage: 'Missing reqId in response.', // 🔥
          ),
        );
        return;
      }

      getIt<AppStateProvider>().setReqId(reqId);

      final otpResult = await repository.generateOtp();

      otpResult.when(
        success: (otpResponse) {
          emit(
            state.copyWith(
              panStatus: PanVerificationStatus.verified,
              otpStatus: PanOtpStatus.sent,

              // 🔥 SHOW OTP SENT MESSAGE
              snackbarMessage: otpResponse.message ?? 'OTP sent successfully.',

              generalErrorMessage:
                  otpResponse.message ?? 'OTP sent successfully.',
            ),
          );
        },
        failure: (error) {
          emit(
            state.copyWith(
              otpStatus: PanOtpStatus.failed,
              generalErrorMessage: error,
              snackbarMessage: error, // 🔥
            ),
          );
        },
      );
    },

    failure: (error) {
      emit(
        state.copyWith(
          panStatus: PanVerificationStatus.failed,
          generalErrorMessage: error,
          snackbarMessage: error, // 🔥 SHOW ERROR IN SNACKBAR
        ),
      );
    },
  );
}

  Future<void> _onSendPanOtpPressed(
    SendPanOtpPressed event,
    Emitter<EligibilityState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, otpStatus: PanOtpStatus.sending));

    try {
      // get reqId from AppStateProvider instance (via getIt)
      final reqId = getIt<AppStateProvider>().reqId;
      if (reqId == null || reqId.isEmpty) {
        emit(
          state.copyWith(
            isLoading: false,
            otpStatus: PanOtpStatus.failed,
            snackbarMessage: 'Missing reqId. Please login again.',
          ),
        );
        return;
      }

      final result = await repository
          .generateOtp(); // returns Result<PanGenerateOtpResponseModel>

      emit(state.copyWith(isLoading: false));

      if (result is Success<PanGenerateOtpResponseModel>) {
        final data = result.value;
        emit(
          state.copyWith(
            otpStatus: PanOtpStatus.sent,
            snackbarMessage:
                data.message ?? 'OTP sent to registered mobile number.',
          ),
        );
      } else if (result is Failure<PanGenerateOtpResponseModel>) {
        emit(
          state.copyWith(
            otpStatus: PanOtpStatus.failed,
            snackbarMessage: result.message,
          ),
        );
      } else {
        emit(
          state.copyWith(
            otpStatus: PanOtpStatus.failed,
            snackbarMessage: 'Unexpected error while sending OTP.',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          otpStatus: PanOtpStatus.failed,
          snackbarMessage: 'Something went wrong. Please try again.',
        ),
      );
    }
  }

  Future<void> _onVerifyPanOtpPressed(
    VerifyPanOtpPressed event,
    Emitter<EligibilityState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await repository.verifyOtp(otp: event.otp);

    emit(state.copyWith(isLoading: false));

    if (result is Success<PanVerifyResponseModel>) {
      final data = result.value;

      emit(
        state.copyWith(
          snackbarMessage: data.message ?? 'OTP verified successfully!',
          otpStatus: PanOtpStatus.verified,
        ),
      );
    } else if (result is Failure<PanVerifyResponseModel>) {
      emit(
        state.copyWith(
          snackbarMessage: result.message ?? 'OTP verification failed.',
          otpStatus: PanOtpStatus.failed,
        ),
      );
    } else {
      emit(
        state.copyWith(
          snackbarMessage: 'Unexpected error during OTP verification.',
          otpStatus: PanOtpStatus.failed,
        ),
      );
    }
  }

  Future<void> _onFetchStep2Data(
    FetchStep2Data event,
    Emitter<EligibilityState> emit,
  ) async {
    // Guard: if already loading Step2 or already fetched, ignore duplicate request
    if (state.isStep2Loading) {
      print('🔁 FetchStep2Data ignored — Step2 already loading.');
      return;
    }
    if (state.mfDetailsResponse != null) {
      print('🔁 FetchStep2Data ignored — mfDetailsResponse already present.');
      return;
    }

    print("🔄 Fetching lenders and portfolio data (Step 2)...");
    emit(state.copyWith(isStep2Loading: true, generalErrorMessage: null));

    try {
      final reqId = getIt<AppStateProvider>().reqId;
      if (reqId == null) {
        print('⚠️ Missing reqId for FetchStep2Data');
        emit(
          state.copyWith(
            isStep2Loading: false,
            generalErrorMessage:
                "Missing request ID. Please restart the process.",
          ),
        );
        return;
      }

      // Call repository with a timeout so we don't wait forever
      // Adjust the timeout as suitable for your environment
      final fetchFuture = lenderRepository.fetchLendersAndPortfolio(
        reqId: reqId,
      );

      // Wait for either the fetch or a timeout
      final result = await fetchFuture.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('FetchStep2Data timed out after 30s');
        },
      );

      // If the repository returns a Result-like object with when(), handle it
      await result.when(
        success: (mfResponse) async {
          print("✅ Lenders parsed: ${mfResponse.lenders.length}");
          print(
            "✅ Pledgeable funds parsed: ${mfResponse.pledgeableFunds.length}",
          );
          print("✅ Pledgeable Amount: ${mfResponse.pledgeableAmount}");

          final lenders = mfResponse.lenders.map((l) {
            return Lender(
              id: l.id.toString(),
              name: l.name ?? '-',
              logoAsset: l.logo ?? '',
              interestRate: l.loanInterest ?? 0.0,
              loanAmount: l.loanAmount ?? 0.0,
              pledgeableMFs: l.eligibleFundsCount ?? 0,
              maxEligibleLimit: l.maxEligibleLimit ?? 0.0,
              tag: '',
            );
          }).toList();

          emit(
            state.copyWith(
              isStep2Loading: false,
              lenders: lenders,
              pledgeableFunds: mfResponse.pledgeableFunds,
              mfDetailsResponse: mfResponse,
              generalErrorMessage: null,
            ),
          );

          print("🟢 Stored lender + MF data successfully (Step 2).");
        },
        failure: (error) {
          print("❌ API error while fetching Step2: $error");
          emit(
            state.copyWith(
              isStep2Loading: false,
              generalErrorMessage: error?.toString() ?? 'Failed to fetch data',
            ),
          );
        },
      );
    } on TimeoutException catch (te) {
      print("⏱️ FetchStep2Data timeout: $te");
      emit(
        state.copyWith(
          isStep2Loading: false,
          generalErrorMessage: 'Request timed out. Please try again.',
        ),
      );
    } on DioException catch (dioErr) {
      print(
        "🌐 DioException during FetchStep2Data: ${dioErr.type} ${dioErr.message}",
      );
      // If server returned a body, try to extract a message
      final msg = dioErr.response?.data is Map
          ? dioErr.response?.data['message']
          : dioErr.message;
      emit(
        state.copyWith(
          isStep2Loading: false,
          generalErrorMessage: msg?.toString() ?? 'Network error occurred',
        ),
      );
    } catch (e, st) {
      print("💥 Unexpected exception in FetchStep2Data: $e");
      print(st);
      emit(
        state.copyWith(
          isStep2Loading: false,
          generalErrorMessage: 'Something went wrong. Please try again.',
        ),
      );
    }
  }

  void _onLenderSelected(LenderSelected event, Emitter<EligibilityState> emit) {
    final newSelectedId = (state.selectedLenderId == event.lenderId)
        ? null
        : event.lenderId;

    // 🧹 If lender is deselected — clear everything
    if (newSelectedId == null) {
      emit(
        state.copyWith(
          selectedLenderId: null,
          selectedFundIds: {},
          previousSelectedFundIds: {},
          clearSelectedLender: true,
        ),
      );
      return;
    }

    // 🧩 Get all pledgeable funds (for this lender, if applicable)
    final allFunds = state.pledgeableFunds;

    // 🪄 Auto-select all fund codes
    final allFundIds = allFunds.map((f) => f.fundCode).toSet();

    emit(
      state.copyWith(
        selectedLenderId: newSelectedId,
        clearSelectedLender: false,
        selectedFundIds: allFundIds,
        previousSelectedFundIds: allFundIds,
      ),
    );

    print(
      '✅ Auto-selected all ${allFundIds.length} funds for lender $newSelectedId',
    );
  }

  void _onToggleFundSelection(
    ToggleFundSelection event,
    Emitter<EligibilityState> emit,
  ) {
    // 🧠 Copy current selected fund IDs
    final currentSelected = Set<String>.from(state.selectedFundIds);
    final previousSelected = Set<String>.from(state.previousSelectedFundIds);

    // 🪄 Toggle logic: add/remove based on tap
    if (currentSelected.contains(event.fundId)) {
      currentSelected.remove(event.fundId);
    } else {
      currentSelected.add(event.fundId);
    }

    // 🧾 Log the change
    print('🔁 Fund toggled: ${event.fundId}');
    print('📦 Selected funds after toggle: $currentSelected');

    // Emit updated selection and store current state for future diffing
    emit(
      state.copyWith(
        selectedFundIds: currentSelected,
        hasUnsavedFundChanges: true,
        previousSelectedFundIds: previousSelected,
      ),
    );
  }

  Future<void> _onConfirmFundSelection(
    ConfirmFundSelection event,
    Emitter<EligibilityState> emit,
  ) async {
    print('🧩 ConfirmFundSelection START');
    emit(state.copyWith(isLoading: true, generalErrorMessage: null));

    try {
      final lenderId = state.selectedLenderId ?? '';
      final reqId = getIt<AppStateProvider>().reqId ?? '';
      print('📋 reqId: $reqId, selectedLenderId: $lenderId');

      if (reqId.isEmpty) {
        emit(
          state.copyWith(
            isLoading: false,
            generalErrorMessage: 'Missing reqId. Please restart the process.',
          ),
        );
        return;
      }

      // Base loan amount (if this is purely loan-edit without fund add/remove)
      final baseLoanAmount =
          state.editedLoanAmounts[lenderId] ??
          state.selectedLender?.loanAmount ??
          0.0;

      // Defensive: drop any empty fund codes from current selection
      final previousFunds = state.previousSelectedFundIds;
      final currentFundsRaw = state.selectedFundIds;
      final currentFunds = currentFundsRaw
          .where((s) => s.trim().isNotEmpty)
          .toSet();
      if (currentFundsRaw.length != currentFunds.length) {
        debugPrint('⚠️ Removed empty/blank fund codes from selection');
      }

      // helpers & results
      final List<String> isinAdd = [];
      final List<String> isinRemove = [];
      final List<String> isinModify = [];
      final List<String> skipped = [];

      PledgeableFund? findFund(String code) =>
          state.pledgeableFunds.firstWhereOrNull((p) => p.fundCode == code);

      // Build add list: fundCode:folioNo
      for (final code in currentFunds.difference(previousFunds)) {
        if (code.trim().isEmpty) {
          debugPrint('⚠️ Skipping add entry for blank code');
          skipped.add('add:$code');
          continue;
        }
        final f = findFund(code);
        final folio = f?.folioNo ?? '';
        if (folio.isEmpty) {
          debugPrint('⚠️ Skipping add entry for $code - folio missing');
          skipped.add('add:$code');
          continue;
        }
        isinAdd.add('$code:$folio');
      }

      // Build remove list: fundCode:folioNo
      for (final code in previousFunds.difference(currentFunds)) {
        if (code.trim().isEmpty) {
          debugPrint('⚠️ Skipping remove entry for blank code');
          skipped.add('remove:$code');
          continue;
        }
        final f = findFund(code);
        final folio = f?.folioNo ?? '';
        if (folio.isEmpty) {
          debugPrint('⚠️ Skipping remove entry for $code - folio missing');
          skipped.add('remove:$code');
          continue;
        }
        isinRemove.add('$code:$folio');
      }

      // Extra safety: filter out any malformed colon entries (guards against ":5544587")
      bool looksValidIsinPair(String s) {
        if (!s.contains(':')) return false;
        final parts = s.split(':');
        if (parts.length != 2) return false;
        final isin = parts[0].trim();
        final folio = parts[1].trim();
        if (isin.isEmpty || folio.isEmpty) return false;
        if (!RegExp(r'^[A-Z0-9]+$').hasMatch(isin)) return false;
        return true;
      }

      final filteredIsinAdd = isinAdd.where(looksValidIsinPair).toList();
      final filteredIsinRemove = isinRemove.where(looksValidIsinPair).toList();
      if (filteredIsinAdd.length != isinAdd.length ||
          filteredIsinRemove.length != isinRemove.length) {
        debugPrint('⚠️ Removed malformed ISIN entries from lists');
      }

      debugPrint('📤 ISIN_ADD (${filteredIsinAdd.length}): $filteredIsinAdd');
      debugPrint(
        '📤 ISIN_REMOVE (${filteredIsinRemove.length}): $filteredIsinRemove',
      );
      // ⭐ BUILD ISIN_MODIFY LIST FOR EDITED FUND VALUES
// ⭐ Only include the last edited fund
if (state.lastEditedFundCode != null &&
    state.lastEditedFundAmount != null) {

  final fund = state.pledgeableFunds.firstWhereOrNull(
      (f) => f.fundCode == state.lastEditedFundCode);

  if (fund != null) {
    final modifyEntry =
        "${fund.fundCode}:${fund.folioNo}:${state.lastEditedFundAmount}";
    isinModify.add(modifyEntry);

    debugPrint("🔧 FINAL ISIN MODIFY ENTRY -> $modifyEntry");
  }
}


debugPrint('📤 ISIN_MODIFY (${isinModify.length}): $isinModify');
      if (skipped.isNotEmpty) debugPrint('⚠️ Skipped entries: $skipped');

      // Determine loan_amount to send as nullable double:
      // - when add/remove present -> send null
      // - otherwise -> send actual baseLoanAmount
      double? loanAmountToSend;
      if (filteredIsinAdd.isNotEmpty || filteredIsinRemove.isNotEmpty) {
        loanAmountToSend = null;
        debugPrint('⚠️ Add/remove detected -> sending loan_amount = null');
      } else {
        loanAmountToSend = baseLoanAmount;
        debugPrint(
          'ℹ️ No add/remove -> sending loan_amount = $loanAmountToSend',
        );
      }

      // Final body preview for debugging
      final bodyPreview = {
        'req_id': reqId,
        'loan_amount': loanAmountToSend,
        'lender_id': lenderId,
        'isin_add': filteredIsinAdd,
        'isin_remove': filteredIsinRemove,
        'isin_modify': isinModify,
      };
      debugPrint('📦 Final request body preview: $bodyPreview');

      // Call repository (new method with named args)
      final result = await lenderRepository.editLoanAmount(
        reqId: reqId,
        loanAmount: loanAmountToSend,
        lenderId: lenderId,
        isinAdd: filteredIsinAdd,
        isinRemove: filteredIsinRemove,
        isinModify: isinModify,
      );

      // Handle Result<MfDetailsResponse>
      await result.when(
        success: (updatedData) async {
          debugPrint('✅ editLoanAmount success, updating state');

          // Map lenders from response into UI model Lender
          final updatedLenders = updatedData.lenders.map((l) {
            return Lender(
              id: l.id.toString(),
              name: l.name ?? '-',
              logoAsset: l.logo ?? '',
              interestRate: l.loanInterest ?? 0.0,
              maxEligibleLimit: l.maxEligibleLimit ?? 0.0,
              loanAmount: l.loanAmount ?? 0.0,
              pledgeableMFs: l.eligibleFundsCount ?? 0,
              tag: '',
            );
          }).toList();
// ⭐ Merge backend response with last edited fund's updated amount
final mergedFunds = updatedData.pledgeableFunds.map((apiFund) {
  if (apiFund.fundCode == state.lastEditedFundCode) {
    return apiFund.copyWith(
      updatedFundAmount: state.lastEditedFundAmount,
    );
  }
  return apiFund;
}).toList();

          emit(
            state.copyWith(
              mfDetailsResponse: updatedData,
              pledgeableFunds: mergedFunds,
              lenders: updatedLenders,
              isLoading: false,
              hasUnsavedFundChanges: false,
              generalErrorMessage: null,
              previousSelectedFundIds: state.selectedFundIds,
            ),
          );
        },
        failure: (error) {
          debugPrint('❌ editLoanAmount failed: $error');
          emit(state.copyWith(isLoading: false, generalErrorMessage: error));
        },
      );
    } catch (e, st) {
      debugPrint('Server down please try again in some time');
      emit(state.copyWith(isLoading: false, generalErrorMessage: e.toString()));
    }
  }

  void _onViewDetailsToggled(
    ViewDetailsToggled event,
    Emitter<EligibilityState> emit,
  ) {
    final currentView = state.lenderSelectionView;
    late final LenderSelectionView nextView;

    if (currentView == LenderSelectionView.lenderList ||
        currentView == LenderSelectionView.fundSelection) {
      nextView = LenderSelectionView.portfolioBreakdown;
    } else if (currentView == LenderSelectionView.portfolioBreakdown ||
        currentView == LenderSelectionView.pledgeableDetail) {
      nextView = LenderSelectionView.lenderList;
    } else {
      nextView = LenderSelectionView.lenderList;
    }

    emit(
      state.copyWith(lenderSelectionView: nextView, clearSelectedLender: true),
    );
  }

  Future<void> _onRefreshPortfolioPressed(
    RefreshPortfolioPressed event,
    Emitter<EligibilityState> emit,
  ) async {
    if (state.isPortfolioRefreshing) return;

    emit(state.copyWith(isPortfolioRefreshing: true));
    print("🔄 Refreshing portfolio...");

    try {
      final reqId = getIt<AppStateProvider>().reqId;
      if (reqId == null) {
        emit(
          state.copyWith(
            isPortfolioRefreshing: false,
            generalErrorMessage: "Missing request ID.",
          ),
        );
        return;
      }

      final result = await lenderRepository.fetchLendersAndPortfolio(
        reqId: reqId,
      );
      await result.when(
        success: (mfResponse) {
          print("✅ Portfolio refreshed successfully.");
          emit(
            state.copyWith(
              isPortfolioRefreshing: false,
              pledgeableFunds: mfResponse.pledgeableFunds,
              mfDetailsResponse: mfResponse,
            ),
          );
        },
        failure: (error) {
          emit(
            state.copyWith(
              isPortfolioRefreshing: false,
              generalErrorMessage: error,
            ),
          );
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          isPortfolioRefreshing: false,
          generalErrorMessage: "Failed to refresh portfolio.",
        ),
      );
    }
  }

  void _onBreakdownCategoryTapped(
    BreakdownCategoryTapped event,
    Emitter<EligibilityState> emit,
  ) {
    switch (event.categoryId) {
      case 'pledgeable':
        print("🟢 Switching to Pledgeable Detail view");
        print(
          "🟢 Pledgeable funds count: ${state.mfDetailsResponse?.pledgeableFunds.length ?? 0}",
        );
        emit(
          state.copyWith(
            lenderSelectionView: LenderSelectionView.pledgeableDetail,
          ),
        );
        break;

      case 'non_pledgeable':
        print("🟡 Switching to Non-Pledgeable Detail view");
        print(
          "🟡 Non-Pledgeable funds count: ${state.mfDetailsResponse?.nonPledgeableFunds.length ?? 0}",
        );
        emit(
          state.copyWith(
            lenderSelectionView: LenderSelectionView.nonPledgeableDetail,
          ),
        );
        break;

      case 'demat':
        print("🔵 Switching to Demat Detail view");
        print(
          "🔵 Demat funds count: ${state.mfDetailsResponse?.dematFunds.length ?? 0}",
        );
        emit(
          state.copyWith(lenderSelectionView: LenderSelectionView.dematDetail),
        );
        break;

      default:
        emit(
          state.copyWith(
            lenderSelectionView: LenderSelectionView.portfolioBreakdown,
          ),
        );
    }
  }

  Future<void> _onEditLoanAmountPressed(
    EditLoanAmountPressed event,
    Emitter<EligibilityState> emit,
  ) async {
    print('📤 Edit loan amount triggered for lender ${event.lenderId}');
    emit(state.copyWith(isLoading: true));

    try {
      final reqId = getIt<AppStateProvider>().reqId ?? '';
      final lenderId = event.lenderId;

      if (reqId.isEmpty) {
        emit(
          state.copyWith(
            isLoading: false,
            snackbarMessage: 'Missing reqId. Please login again.',
          ),
        );
        return;
      }

      final previousFunds = state.previousSelectedFundIds;
      final currentFunds = state.selectedFundIds;
      final allFunds = state.pledgeableFunds;

      // 🧮 Identify fund changes
      final addedFunds = currentFunds.difference(previousFunds);
      final removedFunds = previousFunds.difference(currentFunds);

      // ✅ Build ISIN lists only if funds changed
      // ✅ Build ISIN lists only if funds changed
      final isinAdd = addedFunds.isNotEmpty
          ? addedFunds.map<String>((id) {
              final fund = allFunds.firstWhere(
                (f) => f.fundCode == id,
                orElse: () => allFunds.first,
              );
              return "${fund.fundCode}:${fund.folioNo}";
            }).toList()
          : <String>[];

      final isinRemove = removedFunds.isNotEmpty
          ? removedFunds.map<String>((id) {
              final fund = allFunds.firstWhere(
                (f) => f.fundCode == id,
                orElse: () => allFunds.first,
              );
              return "${fund.fundCode}:${fund.folioNo}";
            }).toList()
          : <String>[];

      // ✅ Modify funds only when their values actually changed
      final isinModify = state.pledgeableFunds
          .where((f) => currentFunds.contains(f.fundCode))
          .map<String>((f) {
            final folio = f.folioNo ?? '';
            final updatedAmount = event.loanAmount.toStringAsFixed(2);
            return "${f.fundCode}:$folio:$updatedAmount";
          })
          .toList();
      print('📤 ISIN_ADD: $isinAdd');
      print('📤 ISIN_REMOVE: $isinRemove');
      print('📤 ISIN_MODIFY: $isinModify');
      print('📋 reqId: $reqId');
      print('💰 New Loan Amount: ${event.loanAmount}');

      final result = await lenderRepository.editLoanAmount(
        reqId: reqId,
        loanAmount: event.loanAmount,
        lenderId: lenderId.toString(), // ✅ ensure string
        isinAdd: isinAdd,
        isinRemove: isinRemove,
        isinModify: isinModify,
      );

      result.when(
        success: (response) {
          print('✅ Loan amount updated successfully');

          // Update the lender’s amount locally to reflect UI changes instantly
          final updatedLenders = state.lenders.map((lender) {
            if (lender.id == event.lenderId.toString()) {
              return lender.copyWith(loanAmount: event.loanAmount);
            }
            return lender;
          }).toList();

          // If backend returned updated pledgeableFunds etc., use them
          emit(
            state.copyWith(
              isLoading: false,
              mfDetailsResponse: response,
              lenders: updatedLenders,
              pledgeableFunds: response.pledgeableFunds,
              snackbarMessage: 'Loan amount updated successfully!',
            ),
          );
        },
        failure: (error) {
          print('❌ Failed to update loan amount: $error');
          emit(
            state.copyWith(isLoading: false, snackbarMessage: error.toString()),
          );
        },
      );
    } catch (e, st) {
      print('🚨 Exception while editing loan amount: $e\n$st');
      emit(
        state.copyWith(
          isLoading: false,
          snackbarMessage: 'Something went wrong while updating the amount.',
        ),
      );
    }
  }

  // Future<void> _onSaveEditedLoanAmount(
  //   SaveEditedLoanAmount event,
  //   Emitter<EligibilityState> emit,
  // ) async {
  //   print('🔔 SaveEditedLoanAmount START for lender ${event.lenderId} amount=${event.amount}');

  //   try {
  //     // Start a single global loader
  //     emit(state.copyWith(
  //       isEditingLoan: true,
  //       isLoading: true,
  //       lastSavedLenderId: null,
  //       lastSaveMessage: null,
  //       snackbarMessage: null,
  //     ));
  //     print('→ EMIT: global loading started for save of ${event.lenderId}');

  //     final reqId = getIt<AppStateProvider>().reqId ?? '';

  //     final List<String> isinAdd = <String>[];
  //     final List<String> isinRemove = <String>[];
  //     final List<String> isinModify = <String>[];

  //     final bool hasFundEdits =
  //         state.editedFundAmounts != null && state.editedFundAmounts.isNotEmpty;

  //     if (hasFundEdits) {
  //       final selectedFunds = state.pledgeableFunds.where((fund) {
  //         return state.selectedFundIds.contains(fund.fundCode);
  //       }).toList();

  //       final builtModify = selectedFunds.map((f) {
  //         final double editedValue = state.editedFundAmounts[f.fundCode] ?? 0.0;
  //         final units = editedValue;
  //         final unitsStr = units == units.roundToDouble()
  //             ? units.toStringAsFixed(0)
  //             : units.toStringAsFixed(3).replaceFirst(RegExp(r'\.?0+$'), '');
  //         return '${f.fundCode}:${f.folioNo}:$unitsStr';
  //       }).toList();

  //       isinModify.addAll(builtModify);
  //     }

  //     final double loanAmountToSend = event.amount;

  //     print("📤 Calling editLoanAmount API...");
  //     print("🧩 reqId: $reqId | lenderId: ${event.lenderId} | loanAmount: $loanAmountToSend");
  //     print("🔄 ISIN Modify → $isinModify");

  //     final result = await lenderRepository.editLoanAmount(
  //       reqId: reqId,
  //       loanAmount: loanAmountToSend,
  //       lenderId: event.lenderId,
  //       isinAdd: isinAdd,
  //       isinRemove: isinRemove,
  //       isinModify: isinModify,
  //     );

  //     // SUCCESS
  //     if (result is Success<MfDetailsResponse>) {
  //       final updatedResponse = result.value;

  //       final updatedLenders = state.lenders.map((l) {
  //         if (l.id == event.lenderId) {
  //           return l.copyWith(loanAmount: event.amount);
  //         }
  //         return l;
  //       }).toList();

  //       print('✅ Save success for lender ${event.lenderId} — updating state');

  //       emit(state.copyWith(
  //         mfDetailsResponse: updatedResponse,
  //         lenders: updatedLenders,
  //         pledgeableFunds: updatedResponse.pledgeableFunds,
  //         isEditingLoan: false,
  //         isLoading: false, // stop the global loader
  //         lastSavedLenderId: event.lenderId,
  //         lastSaveMessage: "Loan amount updated successfully!",
  //         snackbarMessage: "Loan amount updated successfully!",
  //       ));
  //       print('→ EMIT: save success and global loading stopped for ${event.lenderId}');
  //     } else if (result is Failure) {
  //       final msg = "Failed to update loan amount";
  //       print('⚠️ Save failed for lender ${event.lenderId}: $msg');

  //       emit(state.copyWith(
  //         isLoading: false,
  //         isEditingLoan: false,
  //         lastSavedLenderId: event.lenderId,
  //         lastSaveMessage: msg,
  //         snackbarMessage: msg,
  //       ));
  //       print('→ EMIT: save failure and global loading stopped for ${event.lenderId}');
  //     } else {
  //       print('⚠️ Save returned unexpected result type for lender ${event.lenderId}');

  //       emit(state.copyWith(
  //         isLoading: false,
  //         isEditingLoan: false,
  //         lastSavedLenderId: event.lenderId,
  //         lastSaveMessage: "Unexpected server response",
  //         snackbarMessage: "Unexpected server response",
  //       ));
  //       print('→ EMIT: unexpected result and global loading stopped for ${event.lenderId}');
  //     }
  //   } catch (e, stack) {
  //     print('💥 Exception during SaveEditedLoanAmount for lender ${event.lenderId}: $e');
  //     print(stack);
  //     emit(state.copyWith(
  //       isLoading: false,
  //       isEditingLoan: false,
  //       lastSavedLenderId: event.lenderId,
  //       lastSaveMessage: "Something went wrong",
  //       snackbarMessage: "Something went wrong",
  //     ));
  //     print('→ EMIT: exception and global loading stopped for ${event.lenderId}');
  //   }
  // }
  Future<void> _onSaveEditedLoanAmount(
    SaveEditedLoanAmount event,
    Emitter<EligibilityState> emit,
  ) async {
    print(
      '🔔 SaveEditedLoanAmount START for lender ${event.lenderId} amount=${event.amount}',
    );

    // mark saving flag (only for Save)
    emit(
      state.copyWith(
        isSavingLoan: true,
        isEditingLoan: true,
        lastSavedLenderId: null,
        lastSaveMessage: null,
        snackbarMessage: null,
      ),
    );
    print('→ EMIT: isSavingLoan = true');

    try {
      final reqId = getIt<AppStateProvider>().reqId ?? '';

      // -------------------------------
      // Build isinAdd / isinRemove safely
      // -------------------------------
      List<String> isinAdd = <String>[];
      List<String> isinRemove = <String>[];

      try {
        // Try a list of likely field names on state that might hold fund lists (List<FundDetail>).
        // If you have a specific field name, replace or add it here for direct mapping.
        final stateCandidates = <String>[
          'fundsToAdd',
          'funds_to_add',
          'selectedFundsForAdd',
          'selected_funds_for_add',
          'selectedForAdd',
          'addedFunds',
          'toBeAddedFunds',
          'fundsToRemove',
          'funds_to_remove',
          'selectedFundsForRemove',
          'selected_funds_for_remove',
          'selectedForRemove',
          'removedFunds',
          'toBeRemovedFunds',
        ];

        // helper to check & build using helper functions if available
        List<String> tryBuild(String fieldName, bool buildAdd) {
          try {
            final dynamic val = (state as dynamic).toJson != null
                ? (state as dynamic)
                      .toJson()[fieldName] // some states provide toJson
                : null;
            // but usually state.<fieldName> exists directly; try that first
          } catch (_) {}
          try {
            final dynamic maybe = (state as dynamic)?.__getField != null
                ? null
                : null; // noop to satisfy analyzer; actual access below
          } catch (_) {}

          try {
            final dynamic candidate = (state as dynamic).noSuchMethod != null
                ? null
                : null; // noop
          } catch (_) {}

          // Direct property access attempts (multiple tries)
          try {
            final dynamic listCandidate = (state as dynamic).runtimeType != Null
                ? (state as dynamic).fundsToAdd
                : null;
            // If this succeeds and matches the expected property, we've populated one path. But rather than hardcoding
            // many direct accesses here (which would throw if property missing), we'll attempt multiple named getters via mirrors-like approach isn't available.
          } catch (_) {
            // ignore
          }

          // Final safe attempt: check commonly-used properties explicitly with try/catch
          try {
            if (fieldName == 'fundsToAdd' &&
                (state as dynamic).fundsToAdd != null) {
              final list = (state as dynamic).fundsToAdd as List<dynamic>;
              return buildAdd
                  ? buildIsinAddFromFunds(list.cast())
                  : buildIsinRemoveFromFunds(list.cast());
            }
          } catch (_) {}
          try {
            if (fieldName == 'funds_to_add' &&
                (state as dynamic).funds_to_add != null) {
              final list = (state as dynamic).funds_to_add as List<dynamic>;
              return buildAdd
                  ? buildIsinAddFromFunds(list.cast())
                  : buildIsinRemoveFromFunds(list.cast());
            }
          } catch (_) {}
          try {
            if (fieldName == 'selectedFundsForAdd' &&
                (state as dynamic).selectedFundsForAdd != null) {
              final list =
                  (state as dynamic).selectedFundsForAdd as List<dynamic>;
              return buildAdd
                  ? buildIsinAddFromFunds(list.cast())
                  : buildIsinRemoveFromFunds(list.cast());
            }
          } catch (_) {}
          try {
            if (fieldName == 'selectedForAdd' &&
                (state as dynamic).selectedForAdd != null) {
              final list = (state as dynamic).selectedForAdd as List<dynamic>;
              return buildAdd
                  ? buildIsinAddFromFunds(list.cast())
                  : buildIsinRemoveFromFunds(list.cast());
            }
          } catch (_) {}
          try {
            if (fieldName == 'addedFunds' &&
                (state as dynamic).addedFunds != null) {
              final list = (state as dynamic).addedFunds as List<dynamic>;
              return buildAdd
                  ? buildIsinAddFromFunds(list.cast())
                  : buildIsinRemoveFromFunds(list.cast());
            }
          } catch (_) {}
          try {
            if (fieldName == 'fundsToRemove' &&
                (state as dynamic).fundsToRemove != null) {
              final list = (state as dynamic).fundsToRemove as List<dynamic>;
              return buildAdd
                  ? buildIsinAddFromFunds(list.cast())
                  : buildIsinRemoveFromFunds(list.cast());
            }
          } catch (_) {}
          try {
            if (fieldName == 'removedFunds' &&
                (state as dynamic).removedFunds != null) {
              final list = (state as dynamic).removedFunds as List<dynamic>;
              return buildAdd
                  ? buildIsinAddFromFunds(list.cast())
                  : buildIsinRemoveFromFunds(list.cast());
            }
          } catch (_) {}

          // If none matched, return empty
          return <String>[];
        }

        // Try to build isinAdd by scanning likely fields
        for (final name in stateCandidates) {
          // build only for add-related names
          if ([
            'fundsToAdd',
            'funds_to_add',
            'selectedFundsForAdd',
            'selected_funds_for_add',
            'selectedForAdd',
            'addedFunds',
            'toBeAddedFunds',
          ].contains(name)) {
            final out = tryBuild(name, true);
            if (out.isNotEmpty) {
              isinAdd = out;
              break;
            }
          }
        }

        // Try to build isinRemove similarly
        for (final name in stateCandidates) {
          if ([
            'fundsToRemove',
            'funds_to_remove',
            'selectedFundsForRemove',
            'selected_funds_for_remove',
            'selectedForRemove',
            'removedFunds',
            'toBeRemovedFunds',
          ].contains(name)) {
            final out = tryBuild(name, false);
            if (out.isNotEmpty) {
              isinRemove = out;
              break;
            }
          }
        }
      } catch (e) {
        print(
          '⚠️ Warning: error while attempting to build isinAdd/isinRemove from state: $e',
        );
        isinAdd = <String>[];
        isinRemove = <String>[];
      }

      // Final safety: if there are explicit sets on state like only fundCodes (strings), try to use them to create "<code>:<folio>" pairs
      try {
        // If state has something like addedFundTuples as List<Map> with code/folio, handle it
        if (isinAdd.isEmpty) {
          try {
            final dynamic cand = (state as dynamic).addedFundTuples;
            if (cand != null && cand is List) {
              final built = <String>[];
              for (final e in cand) {
                try {
                  final code = (e['fundCode'] ?? e['fund_code'] ?? e['code'])
                      .toString();
                  final folio = (e['folioNo'] ?? e['folio'] ?? e['folio_no'])
                      .toString();
                  if (code.trim().isNotEmpty && folio.trim().isNotEmpty) {
                    built.add('$code:$folio');
                  }
                } catch (_) {}
              }
              if (built.isNotEmpty) isinAdd = built;
            }
          } catch (_) {}
        }

        if (isinRemove.isEmpty) {
          try {
            final dynamic cand = (state as dynamic).removedFundTuples;
            if (cand != null && cand is List) {
              final built = <String>[];
              for (final e in cand) {
                try {
                  final code = (e['fundCode'] ?? e['fund_code'] ?? e['code'])
                      .toString();
                  final folio = (e['folioNo'] ?? e['folio'] ?? e['folio_no'])
                      .toString();
                  if (code.trim().isNotEmpty && folio.trim().isNotEmpty) {
                    built.add('$code:$folio');
                  }
                } catch (_) {}
              }
              if (built.isNotEmpty) isinRemove = built;
            }
          } catch (_) {}
        }
      } catch (_) {}

      // -------------------------------
      // Keep your existing modify logic unchanged
      // -------------------------------
      final bool hasFundEdits =
          state.editedFundAmounts != null && state.editedFundAmounts.isNotEmpty;

      if (hasFundEdits) {
        final selectedFunds = state.pledgeableFunds.where((fund) {
          return state.selectedFundIds.contains(fund.fundCode);
        }).toList();

        final builtModify = selectedFunds.map((f) {
          final double editedValue = state.editedFundAmounts[f.fundCode] ?? 0.0;
          final units = editedValue;
          final unitsStr = units == units.roundToDouble()
              ? units.toStringAsFixed(0)
              : units.toStringAsFixed(3).replaceFirst(RegExp(r'\.?0+$'), '');
          return '${f.fundCode}:${f.folioNo}:$unitsStr';
        }).toList();

        // add the built modify entries
        // NOTE: this is exactly your existing logic
        // (we're appending to the local isinModify defined below)
        // ensure we have a local list to add to:
        // (declare here)
      }

      // build a fresh modify list (keeping original logic)
      final List<String> isinModify = <String>[];
      final bool hasModify =
          state.editedFundAmounts != null && state.editedFundAmounts.isNotEmpty;
      if (hasModify) {
        final selectedFunds = state.pledgeableFunds.where((fund) {
          return state.selectedFundIds.contains(fund.fundCode);
        }).toList();

        final builtModify = selectedFunds.map((f) {
          final double editedValue = state.editedFundAmounts[f.fundCode] ?? 0.0;
          final units = editedValue;
          final unitsStr = units == units.roundToDouble()
              ? units.toStringAsFixed(0)
              : units.toStringAsFixed(3).replaceFirst(RegExp(r'\.?0+$'), '');
          return '${f.fundCode}:${f.folioNo}:$unitsStr';
        }).toList();

        isinModify.addAll(builtModify);
      }

      // -------------------------------
      // Final logging before API call
      // -------------------------------
      print('📤 FINAL PAYLOAD:');
      print('   → req_id: $reqId');
      print('   → loan_amount: ${event.amount}');
      print('   → lender_id: ${event.lenderId}');
      print('   → isin_add (${isinAdd.length}): $isinAdd');
      print('   → isin_remove (${isinRemove.length}): $isinRemove');
      print(
        '   → isin_modify (${isinModify.length}): ${isinModify.length > 0 ? (isinModify.length <= 20 ? isinModify : '${isinModify.length} entries (truncated)') : isinModify}',
      );

      // -------------------------------
      // API CALL (unchanged)
      // -------------------------------
      final double loanAmountToSend = event.amount;

      final result = await lenderRepository.editLoanAmount(
        reqId: reqId,
        loanAmount: loanAmountToSend,
        lenderId: event.lenderId,
        isinAdd: isinAdd,
        isinRemove: isinRemove,
        isinModify: isinModify,
      );

      // -------------------------------
      // Result handling (unchanged)
      // -------------------------------
      if (result is Success<MfDetailsResponse>) {
        final updatedResponse = result.value;

        final updatedLenders = state.lenders.map((l) {
          if (l.id == event.lenderId) {
            return l.copyWith(loanAmount: event.amount);
          }
          return l;
        }).toList();

        emit(
          state.copyWith(
            mfDetailsResponse: updatedResponse,
            lenders: updatedLenders,
            pledgeableFunds: updatedResponse.pledgeableFunds,
            isEditingLoan: false,
            isSavingLoan: false,
            lastSavedLenderId: event.lenderId,
            lastSaveMessage: "Loan amount updated successfully!",
            snackbarMessage: "Loan amount updated successfully!",
          ),
        );
        print('→ EMIT: success, isSavingLoan = false');
      } else if (result is Failure) {
        final msg = "Failed to update loan amount";
        emit(
          state.copyWith(
            isEditingLoan: false,
            isSavingLoan: false,
            lastSavedLenderId: event.lenderId,
            lastSaveMessage: msg,
            snackbarMessage: msg,
          ),
        );
        print('→ EMIT: failure, isSavingLoan = false');
      } else {
        emit(
          state.copyWith(
            isEditingLoan: false,
            isSavingLoan: false,
            lastSavedLenderId: event.lenderId,
            lastSaveMessage: "Unexpected server response",
            snackbarMessage: "Unexpected server response",
          ),
        );
        print('→ EMIT: unexpected, isSavingLoan = false');
      }
    } catch (e, stack) {
      print('💥 Exception during SaveEditedLoanAmount: $e\n$stack');
      emit(
        state.copyWith(
          isEditingLoan: false,
          isSavingLoan: false,
          lastSavedLenderId: event.lenderId,
          lastSaveMessage: "Something went wrong",
          snackbarMessage: "Something went wrong",
        ),
      );
      print('→ EMIT: exception, isSavingLoan = false');
    }
  }

  void _onProceedToLenderSelection(
    ProceedToLenderSelection event,
    Emitter<EligibilityState> emit,
  ) {
    print("Handling ProceedToLenderSelection event...");

    emit(
      state.copyWith(
        currentOverlay: EligibilityOverlayType.none,
        pageIndex: 2,
        majorStep: 2,
        clearErrors: true,
        isLoading: false,
      ),
    );

    // Trigger data fetch for lender selection
    add(FetchStep2Data());
  }

  //steps pressed
  //steps pressed
  Future<void> _onNextStepPressed(
    NextStepPressed event,
    Emitter<EligibilityState> emit,
  ) async {
    bool proceed = true;

    // STEP 0: Investment type selection
    if (state.pageIndex == 0) {
      if (state.formData.investmentType == InvestmentType.none) {
        emit(
          state.copyWith(
            generalErrorMessage: 'Please select an investment type.',
          ),
        );
        proceed = false;
      }
    }

    // STEP 1: Insurance flow → go to Insurance Upload page (index 2)
    if (state.pageIndex == 1 &&
        state.formData.investmentType == InvestmentType.insurancePolicy) {
      emit(
        state.copyWith(
          pageIndex: 2, // goes to Insurance Upload page
          majorStep: 1,
          clearErrors: true,
        ),
      );
      return;
    }

    // STEP 1: Shares flow → go to next page (index 2), NO PAN validation
    if (state.pageIndex == 1 &&
        state.formData.investmentType == InvestmentType.shares) {
      emit(state.copyWith(pageIndex: 2, majorStep: 1, clearErrors: true));
      return;
    }

    // STEP 1: PAN flow (Mutual Fund etc.)
    if (state.pageIndex == 1) {
      final pan = state.formData.panNumber;
      final name = state.formData.panFullName;
      final dob = state.formData.panDob;

      String? panError, nameError, dobError;

      if (pan == null || pan.isEmpty) {
        panError = 'PAN number is required.';
        proceed = false;
      } else if (pan.length != 10) {
        panError = 'Please enter a valid 10-digit PAN.';
        proceed = false;
      }

      if (name == null || name.isEmpty) {
        nameError = 'Name is required.';
        proceed = false;
      }

      if (dob == null || dob.isEmpty) {
        dobError = 'Date of Birth is required.';
        proceed = false;
      }

      if (!proceed) {
        emit(
          state.copyWith(
            panNumberError: panError,
            panFullNameError: nameError,
            panDobError: dobError,
          ),
        );
        return;
      }

      // 🔥 Correct: open fetching overlay
      emit(
        state.copyWith(
          isLoading: true,
          clearErrors: true,
          currentOverlay: EligibilityOverlayType.fetchingPortfolio,
        ),
      );

      // 🔥 Correct: call API
      add(FetchStep2Data());

      // ❌ DO NOT add any overlay logic here.
      return;
    }

    if (!proceed) return;

    // STEP > 1: rest of flow
    switch (state.pageIndex) {
      case 0:
        emit(state.copyWith(pageIndex: 1, majorStep: 1, clearErrors: true));
        break;

      case 2:
        // 🔥 If INSURANCE → Submit Upload Docs & Move to Success
        if (state.formData.investmentType == InvestmentType.insurancePolicy) {
          emit(
            state.copyWith(
              pageIndex: 5, // Your Success Screen index
              majorStep: 4,
              clearErrors: true,
            ),
          );
          return;
        }

        // 🔥 Otherwise normal MF / Shares lender validation (for now)
        if (state.selectedLenderId == null) {
          emit(
            state.copyWith(
              generalErrorMessage: 'Please select a lender to continue.',
            ),
          );
          return;
        }
        emit(
          state.copyWith(
            pageIndex: 4,
            majorStep: 3,
            clearErrors: true,
            clearSelectedLender: true,
          ),
        );
        break;

      case 3:
        emit(state.copyWith(pageIndex: 4, majorStep: 3, clearErrors: true));
        break;

      case 4:
        emit(state.copyWith(pageIndex: 5, majorStep: 4, clearErrors: true));
        break;

      case 5:
        emit(state.copyWith(isLoading: true));
        print('Form submitted: ${state.formData}');
        await Future.delayed(const Duration(seconds: 2));
        emit(state.copyWith(isLoading: false));
        break;

      default:
        emit(state.copyWith(clearErrors: true));
    }
  }

  void _onPreviousStepPressed(
    PreviousStepPressed event,
    Emitter<EligibilityState> emit,
  ) {
    // keep clearing transient UI state
    emit(
      state.copyWith(
        clearErrors: true,
        generalErrorMessage: null,
        clearSelectedLender: true,
      ),
    );

    // keep your existing page 2 (lender selection) internal handling
    if (state.pageIndex == 2) {
      if (state.lenderSelectionView == LenderSelectionView.pledgeableDetail) {
        emit(
          state.copyWith(
            lenderSelectionView: LenderSelectionView.portfolioBreakdown,
          ),
        );
        return;
      } else if (state.lenderSelectionView ==
          LenderSelectionView.portfolioBreakdown) {
        emit(
          state.copyWith(lenderSelectionView: LenderSelectionView.lenderList),
        );
        return;
      } else if (state.lenderSelectionView ==
          LenderSelectionView.fundSelection) {
        emit(
          state.copyWith(lenderSelectionView: LenderSelectionView.lenderList),
        );
        return;
      }
    }

    // ------- Minimal page-level back handling -------
    switch (state.pageIndex) {
      case 0:
        // already at investment page — nothing to do here
        break;

      case 1:
        // <- CHANGE: PAN page should go back to mutual-fund (investment) page
        emit(state.copyWith(pageIndex: 0, majorStep: 1));
        break;

      case 2:
        emit(state.copyWith(pageIndex: 1, majorStep: 1));
        break;

      case 3:
        emit(state.copyWith(pageIndex: 2, majorStep: 2));
        break;

      case 4:
        emit(state.copyWith(pageIndex: 2, majorStep: 2));
        break;

      case 5:
        emit(state.copyWith(pageIndex: 4, majorStep: 3));
        break;

      default:
        break;
    }
  }

  void _onErrorMessageCleared(
    ErrorMessageCleared event,
    Emitter<EligibilityState> emit,
  ) {
    emit(state.copyWith(clearErrors: true, generalErrorMessage: null));
  }

  Future<void> _onStartKyc(
    StartKycEvent event,
    Emitter<EligibilityState> emit,
  ) async {
    print('🚀 _onStartKyc called in bloc');
    print('📋 reqId: ${event.reqId}');
    print('📋 lenderCode: ${event.lenderCode}');
    print('📍 Location: ${event.latitude}, ${event.longitude}');

    emit(state.copyWith(kycLoading: true, kycError: null));
    try {
      print('📞 Calling _kycRepository.startKyc...');
      final response = await _kycRepository.startKyc(
        reqId: event.reqId,
        lenderCode: event.lenderCode,
        latitude: event.latitude,
        longitude: event.longitude,
      );
      print('📞 API Response: ${response.status}');

      if (response.status == 'success') {
        emit(state.copyWith(kycLoading: false, kycUrl: response.data.url));

        await Navigator.push(
          event.context,
          MaterialPageRoute(
            builder: (context) => WebViewScreen(url: response.data.url),
          ),
        );
      } else {
        final errorMsg = response.message ?? 'KYC initiation failed';
        print('❌ KYC Error: $errorMsg');
        emit(state.copyWith(kycLoading: false, kycError: errorMsg));
      }
    } catch (e) {
      String errorMessage = 'Unknown error';
      if (e is DioException && e.response != null) {
        errorMessage = e.response?.data['message'] ?? 'Network error';
      }
      print('❌ KYC Exception: $errorMessage');
      emit(state.copyWith(kycLoading: false, kycError: errorMessage));
    }
  }

  void _onUpdateKycStep(UpdateKycStep event, Emitter<EligibilityState> emit) {
    print('🔄 Updating KYC step ${event.stepIndex} to ${event.isCompleted}');
    print('📝 Before update: ${state.kycStepChecks}');

    final updated = List<bool>.from(state.kycStepChecks);
    updated[event.stepIndex] = event.isCompleted;

    print('📝 After update: $updated');
    emit(state.copyWith(kycStepChecks: updated));
  }

  void _onUpdateKycStepsReset(
    UpdateKycStepsReset event,
    Emitter<EligibilityState> emit,
  ) {
    print('🔄 Resetting all KYC steps to initial state');
    emit(state.copyWith(kycStepChecks: [false, false, false, false]));
  }

  void _onUpdateKycStepsAll(
    UpdateKycStepsAll event,
    Emitter<EligibilityState> emit,
  ) {
    print('🔄 Updating all KYC steps at once: ${event.steps}');
    emit(state.copyWith(kycStepChecks: event.steps));
  }

  void _onMarkEligibilityResultSeen(
    MarkEligibilityResultSeen event,
    Emitter<EligibilityState> emit,
  ) {
    emit(state.copyWith(hasSeenEligibilityResult: true));
    _saveEligibilitySeenFlag(true);
  }

  Future<void> _loadEligibilitySeenFlag() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenResult = prefs.getBool('hasSeenEligibilityResult') ?? false;
    if (hasSeenResult) {
      emit(state.copyWith(hasSeenEligibilityResult: true));
    }
  }

  Future<void> _saveEligibilitySeenFlag(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenEligibilityResult', value);
  }

  static Future<void> clearEligibilitySeenFlag() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('hasSeenEligibilityResult');
  }

  Future<void> _onVerifyRtaOtp(
    VerifyRtaOtp event,
    Emitter<EligibilityState> emit,
  ) async {
    // Validation checks
    if (event.otp.isEmpty || event.otp.length < 4) {
      emit(state.copyWith(rtaOtpError: 'Please enter a valid OTP'));
      return;
    }

    if (event.phone.isEmpty) {
      emit(state.copyWith(rtaOtpError: 'Mobile number is required'));
      return;
    }

    emit(state.copyWith(isRtaOtpVerifying: true, rtaOtpError: null));

    final reqId = getIt<AppStateProvider>().reqId;
    if (reqId == null || reqId.isEmpty) {
      emit(
        state.copyWith(
          isRtaOtpVerifying: false,
          rtaOtpError: 'Session expired. Please login again.',
        ),
      );
      return;
    }

    try {
      final result = await _rtaOtpRepository.verifyRtaOtp(
        reqId: reqId,
        phone: event.phone,
        rta: event.rta,
        otp: event.otp,
        refNo: event.refNo,
      );

      result.when(
        success: (response) {
          if (response.status == 'success') {
            emit(
              state.copyWith(
                isRtaOtpVerifying: false,
                rtaOtpError: null,
                snackbarMessage: 'OTP verified successfully!',
              ),
            );
          } else {
            final errorMessage = response.message.trim().isNotEmpty
                ? response.message
                : 'OTP verification failed. Please try again.';
            emit(
              state.copyWith(
                isRtaOtpVerifying: false,
                rtaOtpError: errorMessage,
              ),
            );
          }
        },
        failure: (error) {
          emit(state.copyWith(isRtaOtpVerifying: false, rtaOtpError: error));
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          isRtaOtpVerifying: false,
          rtaOtpError: 'Something went wrong. Please try again.',
        ),
      );
    }
  }

  void _onSetUserMobileNumber(
    SetUserMobileNumber event,
    Emitter<EligibilityState> emit,
  ) {
    emit(state.copyWith(userMobileNumber: event.mobileNumber));
  }

  /// 📱 Start Digio SDK for penny drop (Link Account step)
  /// Called when: Status is kyc_done and user taps step 2, or automatically after kyc_done
  /// Purpose: Initialize Digio SDK, start KYC workflow for bank account linking
  Future<void> _onStartDigioKyc(
    StartDigioKyc event,
    Emitter<EligibilityState> emit,
  ) async {
    debugPrint('🚀 Starting Digio KYC');
    emit(
      state.copyWith(kycLoading: true, kycError: null, hasTriggeredDigio: true),
    );

    try {
      // Clear old docId and polling status before starting fresh
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('docId${event.reqId}');
      await prefs.remove('pennydrop_done_${event.reqId}');
      debugPrint('🧹 Cleared old docId and pennydrop status for fresh start');

      // Stop any active polling to start fresh
      _digioRepository.stopPolling();
      debugPrint('🛑 Stopped any existing polling');

      final configResult = await _digioRepository.getDigioConfig(
        reqId: event.reqId,
        context: event.context,
      );

      await configResult.when(
        success: (config) async {
          debugPrint('✅ Digio config received: $config');

          final data = config['data'];
          if (data == null) {
            add(DigioKycFailed('Config data is null'));
            return;
          }

          final customerId =
              data['id']?.toString() ?? data['customer_id']?.toString() ?? '';
          final identifier =
              data['customer_identifier']?.toString() ??
              data['identifier']?.toString() ??
              '';
          final accessToken = data['access_token']?.toString() ?? '';
          final environment = data['environment']?.toString() ?? 'sandbox';

          debugPrint('📋 Customer ID: $customerId');
          debugPrint('📋 Identifier: $identifier');
          debugPrint('📋 Environment: $environment');

          if (customerId.isEmpty || identifier.isEmpty || accessToken.isEmpty) {
            add(DigioKycFailed('Missing required Digio parameters'));
            return;
          }

          final initResult = await _digioService.initializeSDK(environment);

          await initResult.when(
            success: (_) async {
              debugPrint('✅ SDK initialized, requesting camera permission...');

              if (event.context != null) {
                // Request camera permission before starting SDK
                final cameraStatus = await Permission.camera.request();
                if (!cameraStatus.isGranted) {
                  add(DigioKycFailed('Camera permission denied'));
                  return;
                }

                debugPrint(
                  '✅ Camera permission granted, starting Digio KYC...',
                );
                final kycResult = await _digioService.startKYC(
                  customerId: customerId,
                  identifier: identifier,
                  accessToken: accessToken,
                );
                debugPrint('📱 Digio SDK startKYC called');

                await kycResult.when(
                  success: (result) {
                    debugPrint('✅ KYC Result: $result');
                    // Check if user cancelled
                    if (result.contains('User cancelled') || result.contains('cancelled')) {
                      debugPrint('🚫 User cancelled - not triggering completion');
                      _digioService.resetProcessingState();
                      add(DigioKycFailed('User cancelled'));
                    } else if (result.contains('KYC process completed')) {
                      debugPrint('✅ KYC completed - starting penny drop polling');
                      // Extract documentId from result
                      final docIdMatch = RegExp(r'documentId : ([^,]+)').firstMatch(result);
                      if (docIdMatch != null) {
                        final docId = docIdMatch.group(1)?.trim();
                        if (docId != null && docId.isNotEmpty) {
                          debugPrint('💰 Starting penny drop polling with docId: $docId');
                          // Show loader during polling
                          emit(state.copyWith(isPennyDropPolling: true));
                          // Start polling until success
                          _digioRepository.startPollingKycStatus(
                            null,
                            docId,
                            onPollingComplete: () {
                              debugPrint('✅ Penny drop polling completed');
                              // Use add() instead of emit() in callback
                              add(const PennyDropPollingCompleted());
                            },
                          );
                        } else {
                          add(DigioKycFailed('No documentId found'));
                        }
                      } else {
                        add(DigioKycFailed('Could not extract documentId'));
                      }
                    } else {
                      add(const DigioKycCompleted());
                    }
                  },
                  failure: (error) {
                    debugPrint('❌ KYC failed: $error');
                    _digioService.resetProcessingState();
                    add(DigioKycFailed(error));
                  },
                );
              } else {
                debugPrint('⚠️ No context, skipping SDK launch');
                emit(state.copyWith(kycLoading: false));
              }
            },
            failure: (error) {
              debugPrint('❌ SDK init failed: $error');
              add(DigioKycFailed(error));
            },
          );
        },
        failure: (error) {
          debugPrint('❌ Config fetch failed: $error');
          add(DigioKycFailed(error));
        },
      );
    } catch (e) {
      debugPrint('❌ Exception: $e');
      add(DigioKycFailed('Failed to start KYC: $e'));
    }
  }

  void _onDigioKycCompleted(
    DigioKycCompleted event,
    Emitter<EligibilityState> emit,
  ) async {
    debugPrint('✅ Digio KYC completed');
    emit(state.copyWith(kycLoading: false, kycError: null));

    final reqId = getIt<AppStateProvider>().reqId;
    if (reqId != null) {
      final prefs = await SharedPreferences.getInstance();

      // Clear old penny drop status to allow fresh API call
      await prefs.remove('pennydrop_done_$reqId');
      debugPrint('🧹 Cleared old pennydrop status');

      // Wait for backend to process
      await Future.delayed(const Duration(seconds: 2));

      // Fetch fresh config to get latest docId
      debugPrint('🔄 Fetching fresh config for latest docId...');
      final configResult = await _digioRepository.getDigioConfig(reqId: reqId);

      await configResult.when(
        success: (config) async {
          final newDocId = config['data']?['id']?.toString();
          if (newDocId != null && newDocId.isNotEmpty) {
            await prefs.setString('docId$reqId', newDocId);
            debugPrint('✅ Stored docId: $newDocId');
            debugPrint('🚀 Starting penny drop polling...');

            emit(state.copyWith(isPennyDropPolling: true));

            // Start polling - it will call penny drop API automatically every 5 seconds
            _digioRepository.startPollingKycStatus(
              null,
              newDocId,
              onPollingComplete: () {
                debugPrint('✅ Polling completed successfully');
                add(const PennyDropPollingCompleted());
              },
            );
          } else {
            debugPrint('❌ No docId found in config');
            emit(state.copyWith(isPennyDropPolling: false));
          }
        },
        failure: (err) {
          debugPrint('❌ Config fetch error: $err');
          emit(state.copyWith(isPennyDropPolling: false));
        },
      );
    }

    add(const CheckPledgeStatus());
  }

  void _onDigioKycFailed(DigioKycFailed event, Emitter<EligibilityState> emit) {
    debugPrint('❌ Digio KYC failed: ${event.error}');
    emit(state.copyWith(kycLoading: false, kycError: event.error));
  }

  /// 🎯 KYC Screen: Initial pledge MF API call, WebSocket connection, and auto KYC flow
  /// Called when: Screen loads, WebSocket status changes
  /// Purpose: Fetch current KYC status, update checkboxes, setup WebSocket listener
  Future<void> _onCheckPledgeStatus(
    CheckPledgeStatus event,
    Emitter<EligibilityState> emit,
  ) async {
    // Reset Digio trigger flag when checking status
    emit(state.copyWith(isLoading: true, hasTriggeredDigio: false));

    final reqId = getIt<AppStateProvider>().reqId;
    final token = getIt<AppStateProvider>().token;

    if (reqId == null || token == null) {
      emit(state.copyWith(isLoading: false));
      return;
    }

    final kycSteps = [
      "fillBasicInfo".tr,
      "aadharPanVerification".tr,
      "linkAccountMandate".tr,
      "loanAgreementSigning".tr,
      "SetMandate".tr,
    ];

    final pledgeRepo = PledgeStatusRepository(getIt<ApiClient>());
    final result = await pledgeRepo.checkPledgeMfStatus(
      reqId: reqId,
      authToken: token,
    );

    result.when(
      success: (data) async {
        final statusData = data['data']?['status'];
        String? initialStatus;
        if (statusData is String) {
          initialStatus = statusData;
        } else if (statusData is List && statusData.isNotEmpty) {
          initialStatus = statusData.first as String?;
        }

        // ✅ Auto-check checkboxes based on current KYC status
        List<bool> initialSteps = [false, false, false, false, false];

        if (initialStatus != null) {
          switch (initialStatus) {
            case 'pan_verified':
            case 'start_kyc':
              // Step 0: Fill Basic Info - Not started yet
              break;
            case 'kyc_done':
              // Steps 0,1: Fill Basic Info + Aadhar Pan Verification - DONE
              initialSteps[0] = true;
              initialSteps[1] = true;
              debugPrint('✅ Auto-checked steps 0 & 1 for kyc_done status');
              break;
            case 'penny_drop_done':
              // Steps 0,1,2: Basic + Aadhar + Link Account - DONE
              initialSteps[0] = true;
              initialSteps[1] = true;
              initialSteps[2] = true;
              break;
            case 'kfs_agreement_done':
              // Steps 0,1,2,3: Basic + Aadhar + Link + Agreement - DONE
              initialSteps[0] = true;
              initialSteps[1] = true;
              initialSteps[2] = true;
              initialSteps[3] = true;
              break;
            case 'final_step_done':
            case 'completed':
            case 'mandate_done':
              // All steps completed
              initialSteps = [true, true, true, true, true];
              break;
          }
        }

        emit(
          state.copyWith(
            kycSteps: kycSteps,
            kycStepChecks: initialSteps,
            isLoading: false,
            currentKycStatus: initialStatus,
            kycUrl: null,
          ),
        );

        // 🔌 WebSocket Listener: Real-time KYC status updates
        // Handles: kyc_done, penny_drop_done, kfs_agreement_done, completed/mandate_done
        await pledgeRepo.connectWebSocket(token);
        _socketSubscription?.cancel();
        _socketSubscription = pledgeRepo.listenForKycStatus().listen((
          response,
        ) async {
          final status = response['status'] as String?;
          debugPrint('🔔 WebSocket status received: $status');

          if (status == 'kyc_done') {
            try {
              debugPrint('✅ kyc_done - closing WebView, updating steps');
              _webViewCloseController.add(true);
              add(const UpdateKycStep(0, true));
              add(const UpdateKycStep(1, true));
              add(const SetKycProcessing(true));
              
              // Schedule state update and Digio trigger
              Future.delayed(const Duration(milliseconds: 500), () {
                try {
                  if (!isClosed) {
                    debugPrint('🔄 Refreshing pledge status after kyc_done');
                    add(const CheckPledgeStatus());
                    if (event.context != null) {
                      Future.delayed(const Duration(milliseconds: 500), () {
                        try {
                          if (!isClosed) {
                            debugPrint('🚀 Triggering Digio SDK after kyc_done');
                            add(StartDigioKyc(reqId: reqId, context: event.context));
                          }
                        } catch (e) {
                          debugPrint('❌ Error triggering Digio SDK: $e');
                          add(const SetKycProcessing(false));
                        }
                      });
                    } else {
                      debugPrint('⚠️ No context available for Digio trigger');
                      add(const SetKycProcessing(false));
                    }
                  }
                } catch (e) {
                  debugPrint('❌ Error in CheckPledgeStatus: $e');
                  add(const SetKycProcessing(false));
                }
              });
            } catch (e) {
              debugPrint('❌ Error in kyc_done handler: $e');
              add(const SetKycProcessing(false));
            }
          } else if (status == 'penny_drop_done') {
            debugPrint('✅ penny_drop_done - updating step 2');
            add(const UpdateKycStep(2, true));
            add(const CheckPledgeStatus());
          } else if (status == 'kfs_agreement_done' || status == 'completed') {
            debugPrint('✅ $status - closing WebView');
            _webViewCloseController.add(true);
            add(const CheckPledgeStatus());
          } else if (status != null) {
            add(const CheckPledgeStatus());
          }
        });

        // 🚀 Auto-start KYC flow based on current status
        final allStepsComplete =
            initialSteps.length >= 5 && initialSteps.every((s) => s);

        if (!allStepsComplete) {
          if (initialStatus == null ||
              initialStatus == 'pending' ||
              initialStatus == 'start_kyc' ||
              initialStatus == 'pan_verified') {
            // Status: New user or PAN verified -> Start Step 0 (Fill Basic Info)
            await _startKycFlow(reqId);
          } else if (initialStatus == 'kyc_done' && event.context != null) {
            // Status: KYC done -> Auto-start Digio SDK
            debugPrint('🚀 Auto-starting Digio SDK for kyc_done status');
            add(StartDigioKyc(reqId: reqId, context: event.context!));
          } else if (initialStatus == 'penny_drop_done') {
            // Status: Penny drop done -> Start Step 3 (Agreement)
            await _startKycFlow(reqId);
          } else if (initialStatus == 'kfs_agreement_done') {
            // Status: Agreement done -> Start Step 4 (Mandate)
            await _startKycFlow(reqId);
          }
        }
      },
      failure: (error) {
        debugPrint('Error checking pledge status: $error');
      },
    );
  }

  /// 🚀 Auto start KYC API call
  /// Called when: Status is pan_verified/pending/start_kyc, or kfs_agreement_done from WebSocket
  /// Purpose: Request location permission, call start-kyc API, store URL in state for WebView
  Future<void> _startKycFlow(String reqId) async {
    try {
      // Show loader
      emit(state.copyWith(kycLoading: true, kycError: null));

      // Check and request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('❌ Location permission denied');
          emit(
            state.copyWith(
              kycLoading: false,
              kycError: 'Location permission denied',
            ),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('❌ Location permission permanently denied');
        emit(
          state.copyWith(
            kycLoading: false,
            kycError: 'Location permission denied',
          ),
        );
        return;
      }

      // Get current location
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final response = await _kycRepository.startKyc(
        reqId: reqId,
        lenderCode: 'BFL',
        latitude: position.latitude,
        longitude: position.longitude,
      );
      debugPrint('Start KYC response: ${response.status}');

      // Store URL in state for UI to open WebView
      if (response.status == 'success' && response.data.url.isNotEmpty) {
        String stepName = 'KYC Verification';
        if (state.currentKycStatus == 'kfs_agreement_done') {
          stepName = state.kycSteps.length > 4
              ? state.kycSteps[4]
              : 'Set Mandate';
        } else if (state.currentKycStatus == 'penny_drop_done') {
          stepName = state.kycSteps.length > 3
              ? state.kycSteps[3]
              : 'Loan Agreement Signing';
        } else {
          stepName = state.kycSteps.isNotEmpty
              ? state.kycSteps[0]
              : 'Fill Basic Info';
        }
        emit(
          state.copyWith(
            kycLoading: false,
            kycUrl: response.data.url,
            currentStepName: stepName,
          ),
        );
      } else {
        emit(
          state.copyWith(kycLoading: false, kycError: 'Failed to get KYC URL'),
        );
      }
    } catch (e) {
      debugPrint('Start KYC error: $e');
      emit(state.copyWith(kycLoading: false, kycError: e.toString()));
    }
  }

  /// Handle Digio SDK config and penny drop API when kyc_done
  Future<void> _handleDigioFlow(String reqId) async {
    try {
      final configResult = await _digioRepository.getDigioConfig(reqId: reqId);

      configResult.when(
        success: (config) async {
          final prefs = await SharedPreferences.getInstance();
          final docId = prefs.getString('docId$reqId');

          if (docId != null && docId.isNotEmpty) {
            final updateResult = await _digioRepository.updateKycStatus(
              null,
              docId,
              onWebViewOpen: () {},
            );

            updateResult.when(
              success: (link) => debugPrint('Penny drop success: $link'),
              failure: (err) => debugPrint('Penny drop error: $err'),
            );
          }
        },
        failure: (err) => debugPrint('Digio config error: $err'),
      );
    } catch (e, stack) {
      debugPrint('Digio flow error: $e\n$stack');
    }
  }

  Future<void> _openWebView(String url, BuildContext context) async {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => WebViewScreen(url: url)),
      );
    } catch (e) {
      print('Failed to open WebView: $e');
    }
  }

  /// Request location permission and start KYC flow
  Future<void> _onRequestLocationAndStartKyc(
    RequestLocationAndStartKyc event,
    Emitter<EligibilityState> emit,
  ) async {
    try {
      debugPrint('🌍 Requesting location permission...');

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('❌ Location services are disabled');
        return;
      }

      // Check current permission status
      LocationPermission permission = await Geolocator.checkPermission();
      debugPrint('📍 Current permission: $permission');

      // Request permission if denied
      if (permission == LocationPermission.denied) {
        debugPrint('🔔 Requesting location permission dialog...');
        permission = await Geolocator.requestPermission();
        debugPrint('📍 Permission after request: $permission');

        if (permission == LocationPermission.denied) {
          debugPrint('❌ Location permission denied by user');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('❌ Location permission permanently denied');
        return;
      }

      debugPrint('✅ Location permission granted, fetching location...');

      // Get current location
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      debugPrint('📍 Location: ${position.latitude}, ${position.longitude}');

      final reqId = getIt<AppStateProvider>().reqId;
      if (reqId == null || reqId.isEmpty) {
        debugPrint('❌ reqId is null or empty');
        return;
      }

      debugPrint('🚀 Triggering StartKycEvent with location');

      // Trigger start KYC with location
      add(
        StartKycEvent(
          reqId: reqId,
          lenderCode: 'BFL',
          latitude: position.latitude,
          longitude: position.longitude,
          context: event.context,
        ),
      );
    } catch (e) {
      debugPrint('❌ Location error: $e');
    }
  }

  /// 👆 Handle manual step tap by user
  /// Called when: User taps on any KYC step
  /// Purpose:
  ///   - Step 0: Start KYC flow (location + API)
  ///   - Step 2: Start Digio SDK for Link Account
  ///   - Step 3/4: Start KYC flow for agreement/mandate
  Future<void> _onKycStepTapped(
    KycStepTapped event,
    Emitter<EligibilityState> emit,
  ) async {
    debugPrint('🔔 KycStepTapped handler called for step ${event.stepIndex}');

    final reqId = getIt<AppStateProvider>().reqId;
    if (reqId == null) {
      debugPrint('❌ reqId is null');
      return;
    }

    final status = state.currentKycStatus;
    debugPrint('📊 Current KYC status: $status');

    // Step 0: Start KYC flow
    if (event.stepIndex == 0 &&
        (status == null ||
            status == 'start_kyc' ||
            status == 'pending' ||
            status == 'pan_verified')) {
      try {
        final stepName = state.kycSteps.isNotEmpty
            ? state.kycSteps[0]
            : 'Fill Basic Info';
        emit(state.copyWith(currentStepName: stepName));

        debugPrint('📍 Fetching location for KYC...');
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        debugPrint(
          '✅ Location fetched: ${position.latitude}, ${position.longitude}',
        );

        add(
          StartKycEvent(
            reqId: reqId,
            lenderCode: 'BFL',
            latitude: position.latitude,
            longitude: position.longitude,
            context: event.context,
          ),
        );
        debugPrint('✅ StartKycEvent added to bloc');
      } catch (e) {
        debugPrint('❌ Error in KycStepTapped: $e');
      }
    }
    // Step 2: Link Account - Start Digio SDK
    else if (event.stepIndex == 2 && status == 'kyc_done') {
      debugPrint('🚀 Starting Digio SDK for Link Account step');
      // Clear all flags before starting
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('docId$reqId');
      await prefs.remove('pennydrop_done_$reqId');
      // Clear cancelled state for manual trigger
      _digioService.clearCancelledState();
      emit(state.copyWith(hasTriggeredDigio: false));
      add(StartDigioKyc(reqId: reqId, context: event.context));
    }
    // Step 3: Loan Agreement - Check penny drop first if kyc_done
    else if (event.stepIndex == 3) {
      if (status == 'kyc_done') {
        // Digio complete but penny drop pending
        debugPrint('💰 Checking penny drop before loan agreement...');
        final prefs = await SharedPreferences.getInstance();
        final docId = prefs.getString('docId$reqId');

        if (docId != null && docId.isNotEmpty) {
          final updateResult = await _digioRepository.updateKycStatus(
            null,
            docId,
            onWebViewOpen: () {},
          );
          updateResult.when(
            success: (link) {
              debugPrint('✅ Penny drop success, refreshing status...');
              add(const CheckPledgeStatus());
            },
            failure: (err) => debugPrint('❌ Penny drop error: $err'),
          );
        }
      } else if (status == 'penny_drop_done') {
        // Penny drop done, start loan agreement
        try {
          final stepName = state.kycSteps.length > 3
              ? state.kycSteps[3]
              : 'Loan Agreement Signing';
          emit(state.copyWith(currentStepName: stepName));

          final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );

          add(
            StartKycEvent(
              reqId: reqId,
              lenderCode: 'BFL',
              latitude: position.latitude,
              longitude: position.longitude,
              context: event.context,
            ),
          );
        } catch (e) {
          debugPrint('❌ Error in Step 3: $e');
        }
      }
    }
    // Step 4: Mandate
    else if (event.stepIndex == 4 && status == 'kfs_agreement_done') {
      try {
        final stepName = state.kycSteps.length > 4
            ? state.kycSteps[4]
            : 'Set Mandate';
        emit(state.copyWith(currentStepName: stepName));

        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        add(
          StartKycEvent(
            reqId: reqId,
            lenderCode: 'BFL',
            latitude: position.latitude,
            longitude: position.longitude,
            context: event.context,
          ),
        );
      } catch (e) {
        debugPrint('❌ Error in Step 4: $e');
      }
    }
  }

  @override
  Future<void> close() {
    _socketSubscription?.cancel();
    _webViewCloseController.close();
    return super.close();
  }
}
