part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

class LoginSendOtpPressed extends LoginEvent {
  final String mobile;
  const LoginSendOtpPressed({required this.mobile});

  @override
  List<Object?> get props => [mobile];
}
class LoginToggleOtpVisibility extends LoginEvent {}

class LoginEmailUpdated extends LoginEvent {
  final String email;
  LoginEmailUpdated(this.email);
}

class LoginMobileUpdated extends LoginEvent {
  final String mobile;
  LoginMobileUpdated(this.mobile);
}


class LoginVerifyOtpPressed extends LoginEvent {
  final String mobile;
  final String otpRef;
  final String otp;


  const LoginVerifyOtpPressed({
    required this.mobile,
    required this.otpRef,
    required this.otp,

  });

  @override
  List<Object?> get props => [mobile, otpRef, otp];
}


class LoginResendOtpPressed extends LoginEvent {
  final String mobile;
  const LoginResendOtpPressed({required this.mobile});

  @override
  List<Object?> get props => [mobile];
}

class LoginSnackbarCleared extends LoginEvent {}
