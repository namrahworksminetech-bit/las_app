part of 'login_bloc.dart';

enum LoginViewStatus { initial, otpSent }

class LoginState extends Equatable {
  const LoginState({
    this.viewStatus = LoginViewStatus.initial,
    this.isLoading = false,
    this.mobileError,
    this.otpError,
    this.snackbarMessage,
    this.pledgeStatus,

    this.token,
    this.otpRef,

    this.mobileLiveError,
    this.isLoginOtpVisible = false,
  });

  final LoginViewStatus viewStatus;
  final bool isLoading;
  final String? mobileError;
  final String? pledgeStatus;
  final String? otpError;
  final String? snackbarMessage;
  final String? token;
  final String? otpRef;

  final String? mobileLiveError;
  final bool isLoginOtpVisible;

  LoginState copyWith({
    LoginViewStatus? viewStatus,
    bool? isLoading,
    String? mobileError,
    String? otpError,
    String? snackbarMessage,
    String? pledgeStatus,
    String? token,

    String? otpRef,
    bool clearSnackbar = false,
    String? emailLiveError,
    String? mobileLiveError,
    bool? isLoginOtpVisible,
  }) {
    return LoginState(
      viewStatus: viewStatus ?? this.viewStatus,
      isLoading: isLoading ?? this.isLoading,
      mobileError: mobileError,
      pledgeStatus: pledgeStatus ?? this.pledgeStatus,
      otpError: otpError,
      snackbarMessage: clearSnackbar
          ? null
          : snackbarMessage ?? this.snackbarMessage,
      token: token ?? this.token,
      otpRef: otpRef ?? this.otpRef,
    
      mobileLiveError: mobileLiveError ?? this.mobileLiveError,
      isLoginOtpVisible: isLoginOtpVisible ?? this.isLoginOtpVisible,
    );
  }

  @override
  List<Object?> get props => [
    viewStatus,
    isLoading,
    mobileError,
    otpError,

    snackbarMessage,
    pledgeStatus,
    token,
    otpRef,
 
    mobileLiveError,
    isLoginOtpVisible,
  ];
}
