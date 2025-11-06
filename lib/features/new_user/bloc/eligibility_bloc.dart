import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:las_app/app.dart';
import 'package:las_app/core/app_state_provider.dart';
import 'package:las_app/core/results/result.dart';
import 'package:las_app/features/new_user/repository/lenders_data_repo.dart';
import 'package:las_app/features/new_user/repository/pan_veirfy_repo.dart';
import 'package:las_app/models/pan_verification/pan_otp_response_model.dart';
import 'package:las_app/models/pan_verification/pan_verify_response_model.dart';
part 'eligibility_event.dart';
part 'eligibility_state.dart';

class EligibilityBloc extends Bloc<EligibilityEvent, EligibilityState> {
  final PanRepository repository;
  final LenderRepository lenderRepository;
  EligibilityBloc({required this.repository, required this.lenderRepository})
    : super(const EligibilityState()) {
    on<InvestmentTypeUpdated>(_onInvestmentTypeUpdated);

    on<PanNumberUpdated>(_onPanNumberUpdated);
    on<PanFullNameUpdated>(_onPanFullNameUpdated);
    on<PanDobUpdated>(_onPanDobUpdated);
    on<VerifyPanPressed>(_onVerifyPanPressed);
    on<SendPanOtpPressed>(_onSendPanOtpPressed);
    on<VerifyPanOtpPressed>(_onVerifyPanOtpPressed);
    on<EligibilitySnackbarCleared>(_onSnackbarCleared);

    on<FetchStep2Data>(_onFetchStep2Data);
    on<LenderSelected>(_onLenderSelected);
    on<ViewDetailsToggled>(_onViewDetailsToggled);
    on<RefreshPortfolioPressed>(_onRefreshPortfolioPressed);
    on<BreakdownCategoryTapped>(_onBreakdownCategoryTapped);
    on<EditLoanAmountPressed>(_onEditLoanAmountPressed);
    on<SaveEditedLoanAmount>(_onSaveEditedLoanAmount);
    on<LenderContinuePressed>(_onLenderContinuePressed);
    on<ProceedToLenderSelection>(_onProceedToLenderSelection);

    on<ToggleFundSelection>(_onToggleFundSelection);
    on<ConfirmFundSelection>(_onConfirmFundSelection);
    on<ToggleKycStep>(_onToggleKycStep);

    //pledging otp
    on<OtpChanged>(_onOtpChanged);
    on<SubmitOtp>(_onSubmitOtp);
    on<ResendOtp>(_onResendOtp);

    on<NextStepPressed>(_onNextStepPressed);
    on<PreviousStepPressed>(_onPreviousStepPressed);
    on<ErrorMessageCleared>(_onErrorMessageCleared);
  }

  //kyc
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

  //pledge funds
  void _onOtpChanged(OtpChanged event, Emitter<EligibilityState> emit) {
    emit(state.copyWith(otp: event.otp, otpError: false));
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
          emit(
            state.copyWith(
              panStatus: PanVerificationStatus.failed,
              generalErrorMessage: 'Missing reqId in response.',
            ),
          );
          return;
        }

        // ✅ Save reqId globally
        getIt<AppStateProvider>().setReqId(reqId);

        // ✅ Now generate OTP
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
          final lenders = mfResponse.lenders.map((l) {
            return Lender(
              id: l.id.toString(),
              name: l.name ?? '-',
              logoAsset: l.logo ?? '',
              interestRate: l.loanInterest ?? 0.0,
              loanAmount: l.loanAmount ?? 0.0,
              pledgeableMFs: l.eligibleFundsCount ?? 0,
              tag: '',
              lender_code: l.lender_code ?? 'BFL',
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

          emit(
            state.copyWith(
              isLoading: false,
              lenders: lenders,
              portfolioData: portfolio,
            ),
          );
        },
        failure: (error) {
          emit(state.copyWith(isLoading: false, generalErrorMessage: error));
        },
      );
    } catch (e) {
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
    emit(
      state.copyWith(
        selectedLenderId: newSelectedId,
        clearSelectedLender: newSelectedId == null,
      ),
    );
  }

  void _onToggleFundSelection(
    ToggleFundSelection event,
    Emitter<EligibilityState> emit,
  ) {
    final newSelectedIds = Set<String>.from(state.selectedFundIds);
    if (newSelectedIds.contains(event.fundId)) {
      newSelectedIds.remove(event.fundId);
    } else {
      newSelectedIds.add(event.fundId);
    }
    emit(state.copyWith(selectedFundIds: newSelectedIds));
  }

  void _onConfirmFundSelection(
    ConfirmFundSelection event,
    Emitter<EligibilityState> emit,
  ) {
    print('Fund selection confirmed. Selected IDs: ${state.selectedFundIds}');

    add(NextStepPressed());
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
    emit(state.copyWith(isPortfolioRefreshing: true));
    try {
      await Future.delayed(const Duration(seconds: 2));
      emit(
        state.copyWith(
          isPortfolioRefreshing: false,
          portfolioData: const PortfolioData(
            totalValue: 1250000,
            eligibleCreditLimit: 490000,
            pledgeableFunds: 560000,
          ),
        ),
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
      emit(
        state.copyWith(
          lenderSelectionView: LenderSelectionView.pledgeableDetail,
        ),
      );
    }
  }

  void _onEditLoanAmountPressed(
    EditLoanAmountPressed event,
    Emitter<EligibilityState> emit,
  ) {
    print('Edit loan amount triggered for lender ${event.lenderId}');
  }

  void _onSaveEditedLoanAmount(
    SaveEditedLoanAmount event,
    Emitter<EligibilityState> emit,
  ) {
    final newAmounts = Map<String, double>.from(state.editedLoanAmounts);

    newAmounts[event.lenderId] = event.amount;

    emit(state.copyWith(editedLoanAmounts: newAmounts));
  }

  Future<void> _onLenderContinuePressed(
    LenderContinuePressed event,
    Emitter<EligibilityState> emit,
  ) async {
    print('Continue pressed for lender ${event.lenderId}');

    emit(state.copyWith(isLoading: true));

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final funds = [
        const PledgeableFund(
          id: 'f1',
          name: 'HDFC Midcap Opportunities Fund',
          value: 556000,
          units: 24,
          perUnitValue: 1234.56,
        ),
        const PledgeableFund(
          id: 'f2',
          name: 'ICICI Prudential Balanced Advantage Fund',
          value: 556000,
          units: 30,
          perUnitValue: 1000.00,
        ),
        const PledgeableFund(
          id: 'f3',
          name: 'Axis Bluechip Fund - Direct Growth',
          value: 556000,
          units: 50,
          perUnitValue: 800.00,
        ),
      ];

      final selectedIds = funds.map((f) => f.id).toSet();

      emit(
        state.copyWith(
          isLoading: false,
          lenderSelectionView: LenderSelectionView.fundSelection,
          pledgeableFunds: funds,
          selectedFundIds: selectedIds,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          generalErrorMessage: 'Failed to fetch funds.',
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

        emit(
          state.copyWith(
            isLoading: false,
            currentOverlay: EligibilityOverlayType.eligibilityResult,
          ),
        );
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
}
