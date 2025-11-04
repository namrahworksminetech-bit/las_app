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


class PledgeableFund extends Equatable {
  final String id;
  final String name;
  final double value;
  final int units;
  final double perUnitValue;

  const PledgeableFund({
    required this.id,
    required this.name,
    required this.value,
    required this.units,
    required this.perUnitValue,
  });

  @override
  List<Object?> get props => [id];
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

class PortfolioData extends Equatable {
  final double totalValue;
  final double eligibleCreditLimit;
  final double pledgeableFunds;

  const PortfolioData({
    this.totalValue = 0.0,
    this.eligibleCreditLimit = 0.0,
    this.pledgeableFunds = 0.0,
  });

  @override
  List<Object?> get props => [totalValue, eligibleCreditLimit, pledgeableFunds];
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
    this.portfolioData = const PortfolioData(),
    this.isPortfolioRefreshing = false,
    this.editedLoanAmounts = const {},
    this.pledgeableFunds = const [],
    this.selectedFundIds = const {},
    this.kycStepChecks = const [true, true, true, true],
    this.otp = '',
    this.isSubmitting = false,
    this.otpError = false,
    this.otpResent = false,
  });

  final int majorStep;
  final int pageIndex;
  final EligibilityFormData formData;

  final PanVerificationStatus panStatus;
  final PanOtpStatus otpStatus;
  final String? snackbarMessage;

  final String? generalErrorMessage;
  final String? panNumberError;
  final String? panFullNameError;
  final String? panDobError;

  final bool isLoading;
  final EligibilityOverlayType currentOverlay;

  final LenderSelectionView lenderSelectionView;
  final List<Lender> lenders;
  final String? selectedLenderId;
  final PortfolioData portfolioData;
  final bool isPortfolioRefreshing;
  final Map<String, double> editedLoanAmounts;
  final List<PledgeableFund> pledgeableFunds;
  final Set<String> selectedFundIds;
  final List<bool> kycStepChecks;
  final String otp;
  final bool isSubmitting;
  final bool otpError;
  final bool otpResent;

  EligibilityState copyWith({
    int? majorStep,
    int? pageIndex,
    EligibilityFormData? formData,
    bool? isLoading,
    String? generalErrorMessage,
    String? panNumberError,
    String? panFullNameError,
    String? panDobError,
    bool clearErrors = false,
    EligibilityOverlayType? currentOverlay,
    LenderSelectionView? lenderSelectionView,
    List<Lender>? lenders,
    String? selectedLenderId,
    bool clearSelectedLender = false,
    PortfolioData? portfolioData,
    bool? isPortfolioRefreshing,
    Map<String, double>? editedLoanAmounts,
    List<PledgeableFund>? pledgeableFunds,
    Set<String>? selectedFundIds,
    List<bool>? kycStepChecks,
    String? otp,
    bool? isSubmitting,
    bool? otpError,
    bool? otpResent,
    PanVerificationStatus? panStatus,
    PanOtpStatus? otpStatus,
    String? snackbarMessage,
    bool clearSnackbar = false,
  }) {
    return EligibilityState(
      majorStep: majorStep ?? this.majorStep,
      pageIndex: pageIndex ?? this.pageIndex,
      formData: formData ?? this.formData,
      isLoading: isLoading ?? this.isLoading,
      generalErrorMessage:
          clearErrors ? null : generalErrorMessage ?? this.generalErrorMessage,
      panNumberError:
          clearErrors ? null : panNumberError ?? this.panNumberError,
      panFullNameError:
          clearErrors ? null : panFullNameError ?? this.panFullNameError,
      panDobError: clearErrors ? null : panDobError ?? this.panDobError,
      currentOverlay: currentOverlay ?? this.currentOverlay,
      lenderSelectionView: lenderSelectionView ?? this.lenderSelectionView,
      lenders: lenders ?? this.lenders,
      selectedLenderId:
          clearSelectedLender ? null : selectedLenderId ?? this.selectedLenderId,
      portfolioData: portfolioData ?? this.portfolioData,
      isPortfolioRefreshing:
          isPortfolioRefreshing ?? this.isPortfolioRefreshing,
      editedLoanAmounts: editedLoanAmounts ?? this.editedLoanAmounts,
      pledgeableFunds: pledgeableFunds ?? this.pledgeableFunds,
      selectedFundIds: selectedFundIds ?? this.selectedFundIds,
      kycStepChecks: kycStepChecks ?? this.kycStepChecks,
      otp: otp ?? this.otp,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      otpError: otpError ?? this.otpError,
      otpResent: otpResent ?? this.otpResent,
      panStatus: panStatus ?? this.panStatus,
      otpStatus: otpStatus ?? this.otpStatus,
      snackbarMessage:
          clearSnackbar ? null : snackbarMessage ?? this.snackbarMessage,
    );
  }

  @override
  List<Object?> get props => [
        majorStep,
        pageIndex,
        formData,
        isLoading,
        generalErrorMessage,
        panNumberError,
        panFullNameError,
        panDobError,
        currentOverlay,
        lenderSelectionView,
        lenders,
        selectedLenderId,
        portfolioData,
        isPortfolioRefreshing,
        editedLoanAmounts,
        pledgeableFunds,
        selectedFundIds,
        kycStepChecks,
        otp,
        isSubmitting,
        otpError,
        otpResent,
        panStatus,
        otpStatus,
        snackbarMessage,
      ];
}
