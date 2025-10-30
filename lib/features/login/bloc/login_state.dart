part of 'login_bloc.dart';

enum LoginViewStatus { initial, otpSent }

class LoginState extends Equatable {
  const LoginState({
    this.viewStatus = LoginViewStatus.initial,
    this.isLoading = false,
    this.mobileError,
    this.otpError,
    this.snackbarMessage,
    this.token,
    this.otpRef,
  });

  final LoginViewStatus viewStatus;
  final bool isLoading;
  final String? mobileError;
  final String? otpError;
  final String? snackbarMessage;
  final String? token;
  final String? otpRef;

  LoginState copyWith({
    LoginViewStatus? viewStatus,
    bool? isLoading,
    String? mobileError,
    String? otpError,
    String? snackbarMessage,
    String? token,
    String? otpRef,
    bool clearSnackbar = false,
  }) {
    return LoginState(
      viewStatus: viewStatus ?? this.viewStatus,
      isLoading: isLoading ?? this.isLoading,
      mobileError: mobileError,
      otpError: otpError,
      snackbarMessage:
      clearSnackbar ? null : snackbarMessage ?? this.snackbarMessage,
      token: token ?? this.token,
      otpRef: otpRef ?? this.otpRef,
    );
  }

  @override
  List<Object?> get props => [
    viewStatus,
    isLoading,
    mobileError,
    otpError,
    snackbarMessage,
    token,
    otpRef,
  ];
}
