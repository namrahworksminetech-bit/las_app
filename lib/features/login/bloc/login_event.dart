part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();
  @override
  List<Object> get props => [];
}

class LoginSendOtpPressed extends LoginEvent {
  final String email;
  final String mobile;
  const LoginSendOtpPressed({required this.email, required this.mobile});
  @override
  List<Object> get props => [email, mobile];
}

class LoginContinuePressed extends LoginEvent {
  final String otp;
  const LoginContinuePressed({required this.otp});
  @override
  List<Object> get props => [otp];
}

class LoginResendOtpPressed extends LoginEvent {}

class LoginSnackbarCleared extends LoginEvent {}
