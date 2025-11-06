import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../repository/kyc_repository.dart';
import 'kyc_event.dart';
import 'kyc_state.dart';

class KycBloc extends Bloc<KycEvent, KycState> {
  final KycRepository _repository;

  KycBloc(this._repository) : super(KycInitial()) {
    on<StartKycEvent>(_onStartKyc);
  }

  Future<void> _onStartKyc(StartKycEvent event, Emitter<KycState> emit) async {
    emit(KycLoading());
    try {
      final response = await _repository.startKyc(
        reqId: event.reqId,
        lenderCode: event.lenderCode,
        latitude: event.latitude,
        longitude: event.longitude,
      );

      if (response.status == 'success') {
        // Launch URL in browser
        await _launchUrl(response.data.url);
        // Emit success to trigger navigation
        emit(KycSuccess(response.data.url));
      } else {
        emit(KycError('KYC initiation failed'));
      }
    } catch (e) {
      String errorMessage = 'Unknown error';
      if (e is DioException && e.response != null) {
        errorMessage = 'STATUS CODE: ${e.response!.statusCode}';
      }
      emit(KycError(errorMessage));
    }
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      print('Failed to launch URL: $e');
      // Try alternative launch mode
      try {
        final uri = Uri.parse(url);
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      } catch (e2) {
        print('Failed to launch URL with platform default: $e2');
      }
    }
  }
}
