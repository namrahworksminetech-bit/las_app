<<<<<<< HEAD
import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:las_app/features/new_user/repository/shares_repo.dart';
import 'package:las_app/helper_widgets/fund_utils.dart';
import 'package:las_app/models/funds/funds_detail_model.dart';
import 'package:las_app/models/funds/pledge_mf_response.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:las_app/features/new_user/repository/pan_veirfy_repo.dart';

import 'package:las_app/models/funds/mf_details_response_model.dart';
import 'package:las_app/models/funds/pledgeable_model.dart';
import 'package:las_app/models/pan_verification/pan_otp_response_model.dart';
import 'package:las_app/models/pan_verification/pan_verify_response_model.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:las_app/common_widgets/webview_screen.dart';

import '../../../core/network/api_client.dart';
import '../repository/kyc_repo.dart';

=======
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:las_app/app.dart';
import 'package:las_app/core/app_state_provider.dart';
import 'package:las_app/core/results/result.dart';
import 'package:las_app/features/new_user/repository/lenders_data_repo.dart';
import 'package:las_app/features/new_user/repository/pan_veirfy_repo.dart';
import 'package:las_app/models/pan_verification/pan_otp_response_model.dart';
import 'package:las_app/models/pan_verification/pan_verify_response_model.dart';
>>>>>>> 9c76ba7 (changes committed)
part 'eligibility_event.dart';
part 'eligibility_state.dart';

class EligibilityBloc extends Bloc<EligibilityEvent, EligibilityState> {
  final PanRepository repository;
  final LenderRepository lenderRepository;
<<<<<<< HEAD
  final KycRepo _kycRepository;
  final RtaOtpRepository _rtaOtpRepository;
  final DigioRepository _digioRepository;
  final DigioService _digioService = getIt<DigioService>();

final SharesRepository _sharesRepository = SharesRepository();


String? shareFileKey;    // store uploaded file path
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
    on<AcknowledgeKycNavigation>(_onAcknowledgeKycNavigation);
on<UploadHoldingFile>(_onUploadHoldingFile);
on<SubmitShareDetails>(_onSubmitShareDetails);


=======
  EligibilityBloc({required this.repository,required this.lenderRepository})
    : super(const EligibilityState()) {
    on<InvestmentTypeUpdated>(_onInvestmentTypeUpdated);

    on<PanNumberUpdated>(_onPanNumberUpdated);
    on<PanFullNameUpdated>(_onPanFullNameUpdated);
    on<PanDobUpdated>(_onPanDobUpdated);
>>>>>>> 9c76ba7 (changes committed)
    on<VerifyPanPressed>(_onVerifyPanPressed);
    on<SendPanOtpPressed>(_onSendPanOtpPressed);
    on<VerifyPanOtpPressed>(_onVerifyPanOtpPressed);
    on<EligibilitySnackbarCleared>(_onSnackbarCleared);
<<<<<<< HEAD
    on<AutoSelectAllFunds>(_onAutoSelectAllFunds);
    on<JumpToPage>(_onJumpToPage);
    on<StartFetchingFromLogin>(_onStartFetchingFromLogin);

   



=======
>>>>>>> 9c76ba7 (changes committed)

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

<<<<<<< HEAD
    ///pledging otp
=======
//pledging otp
>>>>>>> 9c76ba7 (changes committed)
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


  }
<<<<<<< HEAD
/* =========================================================
                      INSURANCE FLOW BLoC
   ========================================================= */
final InsuranceRepository _insuranceRepo = GetIt.instance<InsuranceRepository>();


/// ========== 1️⃣ Fetch Insurer List ==============
Future<void> _onFetchInsurers(
  FetchInsurers event,
  Emitter<EligibilityState> emit,
) async {
  emit(state.copyWith(isFetchingInsurers: true, insuranceError: null));

  final result = await _insuranceRepo.getInsurers();

  result.when(
    success: (companies) {
      emit(state.copyWith(
        insurers: companies,         // List<Map<String, dynamic>>
        isFetchingInsurers: false,
      ));
    },
    failure: (err) {
      emit(state.copyWith(
        isFetchingInsurers: false,
        insuranceError: err,
      ));
    },
  );
}

/// ========== 2️⃣ Save Step-1 Data =================
Future<void> _onSaveInsuranceForm(
  SaveInsuranceForm event,
  Emitter<EligibilityState> emit,
) async {
  emit(state.copyWith(
    insurerCode: event.insurerCode,
    insurancePolicyNo: event.policyNumber,
    insuranceName: event.name,
    insuranceDob: event.dob,
  ));
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
  urlRes.when(
    success: (_) {},
    failure: (err) => urlError = err,
  );

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
      emit(state.copyWith(
        isUploadingUnit: false,
        unitKey: key, //store path
      ));
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
  urlRes.when(
    success: (_) {},
    failure: (err) => urlError = err,
  );

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
      emit(state.copyWith(
        isUploadingPolicy: false,
        policyKey: key,
      ));
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

  if (state.unitKey == null || state.policyKey == null) {
    emit(state.copyWith(insuranceError: "Upload both documents first"));
    return;
  }

  emit(state.copyWith(
    isSubmittingInsurance: true,
    insuranceError: null,
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
      emit(state.copyWith(
        isSubmittingInsurance: false,
        insuranceSuccess: true,
      ));
    },
    failure: (err) {
      print("❌ SUBMIT FAILED → $err");
      emit(state.copyWith(
        isSubmittingInsurance: false,
        insuranceError: err,
      ));
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
  urlResult.when(
    success: (_) {},
    failure: (err) => urlError = err,
  );

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

      emit(state.copyWith(
        isShareUploading: false,
        shareUploadPath: uploadedKey, // ✅ store it in Bloc state
      ));
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
    emit(state.copyWith(
      shareError: "Please upload your Demat Holding Statement before continuing.",
    ));
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
      emit(state.copyWith(
        isShareSubmitting: false,
        shareSuccess: true,
      ));
    },
    failure: (err) {
      emit(state.copyWith(
        isShareSubmitting: false,
        shareError: err,
      ));
    },
  );
}

  // Replace your existing handler with this in EligibilityBloc
  void _onJumpToPage(JumpToPage event, Emitter<EligibilityState> emit) {
    // Defensive: clamp pageIndex to valid range if you want
    final int target = event.pageIndex.clamp(0, 5);

    // Determine majorStep mapping explicitly
    final int newMajor = switch (target) {
      0 => 1, // Investment / fund-type
      1 => 1, // PAN screen still majorStep 1
      2 => 2, // lender selection (major step 2)
      3 => 2,
      4 => 3, // next major step
      5 => 4, // final
      _ => state.majorStep,
    };

    // Default updates: pageIndex and majorStep
    var nextState = state.copyWith(
      pageIndex: target,
      majorStep: newMajor,
      // Ensure we clear any overlay if jumping programmatically
      currentOverlay: EligibilityOverlayType.none,
      // Clear any transient snackbar/generic error if desired:
      generalErrorMessage: null,
    );

    // If we are jumping to page 1 (PAN) from inside lender flow ensure lenderSelectionView
    // is set back to lenderList so it won't try to fetch when user navigates later.
    if (target == 1 &&
        state.lenderSelectionView != LenderSelectionView.lenderList) {
      nextState = nextState.copyWith(
        lenderSelectionView: LenderSelectionView.lenderList,
      );
    }

    // If jumping into lender flow (pageIndex 2) and you want a specific subview, you can
    // set it here; otherwise keep existing value.
    if (target == 2 && state.lenderSelectionView == null) {
      nextState = nextState.copyWith(
        lenderSelectionView: LenderSelectionView.lenderList,
      );
    }

    // Emit only once with everything applied
    emit(nextState);

    debugPrint(
      '🔁 JumpToPage -> page:$target major:$newMajor lenderView:${nextState.lenderSelectionView} overlay:${nextState.currentOverlay}',
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
=======

  //kyc 
>>>>>>> 9c76ba7 (changes committed)
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

<<<<<<< HEAD
=======

//pledge funds
>>>>>>> 9c76ba7 (changes committed)
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

<<<<<<< HEAD
  // pan
=======

// pan
>>>>>>> 9c76ba7 (changes committed)
  void _onPanNumberUpdated(
    PanNumberUpdated event,
    Emitter<EligibilityState> emit,
  ) {
    emit(
      state.copyWith(
        formData: state.formData.copyWith(panNumber: event.pan),
        panNumberError: null,
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

<<<<<<< HEAD
  Future<void> _onVerifyPanPressed(
    VerifyPanPressed event,
    Emitter<EligibilityState> emit,
  ) async {
    emit(
      state.copyWith(
        panStatus: PanVerificationStatus.verifying,
        generalErrorMessage: null,
      ),
    );
    final reqId = getIt<AppStateProvider>().reqId;

    if (reqId == null || reqId.isEmpty) {
      emit(
        state.copyWith(
          panStatus: PanVerificationStatus.failed,
          generalErrorMessage: 'Missing reqId. Please login again.',
        ),
      );
      return;
    }

    final result = await repository.verifyPan(
      reqId: reqId,
      // ✅ safe now
      pan: event.pan,
      dob: event.dob,
      name: event.name,
      email: event.email,
    );

    await result.when(
      success: (panResponse) async {
        final reqId = panResponse.reqId;

        if (reqId == null) {
          emit(
            state.copyWith(
              panStatus: PanVerificationStatus.failed,
              generalErrorMessage: 'Missing reqId in response.',
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
          ),
        );
      },
    );
  }

  Future<void> _onSendPanOtpPressed(
    SendPanOtpPressed event,
    Emitter<EligibilityState> emit,
  ) async {
=======
Future<void> _onVerifyPanPressed(
  VerifyPanPressed event,
  Emitter<EligibilityState> emit,
) async {
  emit(state.copyWith(
    panStatus: PanVerificationStatus.verifying,
    generalErrorMessage: null,
  ));
 final reqId = getIt<AppStateProvider>().reqId;

if (reqId == null || reqId.isEmpty) {
  emit(state.copyWith(
    panStatus: PanVerificationStatus.failed,
    generalErrorMessage: 'Missing reqId. Please login again.',
  ));
  return;
}

final result = await repository.verifyPan(
  reqId: reqId, // ✅ safe now
  pan: event.pan,
  dob: event.dob,
  name: event.name,
  email: event.email,
);

  await result.when(
    success: (panResponse) async {
      final reqId = panResponse.reqId;

      if (reqId == null) {
        emit(state.copyWith(
          panStatus: PanVerificationStatus.failed,
          generalErrorMessage: 'Missing reqId in response.',
        ));
        return;
      }

      // ✅ Save reqId globally
      getIt<AppStateProvider>().setReqId(reqId);

      // ✅ Now generate OTP
      final otpResult = await repository.generateOtp();

      otpResult.when(
        success: (otpResponse) {
          emit(state.copyWith(
            panStatus: PanVerificationStatus.verified,
            otpStatus: PanOtpStatus.sent,
            generalErrorMessage:
                otpResponse.message ?? 'OTP sent successfully.',
          ));
        },
        failure: (error) {
          emit(state.copyWith(
            otpStatus: PanOtpStatus.failed,
            generalErrorMessage: error,
          ));
        },
      );
    },
    failure: (error) {
      emit(state.copyWith(
        panStatus: PanVerificationStatus.failed,
        generalErrorMessage: error,
      ));
    },
  );
}

  Future<void> _onSendPanOtpPressed(
    SendPanOtpPressed event,
    Emitter<EligibilityState> emit,
  ) async {
>>>>>>> 9c76ba7 (changes committed)
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
<<<<<<< HEAD
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
=======
>>>>>>> 9c76ba7 (changes committed)
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


//fetch funds data
Future<void> _onFetchStep2Data(
  FetchStep2Data event,
  Emitter<EligibilityState> emit,
) async {
  if (state.isLoading || state.isPortfolioRefreshing) return;

  emit(state.copyWith(isLoading: true, generalErrorMessage: null));

  try {
    final reqId = getIt<AppStateProvider>().reqId;
    if (reqId == null) {
      emit(state.copyWith(
        isLoading: false,
        generalErrorMessage: "Missing request ID. Please restart the process.",
      ));
      return;
    }

    final result = await lenderRepository.fetchLendersAndPortfolio(reqId: reqId);

    await result.when(
      success: (mfResponse) async {
       final lenders = mfResponse.lenders.map((l) {
  return Lender(
    id: l.id.toString(),
    name: l.name ?? '-',
    logoAsset: l.logo ?? '',
    interestRate: l.loanInterest ?? 0.0,
    loanAmount: l.loanAmount ?? 0.0,
    pledgeableMFs: l.eligibleFundsCount ?? 0,
    tag: '',
  );
}).toList();

        // Compute aggregated portfolio data (optional)
        final totalEligiblePortfolio = lenders.fold<double>(
          0.0,
          (sum, l) => sum + (l.loanAmount),
        );

        final portfolio = PortfolioData(
          totalValue: totalEligiblePortfolio,
          eligibleCreditLimit: totalEligiblePortfolio,
          pledgeableFunds: totalEligiblePortfolio,
        );

        emit(state.copyWith(
          isLoading: false,
          lenders: lenders,
          portfolioData: portfolio,
        ));
      },
      failure: (error) {
        emit(state.copyWith(
          isLoading: false,
          generalErrorMessage: error,
        ));
      },
    );
  } catch (e) {
    emit(state.copyWith(
      isLoading: false,
      generalErrorMessage: "Failed to fetch lender data.",
    ));
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
        state.editedLoanAmounts[lenderId] ?? state.selectedLender?.loanAmount ?? 0.0;

    // Defensive: drop any empty fund codes from current selection
    final previousFunds = state.previousSelectedFundIds;
    final currentFundsRaw = state.selectedFundIds;
    final currentFunds = currentFundsRaw.where((s) => s.trim().isNotEmpty).toSet();
    if (currentFundsRaw.length != currentFunds.length) {
      debugPrint('⚠️ Removed empty/blank fund codes from selection');
    }

    // helpers & results
    final List<String> isinAdd = [];
    final List<String> isinRemove = [];
    final List<String> isinModify = []; // ALWAYS keep empty per backend rule
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
    if (filteredIsinAdd.length != isinAdd.length || filteredIsinRemove.length != isinRemove.length) {
      debugPrint('⚠️ Removed malformed ISIN entries from lists');
    }

    debugPrint('📤 ISIN_ADD (${filteredIsinAdd.length}): $filteredIsinAdd');
    debugPrint('📤 ISIN_REMOVE (${filteredIsinRemove.length}): $filteredIsinRemove');
    debugPrint('📤 ISIN_MODIFY (always empty): $isinModify');
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
      debugPrint('ℹ️ No add/remove -> sending loan_amount = $loanAmountToSend');
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
            loanAmount: l.loanAmount ?? 0.0,
            pledgeableMFs: l.eligibleFundsCount ?? 0,
            tag: '',
          );
        }).toList();

        emit(
          state.copyWith(
            mfDetailsResponse: updatedData,
            pledgeableFunds: updatedData.pledgeableFunds,
            lenders: updatedLenders,
            isLoading: false,
            shouldNavigateToKyc: true,
            generalErrorMessage: null,
          ),
        );
      },
      failure: (error) {
        debugPrint('❌ editLoanAmount failed: $error');
        emit(state.copyWith(isLoading: false, generalErrorMessage: error));
      },
    );
  } catch (e, st) {
    debugPrint('💥 Unexpected exception in _onConfirmFundSelection: $e\n$st');
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
    if (event.categoryId == 'pledgeable') {
      print("🟢 Switching to Pledgeable Detail view");
      print("🟢 Current funds count: ${state.pledgeableFunds.length}");

      emit(
        state.copyWith(
          lenderSelectionView: LenderSelectionView.pledgeableDetail,
        ),
      );
    } else {
      // For other categories (non-pledgeable, demat, etc.)
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

<<<<<<< HEAD
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
    emit(
      state.copyWith(
        pageIndex: 2,
        majorStep: 1,
        clearErrors: true,
      ),
    );
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
=======
//steps pressed
  Future<void> _onNextStepPressed(
    NextStepPressed event,
    Emitter<EligibilityState> emit,
  ) async {
    bool proceed = true;

    if (state.pageIndex == 0) {
      if (state.formData.investmentType == InvestmentType.none) {
        emit(
          state.copyWith(
            generalErrorMessage: 'Please select an investment type.',
          ),
        );
        proceed = false;
      }
    } else if (state.pageIndex == 1) {
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
      } else {
        emit(
          state.copyWith(
            isLoading: true,
            clearErrors: true,
            currentOverlay: EligibilityOverlayType.fetchingPortfolio,
          ),
        );

        await Future.delayed(const Duration(seconds: 10));

        bool panIsEligible = true;

          emit(
            state.copyWith(
              isLoading: false,
              currentOverlay: EligibilityOverlayType.eligibilityResult,
            ),
          );
      }
>>>>>>> 9c76ba7 (changes committed)
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
      emit(
        state.copyWith(
          pageIndex: 1,
          majorStep: 1,
          clearErrors: true,
        ),
      );
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
      emit(
        state.copyWith(
          pageIndex: 4,
          majorStep: 3,
          clearErrors: true,
        ),
      );
      break;

    case 4:
      emit(
        state.copyWith(
          pageIndex: 5,
          majorStep: 4,
          clearErrors: true,
        ),
      );
      break;

<<<<<<< HEAD
    case 5:
      emit(state.copyWith(isLoading: true));
      print('Form submitted: ${state.formData}');
      await Future.delayed(const Duration(seconds: 2));
      emit(state.copyWith(isLoading: false));
      break;

    default:
      emit(state.copyWith(clearErrors: true));
=======
      case 2:
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
        break;
    }
>>>>>>> 9c76ba7 (changes committed)
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
        await _openWebView(response.data.url, event.context);
        emit(state.copyWith(kycLoading: false, kycUrl: response.data.url));
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

  Future<void> _onStartDigioKyc(
    StartDigioKyc event,
    Emitter<EligibilityState> emit,
  ) async {
    emit(state.copyWith(kycLoading: true, kycError: null));

    try {
      final configResult = await _digioRepository.getDigioConfig(
        reqId: event.reqId,
      );

      await configResult.when(
        success: (config) async {
          final initResult = await _digioService.initializeSDK(
            config['environment'] ?? 'sandbox',
          );

          await initResult.when(
            success: (_) async {
              final kycResult = await _digioService.startKYC(
                customerId: config['customer_id'] ?? '',
                identifier: config['identifier'] ?? '',
                accessToken: config['access_token'] ?? '',
              );

              await kycResult.when(
                success: (result) {
                  print('KYC Result: $result');
                  add(const DigioKycCompleted());
                },
                failure: (error) {
                  add(DigioKycFailed(error));
                },
              );
            },
            failure: (error) {
              add(DigioKycFailed(error));
            },
          );
        },
        failure: (error) {
          add(DigioKycFailed(error));
        },
      );
    } catch (e) {
      add(DigioKycFailed('Failed to start KYC: $e'));
    }
  }

  void _onDigioKycCompleted(
    DigioKycCompleted event,
    Emitter<EligibilityState> emit,
  ) {
    emit(
      state.copyWith(
        kycLoading: false,
        kycError: null,
        snackbarMessage: 'KYC completed successfully!',
      ),
    );
  }

  void _onDigioKycFailed(DigioKycFailed event, Emitter<EligibilityState> emit) {
    emit(
      state.copyWith(
        kycLoading: false,
        kycError: event.error,
        snackbarMessage: 'KYC failed: ${event.error}',
      ),
    );
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
}
