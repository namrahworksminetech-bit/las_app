import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'eligibility_event.dart';
part 'eligibility_state.dart';

class EligibilityBloc extends Bloc<EligibilityEvent, EligibilityState> {
  EligibilityBloc() : super(const EligibilityState()) {
    on<InvestmentTypeUpdated>(_onInvestmentTypeUpdated);
    on<PanNumberUpdated>(_onPanNumberUpdated);
    on<PanFullNameUpdated>(_onPanFullNameUpdated);
    on<PanDobUpdated>(_onPanDobUpdated);

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

    on<OtpChanged>(_onOtpChanged);
    on<SubmitOtp>(_onSubmitOtp);
    on<ResendOtp>(_onResendOtp);

    on<NextStepPressed>(_onNextStepPressed);
    on<PreviousStepPressed>(_onPreviousStepPressed);
    on<ErrorMessageCleared>(_onErrorMessageCleared);
  }
  void _onToggleKycStep(ToggleKycStep event, Emitter<EligibilityState> emit) {
    final updated = List<bool>.from(state.kycStepChecks);
    updated[event.index] = !updated[event.index];
    emit(state.copyWith(kycStepChecks: updated));
  }

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

  Future<void> _onFetchStep2Data(
    FetchStep2Data event,
    Emitter<EligibilityState> emit,
  ) async {
    if (state.lenders.isNotEmpty ||
        state.isLoading ||
        state.isPortfolioRefreshing)
      return;
    emit(state.copyWith(isLoading: true));
    try {
      await Future.delayed(const Duration(seconds: 1));
      final lenders = [
        const Lender(
          id: '1',
          name: 'Bajaj Finance Limited',
          logoAsset: 'URL_HERE',
          interestRate: 10.08,
          loanAmount: 485800,
          pledgeableMFs: 38,
          tag: 'Lowest EMI',
        ),
        const Lender(
          id: '2',
          name: 'Tata Capital Limited',
          logoAsset: 'URL_HERE',
          interestRate: 10.95,
          loanAmount: 485800,
          pledgeableMFs: 38,
          tag: 'Fastest Processing',
        ),
        const Lender(
          id: '3',
          name: 'Kotak Mahindra Bank',
          logoAsset: 'URL_HERE',
          interestRate: 11.50,
          loanAmount: 485800,
          pledgeableMFs: 38,
          tag: '',
        ),
      ];
      const portfolio = PortfolioData(
        totalValue: 1240000,
        eligibleCreditLimit: 485800,
        pledgeableFunds: 556000,
      );
      emit(
        state.copyWith(
          isLoading: false,
          lenders: lenders,
          portfolioData: portfolio,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          generalErrorMessage: "Failed to load lender data.",
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

        bool isEligible = true;

        if (isEligible) {
          emit(
            state.copyWith(
              isLoading: false,
              currentOverlay: EligibilityOverlayType.eligibilityResult,
            ),
          );
        // ignore: dead_code
        } else {
          emit(
            state.copyWith(
              isLoading: false,
              currentOverlay: EligibilityOverlayType.none,
              generalErrorMessage: 'Loan eligibility check failed.',
              clearErrors: true,
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
}
