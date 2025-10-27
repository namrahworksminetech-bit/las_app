part of 'login_bloc.dart';

enum LoginViewStatus { initial, otpSent }

class LoginState extends Equatable {
  const LoginState({
    this.viewStatus = LoginViewStatus.initial,
    this.isLoading = false,
    this.emailError,
    this.mobileError,
    this.otpError,
    this.snackbarMessage,
  });

  final LoginViewStatus viewStatus;
  final bool isLoading;
  final String? emailError;
  final String? mobileError;
  final String? otpError;
  final String? snackbarMessage;

  LoginState copyWith({
    LoginViewStatus? viewStatus,
    bool? isLoading,
    String? emailError,
    String? mobileError,
    String? otpError,
    String? snackbarMessage,
    bool clearSnackbar = false,
  }) {
    return LoginState(
      viewStatus: viewStatus ?? this.viewStatus,
      isLoading: isLoading ?? this.isLoading,
      emailError: emailError,
      mobileError: mobileError,
      otpError: otpError,
      snackbarMessage: clearSnackbar
          ? null
          : snackbarMessage ?? this.snackbarMessage,
    );
  }

  @override
  List<Object?> get props => [
    viewStatus,
    isLoading,
    emailError,
    mobileError,
    otpError,
    snackbarMessage,
  ];
}
