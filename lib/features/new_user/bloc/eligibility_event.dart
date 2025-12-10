part of 'eligibility_bloc.dart';

abstract class EligibilityEvent extends Equatable {
  const EligibilityEvent();
  @override
  List<Object?> get props => [];
}


class PanValidationError extends EligibilityEvent {
  final String message;
  const PanValidationError(this.message);
}

class PanValidationErrorCleared extends EligibilityEvent {
  const PanValidationErrorCleared();
}



class InvestmentTypeUpdated extends EligibilityEvent {
  final InvestmentType type;
  const InvestmentTypeUpdated(this.type);
  @override
  List<Object?> get props => [type];
}

class ToggleKycStep extends EligibilityEvent {
  final int index;
  const ToggleKycStep(this.index);

  @override
  List<Object?> get props => [index];
}
class ToggleOtpVisibility extends EligibilityEvent {}

class PanNumberUpdated extends EligibilityEvent {
  final String pan;
  const PanNumberUpdated(this.pan);
  @override
  List<Object?> get props => [pan];
}

class PanFullNameUpdated extends EligibilityEvent {
  final String fullName;
  const PanFullNameUpdated(this.fullName);
  @override
  List<Object?> get props => [fullName];
}

// 🚀 INSURANCE FLOW EVENTS

/// 1️⃣ Fetch insurer list API
class FetchInsurers extends EligibilityEvent {}

/// 2️⃣ Store selected insurer + Step-1 form fields
class SaveInsuranceForm extends EligibilityEvent {
  final String insurerCode;
  final String policyNumber;
  final String name;
  final String dob;

  SaveInsuranceForm({
    required this.insurerCode,
    required this.policyNumber,
    required this.name,
    required this.dob,
  });
}

/// 3️⃣ Upload Unit Statement
class UploadUnitStatement extends EligibilityEvent {
  final Uint8List fileBytes;
  final String mimeType;
  final String fileType;   // like "pdf", "jpg"
  UploadUnitStatement({required this.fileBytes, required this.mimeType, required this.fileType});
}

/// 4️⃣ Upload Policy Bond
class UploadPolicyBond extends EligibilityEvent {
  final Uint8List fileBytes;
  final String mimeType;
  final String fileType;
  UploadPolicyBond({required this.fileBytes, required this.mimeType, required this.fileType});
}

/// 5️⃣ Final submit event
class SubmitInsuranceDetails extends EligibilityEvent {}

class PanDobUpdated extends EligibilityEvent {
  final String dob;
  const PanDobUpdated(this.dob);
  @override
  List<Object?> get props => [dob];
}

class FetchStep2Data extends EligibilityEvent {}

class LenderSelected extends EligibilityEvent {
  final String? lenderId;
  const LenderSelected(this.lenderId);
  @override
  List<Object?> get props => [lenderId];
}

class ViewDetailsToggled extends EligibilityEvent {}

class RefreshPortfolioPressed extends EligibilityEvent {}

class BreakdownCategoryTapped extends EligibilityEvent {
  final String categoryId;
  const BreakdownCategoryTapped(this.categoryId);
  @override
  List<Object?> get props => [categoryId];
}

// eligibility_event.dart
class EditLoanAmountPressed extends EligibilityEvent {
  final String reqId;
  final double loanAmount;
  final String lenderId;

  const EditLoanAmountPressed({
    required this.reqId,
    required this.loanAmount,
    required this.lenderId,
  });
}



class UploadHoldingFile extends EligibilityEvent {
  final Uint8List fileBytes;
  final String mimeType;
  final String fileType; // 👈 NEW

  UploadHoldingFile({
    required this.fileBytes,
    required this.mimeType,
    required this.fileType,
  });

  @override
  List<Object?> get props => [fileBytes, mimeType, fileType];
}


class SubmitShareDetails extends EligibilityEvent {
  final String broker;
  final String dpId;

  SubmitShareDetails({
    required this.broker,
    required this.dpId,
  });
}

// new event
class ConfirmFundSelectionWithFunds extends EligibilityEvent {
  final List<PledgeableFund> fundsToAdd;
  final List<PledgeableFund> fundsToRemove;
  final String lenderId;

  ConfirmFundSelectionWithFunds({
    required this.fundsToAdd,
    required this.fundsToRemove,
    required this.lenderId,
  });
}


class SaveEditedLoanAmount extends EligibilityEvent {
  final String lenderId;
  final double amount;
  const SaveEditedLoanAmount(this.lenderId, this.amount);
  @override
  List<Object?> get props => [lenderId, amount];
}
class UpdateEditedFundAmount extends EligibilityEvent {
  final String fundCode; // key
  final double amount;

  UpdateEditedFundAmount(this.fundCode, this.amount);
}

class LenderContinuePressed extends EligibilityEvent {
  final String lenderId;
  const LenderContinuePressed(this.lenderId);

  @override
  List<Object?> get props => [lenderId];
}

class AutoSelectAllFunds extends EligibilityEvent {
  final Set<String> fundIds;
  AutoSelectAllFunds(this.fundIds);
}

class ToggleFundSelection extends EligibilityEvent {
  final String fundId;
  const ToggleFundSelection(this.fundId);
  @override
  List<Object?> get props => [fundId];
}

// eligibility_event.dart (add this)
class SetLenderSelectionView extends EligibilityEvent {
  final LenderSelectionView view;
  const SetLenderSelectionView(this.view);
}

class StartFetchingFromLogin extends EligibilityEvent {
  const StartFetchingFromLogin();
}

class ConfirmFundSelection extends EligibilityEvent {
  const ConfirmFundSelection();
}

class UpdateFundAmount extends EligibilityEvent {
  final String fundCode;
  final double amount;

  const UpdateFundAmount(this.fundCode, this.amount);

  @override
  List<Object?> get props => [fundCode, amount];
}

class PanEmailUpdated extends EligibilityEvent {
  final String email;
  PanEmailUpdated(this.email);
}

class JumpToPage extends EligibilityEvent {
  final int pageIndex;
  const JumpToPage(this.pageIndex);
}
class AcknowledgeKycNavigation extends EligibilityEvent {}


class ProceedToLenderSelection extends EligibilityEvent {}

class NextStepPressed extends EligibilityEvent {}

class PreviousStepPressed extends EligibilityEvent {
   const PreviousStepPressed();
}

class ErrorMessageCleared extends EligibilityEvent {}

class OtpChanged extends EligibilityEvent {
  final String otp;
  const OtpChanged(this.otp);

  @override
  List<Object?> get props => [otp];
}

class VerifyPanPressed extends EligibilityEvent {
  final String pan;
  final String dob;
  final String name;
  final String email;

  VerifyPanPressed({
    required this.pan,
    required this.dob,
    required this.name,
    required this.email,
  });
}

class SendPanOtpPressed extends EligibilityEvent {
  // no args required — repo will use AppStateProvider.reqId
  const SendPanOtpPressed();

  @override
  List<Object?> get props => [];
}

/// Step 3
class VerifyPanOtpPressed extends EligibilityEvent {
  final String otp;

  const VerifyPanOtpPressed({required this.otp});

  @override
  List<Object?> get props => [otp];
}

/// Snackbar clear
class EligibilitySnackbarCleared extends EligibilityEvent {}

class SubmitOtp extends EligibilityEvent {
  const SubmitOtp();

  @override
  List<Object?> get props => [];
}

class ResendOtp extends EligibilityEvent {
  const ResendOtp();

  @override
  List<Object?> get props => [];
}

// events.dart
class ClearSnackbar extends EligibilityEvent {
  const ClearSnackbar();
}


class StartKycEvent extends EligibilityEvent {
  final String reqId;
  final String lenderCode;
  final double latitude;
  final double longitude;
  final BuildContext context;

  const StartKycEvent({
    required this.reqId,
    required this.lenderCode,
    required this.latitude,
    required this.longitude,
    required this.context,
  });

  @override
  List<Object> get props => [reqId, lenderCode, latitude, longitude];
}

class UpdateKycStep extends EligibilityEvent {
  final int stepIndex;
  final bool isCompleted;

  const UpdateKycStep(this.stepIndex, this.isCompleted);

  @override
  List<Object> get props => [stepIndex, isCompleted];
}

class UpdateKycStepsReset extends EligibilityEvent {
  const UpdateKycStepsReset();

  @override
  List<Object> get props => [];
}

class UpdateKycStepsAll extends EligibilityEvent {
  final List<bool> steps;

  const UpdateKycStepsAll(this.steps);

  @override
  List<Object> get props => [steps];
}

class MarkEligibilityResultSeen extends EligibilityEvent {
  const MarkEligibilityResultSeen();

  @override
  List<Object> get props => [];
}

class VerifyRtaOtp extends EligibilityEvent {
  final String phone;
  final String rta;
  final String otp;
  final String refNo;

  const VerifyRtaOtp({
    required this.phone,
    required this.rta,
    required this.otp,
    this.refNo = '',
  });

  @override
  List<Object> get props => [phone, rta, otp, refNo];
}

class SetUserMobileNumber extends EligibilityEvent {
  final String mobileNumber;

  const SetUserMobileNumber(this.mobileNumber);

  @override
  List<Object> get props => [mobileNumber];
}

class StartDigioKyc extends EligibilityEvent {
  final String reqId;
  final BuildContext? context;

  const StartDigioKyc({
    required this.reqId,
    this.context,
  });

  @override
  List<Object?> get props => [reqId, context];
}

class DigioKycCompleted extends EligibilityEvent {
  const DigioKycCompleted();

  @override
  List<Object> get props => [];
}

class DigioKycFailed extends EligibilityEvent {
  final String error;

  const DigioKycFailed(this.error);

  @override
  List<Object> get props => [error];
}

class CheckPledgeStatus extends EligibilityEvent {
  final BuildContext? context;
  const CheckPledgeStatus({this.context});
  
  @override
  List<Object?> get props => [context];
}

class RequestLocationAndStartKyc extends EligibilityEvent {
  final BuildContext context;

  const RequestLocationAndStartKyc({required this.context});

  @override
  List<Object> get props => [];
}

class KycStepTapped extends EligibilityEvent {
  final int stepIndex;
  final BuildContext context;

  const KycStepTapped({
    required this.stepIndex,
    required this.context,
  });

  @override
  List<Object> get props => [stepIndex];
}

class PennyDropPollingCompleted extends EligibilityEvent {
  const PennyDropPollingCompleted();

  @override
  List<Object> get props => [];
}

class NavigateToNextScreen extends EligibilityEvent {
  const NavigateToNextScreen();

  @override
  List<Object> get props => [];
}

class FetchPledgePhoneNumber extends EligibilityEvent {
  const FetchPledgePhoneNumber();

  @override
  List<Object> get props => [];
}
class PledgeOtpChanged extends EligibilityEvent {
  final String otp;
  const PledgeOtpChanged(this.otp);

  @override
  List<Object> get props => [otp];
}
class TermsAgreementToggled extends EligibilityEvent {
  final bool agreed;
  const TermsAgreementToggled(this.agreed);

  @override
  List<Object?> get props => [agreed];
}

class SubmitPledgeOtp extends EligibilityEvent {
  final String otp;
  final String phone;

  const SubmitPledgeOtp({required this.otp, required this.phone});

  @override
  List<Object> get props => [otp, phone];
}
