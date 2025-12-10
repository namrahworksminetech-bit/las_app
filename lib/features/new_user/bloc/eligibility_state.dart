part of 'eligibility_bloc.dart';

enum InvestmentType { insurancePolicy, mutualFund, shares, none }

enum PanVerificationStatus { initial, verifying, verified, failed }

enum PanOtpStatus { initial, sending, sent, verified, failed }

enum EligibilityOverlayType { none, fetchingPortfolio, eligibilityResult }

enum LenderSelectionView {
  lenderList,
  portfolioBreakdown,
  pledgeableDetail,
  nonPledgeableDetail, // NEW
  dematDetail, // NEW
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
  final double maxEligibleLimit;

  const Lender({
    required this.id,
    required this.name,
    required this.logoAsset,
    required this.interestRate,
    required this.loanAmount,
    required this.pledgeableMFs,
    required this.tag,
    required this.maxEligibleLimit,
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
    double? maxEligibleLimit,
  }) {
    return Lender(
      id: id ?? this.id,
      name: name ?? this.name,
      logoAsset: logoAsset ?? this.logoAsset,
      interestRate: interestRate ?? this.interestRate,
      loanAmount: loanAmount ?? this.loanAmount,
      maxEligibleLimit: maxEligibleLimit ?? this.maxEligibleLimit,
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
    this.panEmail,
  });

  final InvestmentType investmentType;
  final String? panNumber;
  final String? panFullName;
  final String? panDob;
  final String? panEmail;
  EligibilityFormData copyWith({
    InvestmentType? investmentType,
    String? panNumber,
    String? panFullName,
    String? panDob,
    String? panEmail,
  }) {
    return EligibilityFormData(
      investmentType: investmentType ?? this.investmentType,
      panNumber: panNumber ?? this.panNumber,
      panFullName: panFullName ?? this.panFullName,
      panDob: panDob ?? this.panDob,
      panEmail: panEmail ?? this.panEmail,
    );
  }

  @override
  List<Object?> get props => [
    investmentType,
    panNumber,
    panFullName,
    panDob,
    panEmail,
  ];
}

class EligibilityState extends Equatable {
  const EligibilityState({
    this.isOtpVisible = false,
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
    this.isEditingLoan = false,
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
    this.shouldNavigateToKyc = false,
    this.loadingLenderId,
    this.otpError = false,
    this.otpResent = false,
    this.kycUrl,
    this.kycLoading = false,
    this.kycError,
    this.hasSeenEligibilityResult = false,
    this.isRtaOtpVerifying = false,
    this.pledgeStatus,
    this.editedFundAmounts = const {},
    this.isStep2Loading = false,
    this.rtaOtpError,
    this.redirectToKycAfterFetch = false,
    this.userMobileNumber,
    this.pledgeMfResponse,
    this.savingLenderId,
    this.isSavingLoan = false,
    this.fundsToAdd = const [], // <-- ADD THIS
    this.fundsToRemove = const [],

    this.isShareUploading = false,
    this.isShareSubmitting = false,
    this.shareUploadPath,
    this.shareError,
    this.shareSuccess = false,

    this.insuranceCompanies = const [],
    this.selectedInsuranceCode,
    this.selectedInsuranceName,
    this.unitStatementPath,
    this.policyDocumentPath,
    this.isUnitUploading = false,
    this.isPolicyUploading = false,
    this.isInsuranceSubmitting = false,
    this.insuranceSuccess = false,
    this.insuranceError,
    this.insurers = const [],
    this.insurerCode,
    this.insurancePolicyNo,
    this.insuranceName,
    this.insuranceDob,
    this.unitKey,
    this.policyKey,
    this.isFetchingInsurers = false,
    this.isUploadingUnit = false,
    this.isUploadingPolicy = false,
    this.isSubmittingInsurance = false,
    this.kycSteps = const [],
    this.currentKycStatus,
    this.hasTriggeredDigio = false,
    this.panLiveError,

    this.currentStepName,
    this.isPennyDropPolling = false,
    this.shouldNavigateToOtp = false,
    this.pledgeOtpSubmitting = false,
    this.pledgeChecked = false,
    this.pledgePhoneNumber,
    this.hasUnsavedFundChanges = false,
    this.panEmail,
    this.panEmailError,
 
this.pledgeOtp = '',
this.pledgeOtpError,
this.agreedToTerms = false,

  this.lastEditedFundCode,
  this.lastEditedFundAmount,
  });
  final bool agreedToTerms;
  final String? lastEditedFundCode;
final double? lastEditedFundAmount;

  final bool pledgeChecked;
final String? pledgePhoneNumber;

final String pledgeOtp;
final String? pledgeOtpError;

  final String? panLiveError;
  final bool isOtpVisible;
  final bool hasUnsavedFundChanges;

  final String? panEmail;
  final String? panEmailError;

  final List<Map<String, dynamic>> insurers; // dropdown list
  final String? insurerCode; // selected code
  final String? insurancePolicyNo;
  final String? insuranceName;
  final String? insuranceDob;

  /// ================= INSURANCE UPLOAD KEYS =============
  final String? unitKey; // unit_statement_path
  final String? policyKey;
  final bool isFetchingInsurers;
  final bool isUploadingUnit;
  final bool isUploadingPolicy;
  final bool isSubmittingInsurance;

  final String? insuranceError;
  final bool insuranceSuccess;

  final bool isSavingLoan;
  final List<PledgeableFund> fundsToAdd;
  final List<PledgeableFund> fundsToRemove;
  // Core fields
  final int majorStep;
  final int pageIndex;
  final bool isStep2Loading;
  final bool redirectToKycAfterFetch;
  final Map<String, double> editedFundAmounts;

  final String? savingLenderId;
  final bool shouldNavigateToKyc;
  final bool isEditingLoan;
  final PledgeMfResponse? pledgeMfResponse;

  final EligibilityFormData formData;
  final MfDetailsResponse? mfDetailsResponse;

  // New: lender-specific edit results: lenderId -> true/false/null
  final Map<String, bool?> editLoanResult;
  final String? pledgeStatus;

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

  final bool isShareUploading;
  final bool isShareSubmitting;
  final String? shareUploadPath;
  final String? shareError;
  final bool shareSuccess;

  final List<Map<String, dynamic>> insuranceCompanies;

  final String? selectedInsuranceCode;
  final String? selectedInsuranceName;

  final String? unitStatementPath;
  final String? policyDocumentPath;

  final bool isUnitUploading;
  final bool isPolicyUploading;
  final bool isInsuranceSubmitting;

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
  final List<String> kycSteps;
  final String? currentKycStatus;
  final bool hasTriggeredDigio;
  final String? currentStepName;
  final bool isPennyDropPolling;
  final bool shouldNavigateToOtp;
  final bool pledgeOtpSubmitting;


  EligibilityState copyWith({
    bool? isOtpVisible,
    bool? hasUnsavedFundChanges,

    String? panLiveError,
    List<Map<String, dynamic>>? insurers,
    String? insurerCode,
    String? insurancePolicyNo,
    String? insuranceName,
    String? insuranceDob,
    String? unitKey,
    String? policyKey,
    bool? isFetchingInsurers,
    bool? isUploadingUnit,
    bool? isUploadingPolicy,
    bool? isSubmittingInsurance,
    String? insuranceError,
    bool? insuranceSuccess,
    int? majorStep,
    int? pageIndex,
    EligibilityFormData? formData,
    bool? isSavingLoan,
    MfDetailsResponse? mfDetailsResponse,
    bool? isLoading,
    String? generalErrorMessage,
    String? panNumberError,
    String? panFullNameError,
    String? panDobError,
    Map<String, double>? editedFundAmounts,
    PanVerificationStatus? panStatus,
bool? agreedToTerms,

    bool? isStep2Loading,
    String? savingLenderId,
    PanOtpStatus? otpStatus,
    String? snackbarMessage,
    bool? shouldNavigateToKyc,
    PledgeMfResponse? pledgeMfResponse,
    bool clearSnackbar = false,
    EligibilityOverlayType? currentOverlay,
    LenderSelectionView? lenderSelectionView,
    String? pledgeStatus,

    List<Lender>? lenders,
    String? selectedLenderId,
    bool clearSelectedLender = false,
    bool? isPortfolioRefreshing,
    String? loadingLenderId,
    bool? redirectToKycAfterFetch,

    String? lastSavedLenderId,
    String? lastSaveMessage,

    Map<String, double>? editedLoanAmounts,
    Map<String, bool?>? editLoanResult,
    List<PledgeableFund>? pledgeableFunds,
    Set<String>? selectedFundIds,
    Set<String>? previousSelectedFundIds,
    List<bool>? kycStepChecks,
    String? otp,
    isEditingLoan = false,
    List<PledgeableFund>? fundsToAdd,
    List<PledgeableFund>? fundsToRemove,

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
    List<String>? kycSteps,
    String? currentKycStatus,
    bool? hasTriggeredDigio,
    String? currentStepName,
    bool? isPennyDropPolling,
    bool? shouldNavigateToOtp,
    bool? pledgeOtpSubmitting,
    bool? pledgeChecked,
    String? pledgePhoneNumber,
    bool clearErrors = false,

    bool? isShareUploading,
    bool? isShareSubmitting,
    String? shareUploadPath,
    String? shareError,
    bool? shareSuccess,

    List<Map<String, dynamic>>? insuranceCompanies,
    String? selectedInsuranceCode,
    String? selectedInsuranceName,
    String? unitStatementPath,
    String? policyDocumentPath,
    bool? isUnitUploading,
    bool? isPolicyUploading,
    bool? isInsuranceSubmitting,
    String? panEmail,
    String? panEmailError,
    String? pledgeOtp,
String? pledgeOtpError,
  String? lastEditedFundCode,
  double? lastEditedFundAmount,
  }) {
    return EligibilityState(
         lastEditedFundCode: lastEditedFundCode ?? this.lastEditedFundCode,
    lastEditedFundAmount: lastEditedFundAmount ?? this.lastEditedFundAmount,
      pledgeOtp: pledgeOtp ?? this.pledgeOtp,
pledgeOtpError: pledgeOtpError ?? this.pledgeOtpError,
agreedToTerms: agreedToTerms ?? this.agreedToTerms,

      panLiveError: panLiveError ?? this.panLiveError,
      isOtpVisible: isOtpVisible ?? this.isOtpVisible,
      hasUnsavedFundChanges:
          hasUnsavedFundChanges ?? this.hasUnsavedFundChanges,

      insurers: insurers ?? this.insurers,
      insurerCode: insurerCode ?? this.insurerCode,
      insurancePolicyNo: insurancePolicyNo ?? this.insurancePolicyNo,
      insuranceName: insuranceName ?? this.insuranceName,
      insuranceDob: insuranceDob ?? this.insuranceDob,
      unitKey: unitKey ?? this.unitKey,
      policyKey: policyKey ?? this.policyKey,
      isFetchingInsurers: isFetchingInsurers ?? this.isFetchingInsurers,
      isUploadingUnit: isUploadingUnit ?? this.isUploadingUnit,
      isUploadingPolicy: isUploadingPolicy ?? this.isUploadingPolicy,
      isSubmittingInsurance:
          isSubmittingInsurance ?? this.isSubmittingInsurance,
      insuranceError: insuranceError,
      insuranceSuccess: insuranceSuccess ?? this.insuranceSuccess,
      majorStep: majorStep ?? this.majorStep,
      pageIndex: pageIndex ?? this.pageIndex,
      formData: formData ?? this.formData,
      isSavingLoan: isSavingLoan ?? this.isSavingLoan,
      pledgeStatus: pledgeStatus ?? this.pledgeStatus,
      savingLenderId: savingLenderId ?? this.savingLenderId,
      mfDetailsResponse: mfDetailsResponse ?? this.mfDetailsResponse,
      generalErrorMessage: clearErrors
          ? null
          : (generalErrorMessage ?? this.generalErrorMessage),
      panNumberError: clearErrors
          ? null
          : (panNumberError ?? this.panNumberError),
      panFullNameError: clearErrors
          ? null
          : (panFullNameError ?? this.panFullNameError),
      panDobError: clearErrors ? null : (panDobError ?? this.panDobError),
      panStatus: panStatus ?? this.panStatus,
      isEditingLoan: isEditingLoan ?? this.isEditingLoan,
      isStep2Loading: isStep2Loading ?? this.isStep2Loading,
      editedFundAmounts: editedFundAmounts ?? this.editedFundAmounts,
      fundsToAdd: fundsToAdd ?? this.fundsToAdd, // <-- ADD
      fundsToRemove: fundsToRemove ?? this.fundsToRemove,
      redirectToKycAfterFetch:
          redirectToKycAfterFetch ?? this.redirectToKycAfterFetch,
      pledgeMfResponse: pledgeMfResponse ?? this.pledgeMfResponse,
      otpStatus: otpStatus ?? this.otpStatus,
      snackbarMessage: clearSnackbar
          ? null
          : (snackbarMessage ?? this.snackbarMessage),
      isLoading: isLoading ?? this.isLoading,
      currentOverlay: currentOverlay ?? this.currentOverlay,
      lenderSelectionView: lenderSelectionView ?? this.lenderSelectionView,
      lastSavedLenderId: lastSavedLenderId ?? this.lastSavedLenderId,
      lastSaveMessage: lastSaveMessage ?? this.lastSaveMessage,
      lenders: lenders ?? this.lenders,
      selectedLenderId: clearSelectedLender
          ? null
          : (selectedLenderId ?? this.selectedLenderId),
      isPortfolioRefreshing:
          isPortfolioRefreshing ?? this.isPortfolioRefreshing,
      editedLoanAmounts: editedLoanAmounts ?? this.editedLoanAmounts,
      editLoanResult: editLoanResult ?? this.editLoanResult,
      pledgeableFunds: pledgeableFunds ?? this.pledgeableFunds,
      shouldNavigateToKyc: shouldNavigateToKyc ?? this.shouldNavigateToKyc,

      selectedFundIds: selectedFundIds ?? this.selectedFundIds,
      previousSelectedFundIds:
          previousSelectedFundIds ?? this.previousSelectedFundIds,
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
      kycSteps: kycSteps ?? this.kycSteps,
      currentKycStatus: currentKycStatus ?? this.currentKycStatus,
      hasTriggeredDigio: hasTriggeredDigio ?? this.hasTriggeredDigio,
      currentStepName: currentStepName ?? this.currentStepName,
      isPennyDropPolling: isPennyDropPolling ?? this.isPennyDropPolling,
      shouldNavigateToOtp: shouldNavigateToOtp ?? this.shouldNavigateToOtp,
      pledgeOtpSubmitting: pledgeOtpSubmitting ?? this.pledgeOtpSubmitting,
      pledgeChecked: pledgeChecked ?? this.pledgeChecked,
      pledgePhoneNumber: pledgePhoneNumber ?? this.pledgePhoneNumber,
      isShareUploading: isShareUploading ?? this.isShareUploading,
      isShareSubmitting: isShareSubmitting ?? this.isShareSubmitting,
      shareUploadPath: clearErrors
          ? null
          : (shareUploadPath ?? this.shareUploadPath),
      shareError: clearErrors ? null : (shareError ?? this.shareError),
      shareSuccess: shareSuccess ?? this.shareSuccess,
      insuranceCompanies: insuranceCompanies ?? this.insuranceCompanies,
      selectedInsuranceCode:
          selectedInsuranceCode ?? this.selectedInsuranceCode,
      selectedInsuranceName:
          selectedInsuranceName ?? this.selectedInsuranceName,
      unitStatementPath: unitStatementPath ?? this.unitStatementPath,
      policyDocumentPath: policyDocumentPath ?? this.policyDocumentPath,
      isUnitUploading: isUnitUploading ?? this.isUnitUploading,
      isPolicyUploading: isPolicyUploading ?? this.isPolicyUploading,
      isInsuranceSubmitting:
          isInsuranceSubmitting ?? this.isInsuranceSubmitting,
      panEmail: panEmail ?? this.panEmail,
      panEmailError: panEmailError,
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
    isStep2Loading,
    editedFundAmounts,
    pageIndex,
    formData,
    isSavingLoan,
    pledgeStatus,
    isShareUploading,
    isShareSubmitting,
    shareUploadPath,
    shareError,
    shareSuccess,
    lastEditedFundCode, lastEditedFundAmount, 

    pledgeOtpSubmitting,
pledgeChecked,
pledgePhoneNumber,
pledgeOtp,
pledgeOtpError,


    // ===== INSURANCE FLOW =====
    insurers, // list of companies
    insurerCode, // selected code
    insurancePolicyNo,
    insuranceName,
    insuranceDob,

    unitKey, // uploaded unit doc
    policyKey, // uploaded policy doc

    isFetchingInsurers,
    isUploadingUnit,
    isUploadingPolicy,
    isSubmittingInsurance,

    insuranceError,
    insuranceSuccess,

    isLoading,
    generalErrorMessage,
    panNumberError,
    panFullNameError,
    mfDetailsResponse,
    redirectToKycAfterFetch,
    panDobError,
    savingLenderId,
    currentOverlay,
    lenderSelectionView,
    lenders,
    shouldNavigateToKyc,
    selectedLenderId,
    pledgeMfResponse,
    isPortfolioRefreshing,
    fundsToAdd, // <-- ADD
    fundsToRemove,
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
    agreedToTerms,

    kycUrl,
    kycLoading,
    kycError,
    hasSeenEligibilityResult,
    isRtaOtpVerifying,
    rtaOtpError,
    userMobileNumber,
    kycSteps,
    currentKycStatus,
    hasTriggeredDigio,
    currentStepName,
    isPennyDropPolling,
    shouldNavigateToOtp,
    pledgeOtpSubmitting,
    pledgeChecked,
    pledgePhoneNumber,
    isShareUploading,
    isShareSubmitting,
    shareUploadPath,
    shareError,
    shareSuccess,
    panLiveError,
    isOtpVisible,
    hasUnsavedFundChanges,
    panEmail,
    panEmailError,
  ];
}
