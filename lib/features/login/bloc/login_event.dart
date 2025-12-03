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

class LoginVerifyOtpPressed extends LoginEvent {
  final String mobile;
  final String otpRef;
  final String otp;
  final String email;

  const LoginVerifyOtpPressed({
    required this.mobile,
    required this.otpRef,
    required this.otp,
    required this.email,
  });

  @override
  List<Object?> get props => [mobile, otpRef, otp, email];
}


class LoginResendOtpPressed extends LoginEvent {
  const LoginResendOtpPressed();
}

class LoginSnackbarCleared extends LoginEvent {}
