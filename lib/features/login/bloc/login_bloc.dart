import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(const LoginState()) {
    on<LoginSendOtpPressed>(_onSendOtpPressed);
    on<LoginContinuePressed>(_onContinuePressed);
    on<LoginResendOtpPressed>(_onResendOtpPressed);
    on<LoginSnackbarCleared>(_onSnackbarCleared);
  }

  Future<void> _onSendOtpPressed(
    LoginSendOtpPressed event,
    Emitter<LoginState> emit,
  ) async {
    String? emailError;
    String? mobileError;

    if (event.email.isEmpty || !event.email.contains('@')) {
      emailError = 'Please enter a valid email address.';
    }
    if (event.mobile.isEmpty || event.mobile.length < 10) {
      mobileError = 'Please enter a valid 10-digit mobile number.';
    }

    if (emailError != null || mobileError != null) {
      emit(state.copyWith(emailError: emailError, mobileError: mobileError));
      return;
    }

    emit(state.copyWith(isLoading: true, emailError: null, mobileError: null));

    await Future.delayed(const Duration(seconds: 1));
    bool success = true;

    if (success) {
      emit(
        state.copyWith(
          isLoading: false,
          viewStatus: LoginViewStatus.otpSent,
          snackbarMessage: 'OTP sent successfully!',
        ),
      );
    } else {
      emit(
        state.copyWith(
          isLoading: false,
          snackbarMessage: 'Failed to send OTP. Please try again.',
        ),
      );
    }
  }

  Future<void> _onContinuePressed(
    LoginContinuePressed event,
    Emitter<LoginState> emit,
  ) async {
    if (event.otp.length != 6) {
      emit(
        state.copyWith(
          otpError: 'OTP must be 6 digits.',
          snackbarMessage: 'Please enter a valid 6-digit OTP.',
        ),
      );
      return;
    }

    emit(state.copyWith(isLoading: true, otpError: null));

    await Future.delayed(const Duration(seconds: 1));
    bool success = event.otp == "123456";

    if (success) {
      emit(
        state.copyWith(isLoading: false, snackbarMessage: 'Login Successful!'),
      );
    } else {
      emit(
        state.copyWith(
          isLoading: false,
          otpError: 'Invalid OTP. Please try again.',
          snackbarMessage: 'Invalid OTP. Please try again.',
        ),
      );
    }
  }

  Future<void> _onResendOtpPressed(
    LoginResendOtpPressed event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    await Future.delayed(const Duration(seconds: 1));
    emit(
      state.copyWith(isLoading: false, snackbarMessage: 'OTP has been resent.'),
    );
  }

  void _onSnackbarCleared(
    LoginSnackbarCleared event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(clearSnackbar: true));
  }
}
