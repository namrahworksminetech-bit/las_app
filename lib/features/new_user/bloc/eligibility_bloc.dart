import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:las_app/app.dart';
import 'package:las_app/core/app_state_provider.dart';
import 'package:las_app/core/results/result.dart';
import 'package:las_app/features/new_user/repository/lenders_data_repo.dart'
    hide DioException;
import 'package:las_app/features/new_user/repository/rta_otp_repo.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:las_app/features/new_user/repository/pan_veirfy_repo.dart';
import 'package:las_app/features/new_user/view/widgets/three_kyc_verification/step_checker_view.dart';
import 'package:las_app/helper_widgets/funds_merger.dart';
import 'package:las_app/models/funds/mf_details_response_model.dart';
import 'package:las_app/models/funds/pledgeable_model.dart';
import 'package:las_app/models/pan_verification/pan_otp_response_model.dart';
import 'package:las_app/models/pan_verification/pan_verify_response_model.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:las_app/common_widgets/webview_screen.dart';

import '../../../core/network/api_client.dart';
import '../repository/kyc_repo.dart';

part 'eligibility_event.dart';

part 'eligibility_state.dart';

class EligibilityBloc extends Bloc<EligibilityEvent, EligibilityState> {
  final PanRepository repository;
  final LenderRepository lenderRepository;
  final KycRepository _kycRepository;
  final RtaOtpRepository _rtaOtpRepository;

  EligibilityBloc({
    required this.repository,
    required this.lenderRepository,
    required ApiClient apiClient,
  }) : _kycRepository = KycRepository(apiClient),
       _rtaOtpRepository = RtaOtpRepository(apiClient),
       super(const EligibilityState()) {
    _loadEligibilitySeenFlag();
    on<InvestmentTypeUpdated>(_onInvestmentTypeUpdated);

    on<PanNumberUpdated>(_onPanNumberUpdated);
    on<PanFullNameUpdated>(_onPanFullNameUpdated);
    on<PanDobUpdated>(_onPanDobUpdated);
    on<VerifyPanPressed>(_onVerifyPanPressed);
    on<SendPanOtpPressed>(_onSendPanOtpPressed);
    on<VerifyPanOtpPressed>(_onVerifyPanOtpPressed);
    on<EligibilitySnackbarCleared>(_onSnackbarCleared);
    on<AutoSelectAllFunds>(_onAutoSelectAllFunds);

    on<FetchStep2Data>(_onFetchStep2Data);
    on<LenderSelected>(_onLenderSelected);
    on<ViewDetailsToggled>(_onViewDetailsToggled);
    on<RefreshPortfolioPressed>(_onRefreshPortfolioPressed);
    on<BreakdownCategoryTapped>(_onBreakdownCategoryTapped);
    on<EditLoanAmountPressed>(_onEditLoanAmountPressed);
    on<SaveEditedLoanAmount>(_onSaveEditedLoanAmount);
    on<LenderContinuePressed>(_onLenderContinuePressed);
    on<ProceedToLenderSelection>(_onProceedToLenderSelection);

    on<ClearSnackbar>(_onClearSnackbar);

    on<ToggleFundSelection>(_onToggleFundSelection);
    on<ConfirmFundSelection>(_onConfirmFundSelection);
    on<ToggleKycStep>(_onToggleKycStep);

    ///pledging otp
    on<OtpChanged>(_onOtpChanged);
    on<SubmitOtp>(_onSubmitOtp);
    on<ResendOtp>(_onResendOtp);

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
    emit(state.copyWith(isLoading: true, generalErrorMessage: null));

    try {
      // 1️⃣ Get selected UI lender
      final selectedUiLender = state.lenders.firstWhere(
        (l) => l.id == event.lenderId,
        orElse: () => throw Exception('Selected lender not found in UI list'),
      );

      // 2️⃣ Get mfDetailsResponse
      final mfDetails = state.mfDetailsResponse;
      if (mfDetails == null)
        throw Exception('mfDetailsResponse not loaded yet');

      // 3️⃣ Find the full LenderItem details by matching ID
      final lenderItem = mfDetails.lenders.firstWhere(
        (l) => l.id.toString() == selectedUiLender.id,
        orElse: () =>
            throw Exception('Lender details not found in mfDetailsResponse'),
      );

      // 4️⃣ Extract eligible funds
      final eligibleFunds = lenderItem.eligibleFunds ?? [];
      if (eligibleFunds.isEmpty) {
        emit(
          state.copyWith(
            isLoading: false,
            generalErrorMessage:
                'No eligible funds found for ${selectedUiLender.name}.',
          ),
        );
        return;
      }

      // 5️⃣ Use pledgeableFunds list from mfDetailsResponse
      final fundDetails = mfDetails.pledgeableFunds;
      if (fundDetails.isEmpty) {
        emit(
          state.copyWith(
            isLoading: false,
            generalErrorMessage: 'No pledgeable fund details found.',
          ),
        );
        return;
      }

      // 6️⃣ Merge both using helper
      final mergedFunds = FundsMerger.merge(
        eligibleFunds: eligibleFunds,
        fundDetails: fundDetails,
      );

      if (mergedFunds.isEmpty) {
        emit(
          state.copyWith(
            isLoading: false,
            generalErrorMessage:
                'No matching funds found for ${selectedUiLender.name}.',
          ),
        );
        return;
      }

      // 7️⃣ Collect selected IDs (folio numbers)
      final selectedIds = mergedFunds.map((f) => f.folioNo).toSet();

      // 8️⃣ Emit state for next screen
      emit(
        state.copyWith(
          isLoading: false,
          selectedLenderId: selectedUiLender.id,
          lenderSelectionView: LenderSelectionView.fundSelection,
          pledgeableFunds: mergedFunds,
          selectedFundIds: selectedIds,
        ),
      );

      print(
        '✅ ${mergedFunds.length} pledgeable funds ready for ${selectedUiLender.name}',
      );
    } catch (e, st) {
      print('❌ Error in _onLenderContinuePressed: $e\n$st');
      emit(
        state.copyWith(
          isLoading: false,
          generalErrorMessage:
              'Something went wrong while preparing lender funds.',
        ),
      );
    }
  }

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

  // pan
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
    if (state.isLoading || state.isPortfolioRefreshing) return;

    print("🔄 Fetching lenders and portfolio data...");

    try {
      final reqId = getIt<AppStateProvider>().reqId;
      if (reqId == null) {
        emit(
          state.copyWith(
            isLoading: false,
            generalErrorMessage:
                "Missing request ID. Please restart the process.",
          ),
        );
        return;
      }

      final result = await lenderRepository.fetchLendersAndPortfolio(
        reqId: reqId,
      );

      await result.when(
        success: (mfResponse) async {
          print("✅ Lenders parsed: ${mfResponse.lenders.length}");
          print(
            "✅ Pledgeable funds parsed: ${mfResponse.pledgeableFunds.length}",
          );
          print("✅ Pledgeable Amount: ${mfResponse.pledgeableAmount}");
          print("✅ Non-Pledgeable Amount: ${mfResponse.nonPledgeableAmount}");
          print("✅ Demat Amount: ${mfResponse.dematAmount}");
          print("✅ Eligible Portfolio: ${mfResponse.eligiblePortfolio}");
          print("✅ Max Eligible Limit: ${mfResponse.maxEligibleLimit}");

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

          // ✅ Emit updated state directly with mfResponse data
          emit(
            state.copyWith(
              isLoading: false,
              lenders: lenders,
              pledgeableFunds: mfResponse.pledgeableFunds,
              mfDetailsResponse: mfResponse,

              // Optional: derived summary data for UI
            ),
          );

          print("🟢 Stored lender + MF data successfully.");
        },
        failure: (error) {
          print("❌ Failed to fetch Step 2 data: $error");
          emit(state.copyWith(isLoading: false, generalErrorMessage: error));
        },
      );
    } catch (e, stack) {
      print("❌ Exception while fetching Step 2 data: $e");
      print("🧠 Stacktrace: $stack");
      emit(
        state.copyWith(
          isLoading: false,
          generalErrorMessage: "Failed to fetch lender data.",
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

    // ✅ Emit updated selection and store current state for future diffing
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
    print('🧩 Confirming Fund Selection...');
    print('Selected Fund IDs: ${state.selectedFundIds}');
    print('Edited Amounts: ${state.editedLoanAmounts}');

    emit(state.copyWith(isLoading: true));

    try {
      final lenderId = state.selectedLenderId ?? '';
      final reqId = getIt<AppStateProvider>().reqId ?? '';
      print("📋 Current reqId: $reqId");

      if (reqId.isEmpty) {
        emit(
          state.copyWith(
            isLoading: false,
            generalErrorMessage: 'Missing reqId. Please login again.',
          ),
        );
        return;
      }

      final loanAmount =
          state.editedLoanAmounts[lenderId] ??
          state.selectedLender?.loanAmount ??
          0.0;

      // 🧮 Build ISIN lists for add/remove/modify
      final previousFunds = state.previousSelectedFundIds;
      final currentFunds = state.selectedFundIds;

      final isinAdd = currentFunds.difference(previousFunds).toList();
      final isinRemove = previousFunds.difference(currentFunds).toList();

      // 🧠 For modify: pattern 'fundCode:folioNo:amount'
      final isinModify = state.pledgeableFunds
          .where((f) => currentFunds.contains(f.fundCode))
          .map(
            (f) =>
                "${f.fundCode}:${f.folioNo ?? ''}:${(f.availableAmount ?? 0.0).toStringAsFixed(2)}",
          )
          .toList();

      print('📤 ISIN_ADD: $isinAdd');
      print('📤 ISIN_REMOVE: $isinRemove');
      print('📤 ISIN_MODIFY: $isinModify');

      // 🪄 Call updated repository method
      final result = await lenderRepository.editLoanAmount(
        reqId: reqId,
        loanAmount: loanAmount,
        lenderId: lenderId,
        isinAdd: isinAdd,
        isinRemove: isinRemove,
        isinModify: isinModify,
      );

      await result.when(
        success: (updatedData) async {
          print('✅ Loan Amount Updated Successfully');

          emit(
            state.copyWith(
              mfDetailsResponse: updatedData,
              pledgeableFunds: updatedData.pledgeableFunds,
              lenders: updatedData.lenders.map((l) {
                return Lender(
                  id: l.id.toString(),
                  name: l.name ?? '-',
                  logoAsset: l.logo ?? '',
                  interestRate: l.loanInterest ?? 0.0,
                  loanAmount: l.loanAmount ?? 0.0,
                  pledgeableMFs: l.eligibleFundsCount ?? 0,
                  tag: '',
                );
              }).toList(),
              isLoading: false,
            ),
          );
          // ✅ Navigate to KYC screen after successful update
          final context = event.context;
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<EligibilityBloc>(),
                  child: const KycVerificationScreen(),
                ),
              ),
            );
          }
        },
        failure: (error) {
          print('❌ API failed: $error');
          emit(state.copyWith(isLoading: false, generalErrorMessage: error));
        },
      );
    } catch (e, st) {
      print('❌ Unexpected error in ConfirmFundSelection: $e\n$st');
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

  Future<void> _onSaveEditedLoanAmount(
    SaveEditedLoanAmount event,
    Emitter<EligibilityState> emit,
  ) async {
    try {
      // Start loader
      emit(
        state.copyWith(
          isEditingLoan: true,
          isLoading: true,
          lastSavedLenderId: null,
          lastSaveMessage: null,
        ),
      );

      final reqId = getIt<AppStateProvider>().reqId ?? '';
      final isinModify = state.selectedFundIds.toList();

      print("📤 Calling editLoanAmount API...");
      print(
        "🧩 reqId: $reqId | lenderId: ${event.lenderId} | newAmount: ${event.amount}",
      );
      print("🔄 ISIN Modify: $isinModify");

      final result = await lenderRepository.editLoanAmount(
        reqId: reqId,
        loanAmount: event.amount,
        lenderId: event.lenderId,
        isinAdd: const [],
        isinRemove: const [],
        isinModify: isinModify,
      );

      // SUCCESS
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
            isLoading: false,
            lastSavedLenderId: event.lenderId,
            lastSaveMessage: "Loan amount updated successfully!",
            snackbarMessage: "Loan amount updated successfully!",
          ),
        );
        return;
      }

      // FAILURE
      if (result is Failure) {
        const msg = "Failed to update loan amount";
        emit(
          state.copyWith(
            isLoading: false,
            isEditingLoan: false,
            lastSavedLenderId: event.lenderId,
            lastSaveMessage: msg,
            snackbarMessage: msg,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          isLoading: false,
          isEditingLoan: false,
          lastSavedLenderId: event.lenderId,
          lastSaveMessage: "Unexpected server response",
          snackbarMessage: "Unexpected server response",
        ),
      );
    } catch (e, stack) {
      emit(
        state.copyWith(
          isLoading: false,
          isEditingLoan: false,
          lastSavedLenderId: event.lenderId,
          lastSaveMessage: "Something went wrong",
          snackbarMessage: "Something went wrong",
        ),
      );
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

        // Check if user has already seen eligibility result
        if (state.hasSeenEligibilityResult) {
          // Skip overlay and go directly to lender selection
          emit(
            state.copyWith(
              isLoading: false,
              currentOverlay: EligibilityOverlayType.none,
            ),
          );
          add(ProceedToLenderSelection());
        } else {
          // Show eligibility result overlay for first time
          emit(
            state.copyWith(
              isLoading: false,
              currentOverlay: EligibilityOverlayType.eligibilityResult,
            ),
          );
        }
      }
      return;
    } else if (state.pageIndex == 2) {
      if (state.selectedLenderId == null) {
        emit(
          state.copyWith(
            generalErrorMessage: 'Please select a lender to continue.',
          ),
        );
        proceed = false;
      }
    }

    if (!proceed) return;

    switch (state.pageIndex) {
      case 0:
        emit(state.copyWith(pageIndex: 1, majorStep: 1, clearErrors: true));
        break;

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
  }

  void _onPreviousStepPressed(
    PreviousStepPressed event,
    Emitter<EligibilityState> emit,
  ) {
    emit(
      state.copyWith(
        clearErrors: true,
        generalErrorMessage: null,
        clearSelectedLender: true,
      ),
    );

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

    switch (state.pageIndex) {
      case 0:
        print("Cannot go back further from the first page.");
        break;
      case 1:
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
    emit(state.copyWith(kycLoading: true, kycError: null));
    try {
      final response = await _kycRepository.startKyc(
        reqId: event.reqId,
        lenderCode: event.lenderCode,
        latitude: event.latitude,
        longitude: event.longitude,
      );

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

  Future<void> _openWebView(String url, BuildContext context) async {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WebViewScreen(url: url),
        ),
      );
    } catch (e) {
      print('Failed to open WebView: $e');
    }
  }
}
