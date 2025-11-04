import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:las_app/core/app_state_provider.dart';
import 'package:las_app/core/injection_container.dart';
import 'package:las_app/features/new_user/repository/pan_veirfy_repo.dart';
import '../repository/login_repository.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginRepository repository;

  LoginBloc({required this.repository}) : super(const LoginState()) {
    on<LoginSendOtpPressed>(_onSendOtpPressed);
    on<LoginVerifyOtpPressed>(_onVerifyOtpPressed);
    on<LoginSnackbarCleared>(_onSnackbarCleared);
    on<LoginResendOtpPressed>(_onResendOtpPressed);
  }

  /// 🔹 Send OTP
  Future<void> _onSendOtpPressed(
      LoginSendOtpPressed event,
      Emitter<LoginState> emit,
      ) async {
    String? mobileError;

    if (event.mobile.isEmpty || event.mobile.length < 10) {
      mobileError = 'Please enter a valid phone number.';
    }

    if (mobileError != null) {
      emit(state.copyWith(mobileError: mobileError));
      return;
    }

    emit(state.copyWith(isLoading: true, mobileError: null));

    final response = await repository.sendOtp(event.mobile);

    emit(state.copyWith(isLoading: false));

    if (response.success) {
      emit(
        state.copyWith(
          viewStatus: LoginViewStatus.otpSent,
          otpRef: response.otpRef,
          snackbarMessage: response.message ?? 'OTP sent successfully!',
        ),
      );
    } else {
      emit(
        state.copyWith(
          snackbarMessage: response.message ?? 'Failed to send OTP.',
        ),
      );
    }
  }

  /// 🔹 Verify OTP
/// 🔹 Verify OTP
  Future<void> _onVerifyOtpPressed(
    LoginVerifyOtpPressed event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, otpError: null));

    final response = await repository.verifyOtp(
      phoneNumber: event.mobile,
      otpRef: event.otpRef,
      otp: event.otp,
    );

    emit(state.copyWith(isLoading: false));

    if (response.token != null && response.token!.isNotEmpty) {
      // ✅ Store globally
      final appState = getIt<AppStateProvider>();
      appState.setToken(response.token!);

      // The response also contains reqId in response.data.req_id[]
      if (response.reqId != null && response.reqId!.isNotEmpty) {
        appState.setReqId(response.reqId!);
      }

      // Optionally store name
      if (response.name != null) {
        appState.setName(response.name!);
      }
 await getIt<PanRepository>().saveToken(response.token!);
      emit(
        state.copyWith(
          token: response.token,
          snackbarMessage: 'OTP verified successfully!',
        ),
      );
    } else {
      emit(
        state.copyWith(
          otpError: response.message ?? 'Invalid OTP',
          snackbarMessage: response.message ?? 'OTP verification failed.',
        ),
      );
    }
  }

  /// 🔹 Resend OTP (no API call, just UI feedback)
  Future<void> _onResendOtpPressed(
      LoginResendOtpPressed event,
      Emitter<LoginState> emit,
      ) async {
    emit(
      state.copyWith(
        snackbarMessage: 'A new OTP has been sent to your registered number.',
      ),
    );
  }


  /// 🔹 Clear Snackbar Message
  void _onSnackbarCleared(
      LoginSnackbarCleared event,
      Emitter<LoginState> emit,
      ) {
    emit(state.copyWith(clearSnackbar: true));
  }
}
