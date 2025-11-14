part of 'eligibility_bloc.dart';

enum InvestmentType { insurancePolicy, mutualFund, shares, none }

enum PanVerificationStatus { initial, verifying, verified, failed }

enum PanOtpStatus { initial, sending, sent, verified, failed }

enum EligibilityOverlayType { none, fetchingPortfolio, eligibilityResult }

enum LenderSelectionView {
  lenderList,
  portfolioBreakdown,
  pledgeableDetail,
  fundSelection,
}

class Lender extends Equatable {
  final String id;
  final String name;
  final String logoAsset;
  final double interestRate;
  final double loanAmount;
  final int pledgeableMFs;
  final String tag;

  const Lender({
    required this.id,
    required this.name,
    required this.logoAsset,
    required this.interestRate,
    required this.loanAmount,
    required this.pledgeableMFs,
    required this.tag,
  });

  @override
  List<Object?> get props => [id];

  Lender copyWith({
    String? id,
    String? name,
    String? logoAsset,
    double? interestRate,
    double? loanAmount,
    int? pledgeableMFs,
    String? tag,
  }) {
    return Lender(
      id: id ?? this.id,
      name: name ?? this.name,
      logoAsset: logoAsset ?? this.logoAsset,
      interestRate: interestRate ?? this.interestRate,
      loanAmount: loanAmount ?? this.loanAmount,
      pledgeableMFs: pledgeableMFs ?? this.pledgeableMFs,
      tag: tag ?? this.tag,
    );
  }
}

class EligibilityFormData extends Equatable {
  const EligibilityFormData({
    this.investmentType = InvestmentType.none,
    this.panNumber,
    this.panFullName,
    this.panDob,
  });

  final InvestmentType investmentType;
  final String? panNumber;
  final String? panFullName;
  final String? panDob;

  EligibilityFormData copyWith({
    InvestmentType? investmentType,
    String? panNumber,
    String? panFullName,
    String? panDob,
  }) {
    return EligibilityFormData(
      investmentType: investmentType ?? this.investmentType,
      panNumber: panNumber ?? this.panNumber,
      panFullName: panFullName ?? this.panFullName,
      panDob: panDob ?? this.panDob,
    );
  }

  @override
  List<Object?> get props => [investmentType, panNumber, panFullName, panDob];
}

class EligibilityState extends Equatable {
  const EligibilityState({
    this.majorStep = 1,
    this.pageIndex = 0,
    this.formData = const EligibilityFormData(),
    this.generalErrorMessage,
    this.panNumberError,
    this.panFullNameError,
    this.panDobError,
    this.panStatus = PanVerificationStatus.initial,
    this.otpStatus = PanOtpStatus.initial,
    this.snackbarMessage,
    this.isLoading = false,
    this.currentOverlay = EligibilityOverlayType.none,
    this.lenderSelectionView = LenderSelectionView.lenderList,
    this.lenders = const [],
    this.selectedLenderId,
    this.isPortfolioRefreshing = false,
    this.editedLoanAmounts = const {},
    this.editLoanResult = const {},
    this.pledgeableFunds = const [],
    this.selectedFundIds = const {},
    this.previousSelectedFundIds = const {},
    this.mfDetailsResponse,
    this.lastSaveMessage,
    this.lastSavedLenderId,
    this.kycStepChecks = const [false, false, false, false],
    this.otp = '',
    this.isSubmitting = false,
      this.loadingLenderId,
    this.otpError = false,
    this.otpResent = false,
    this.kycUrl,
    this.kycLoading = false,
    this.kycError,
    this.hasSeenEligibilityResult = false,
    this.isRtaOtpVerifying = false,
    this.rtaOtpError,
    this.userMobileNumber,
  });

  // Core fields
  final int majorStep;
  final int pageIndex;
  final EligibilityFormData formData;
  final MfDetailsResponse? mfDetailsResponse;

  // New: lender-specific edit results: lenderId -> true/false/null
  final Map<String, bool?> editLoanResult;


final String? lastSavedLenderId;
final String? lastSaveMessage;
  // Verification / UI state
  final PanVerificationStatus panStatus;
  final PanOtpStatus otpStatus;
  final String? snackbarMessage;

  // Errors
  final String? generalErrorMessage;
  final String? panNumberError;
  final String? panFullNameError;
  final String? panDobError;

  // Loading / overlays
  final bool isLoading;
  final String? loadingLenderId; // new field (id of lender currently saving)

  final EligibilityOverlayType currentOverlay;

  // Lender selection & lists
  final LenderSelectionView lenderSelectionView;
  final List<Lender> lenders;
  final String? selectedLenderId;
  final bool isPortfolioRefreshing;

  // Edited amounts and pledgeable funds
  final Map<String, double> editedLoanAmounts;
  final List<PledgeableFund> pledgeableFunds;
  final Set<String> selectedFundIds;
  final Set<String> previousSelectedFundIds;

  // KYC / OTP / misc
  final List<bool> kycStepChecks;
  final String otp;
  final bool isSubmitting;
  final bool otpError;
  final bool otpResent;
  final String? kycUrl;
  final bool kycLoading;
  final String? kycError;
  final bool hasSeenEligibilityResult;
  final bool isRtaOtpVerifying;
  final String? rtaOtpError;
  final String? userMobileNumber;

  EligibilityState copyWith({
    int? majorStep,
    int? pageIndex,
    EligibilityFormData? formData,
    MfDetailsResponse? mfDetailsResponse,
    bool? isLoading,
    String? generalErrorMessage,
    String? panNumberError,
    String? panFullNameError,
    String? panDobError,
    PanVerificationStatus? panStatus,
    PanOtpStatus? otpStatus,
    String? snackbarMessage,
    bool clearSnackbar = false,
    EligibilityOverlayType? currentOverlay,
    LenderSelectionView? lenderSelectionView,
    List<Lender>? lenders,
    String? selectedLenderId,
    bool clearSelectedLender = false,
    bool? isPortfolioRefreshing,
    String? loadingLenderId,
     String? lastSavedLenderId,
  String? lastSaveMessage,

    Map<String, double>? editedLoanAmounts,
    Map<String, bool?>? editLoanResult,
    List<PledgeableFund>? pledgeableFunds,
    Set<String>? selectedFundIds,
    Set<String>? previousSelectedFundIds,
    List<bool>? kycStepChecks,
    String? otp,
    bool? isSubmitting,
    bool? otpError,
    bool? otpResent,
    String? kycUrl,
    bool? kycLoading,
    String? kycError,
    bool? hasSeenEligibilityResult,
    bool? isRtaOtpVerifying,
    String? rtaOtpError,
    String? userMobileNumber,
    bool clearErrors = false,
  }) {
    return EligibilityState(
      majorStep: majorStep ?? this.majorStep,
      pageIndex: pageIndex ?? this.pageIndex,
      formData: formData ?? this.formData,
      mfDetailsResponse: mfDetailsResponse ?? this.mfDetailsResponse,
      generalErrorMessage: clearErrors ? null : (generalErrorMessage ?? this.generalErrorMessage),
      panNumberError: clearErrors ? null : (panNumberError ?? this.panNumberError),
      panFullNameError: clearErrors ? null : (panFullNameError ?? this.panFullNameError),
      panDobError: clearErrors ? null : (panDobError ?? this.panDobError),
      panStatus: panStatus ?? this.panStatus,
      otpStatus: otpStatus ?? this.otpStatus,
      snackbarMessage: clearSnackbar ? null : (snackbarMessage ?? this.snackbarMessage),
      isLoading: isLoading ?? this.isLoading,
      currentOverlay: currentOverlay ?? this.currentOverlay,
      lenderSelectionView: lenderSelectionView ?? this.lenderSelectionView,
lastSavedLenderId: lastSavedLenderId ?? this.lastSavedLenderId,
    lastSaveMessage: lastSaveMessage ?? this.lastSaveMessage,
      lenders: lenders ?? this.lenders,
      selectedLenderId: clearSelectedLender ? null : (selectedLenderId ?? this.selectedLenderId),
      isPortfolioRefreshing: isPortfolioRefreshing ?? this.isPortfolioRefreshing,
      editedLoanAmounts: editedLoanAmounts ?? this.editedLoanAmounts,
      editLoanResult: editLoanResult ?? this.editLoanResult,
      pledgeableFunds: pledgeableFunds ?? this.pledgeableFunds,
      selectedFundIds: selectedFundIds ?? this.selectedFundIds,
      previousSelectedFundIds: previousSelectedFundIds ?? this.previousSelectedFundIds,
      kycStepChecks: kycStepChecks ?? this.kycStepChecks,
      otp: otp ?? this.otp,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      otpError: otpError ?? this.otpError,
      otpResent: otpResent ?? this.otpResent,
      kycUrl: kycUrl ?? this.kycUrl,
      kycLoading: kycLoading ?? this.kycLoading,
      loadingLenderId: loadingLenderId ?? this.loadingLenderId,
      kycError: kycError ?? this.kycError,
      hasSeenEligibilityResult:
          hasSeenEligibilityResult ?? this.hasSeenEligibilityResult,
      isRtaOtpVerifying: isRtaOtpVerifying ?? this.isRtaOtpVerifying,
      rtaOtpError: rtaOtpError ?? this.rtaOtpError,
      userMobileNumber: userMobileNumber ?? this.userMobileNumber,
    );
  }

  // 🔹 Getter for currently selected lender
  Lender? get selectedLender {
    if (selectedLenderId == null) return null;
    try {
      return lenders.firstWhere((l) => l.id == selectedLenderId);
    } catch (_) {
      return null;
    }
  }

  // 🔹 Equatable props
  @override
  List<Object?> get props => [
    majorStep,
    pageIndex,
    formData,
    isLoading,
    generalErrorMessage,
    panNumberError,
    panFullNameError,
    mfDetailsResponse,
    panDobError,
    currentOverlay,
    lenderSelectionView,
    lenders,
    selectedLenderId,
    isPortfolioRefreshing,
    editedLoanAmounts,
    pledgeableFunds,
    selectedFundIds,
    previousSelectedFundIds, // ✅ Added here too
    kycStepChecks,
    editLoanResult,
    otp,
    isSubmitting,
    otpError,
    otpResent,
    panStatus,
    otpStatus,
    snackbarMessage,
    kycUrl,
    kycLoading,
    kycError,
    hasSeenEligibilityResult,
    isRtaOtpVerifying,
    rtaOtpError,
    userMobileNumber,
  ];
}
