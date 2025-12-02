import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:las_app/core/app_state_provider.dart';
import 'package:las_app/core/network/api_client.dart';
import 'package:dio/dio.dart';

part 'abcl_event.dart';
part 'abcl_state.dart';

class AbclBloc extends Bloc<AbclEvent, AbclState> {
  AbclBloc() : super(const AbclState()) {
    on<AbclSaveFormEvent>(_onSaveForm);
    on<AbclSubmitConcernEvent>(_onSubmitConcern);
  }

  Future<void> _onSaveForm(
      AbclSaveFormEvent event, Emitter<AbclState> emit) async {
    emit(state.copyWith(
      motherName: event.motherName,
      gender: event.gender,
      marital: event.marital,
      applicantType: event.applicantType,
      employmentType: event.employmentType,
      purpose: event.purpose,
      address: event.address,
      pinCode: event.pinCode,
    ));
  }

  Future<void> _onSubmitConcern(
      AbclSubmitConcernEvent event, Emitter<AbclState> emit) async {
    emit(state.copyWith(loader: true));

    final reqId = GetIt.I<AppStateProvider>().reqId;

    final body = {
      "req_id": reqId ?? "",
      "motherName": state.motherName,
      "gender": state.gender?[0],
      "maritalStatus": state.marital?[0],
      "applicantType": state.applicantType,
      "employmentType": state.employmentType,
      "purpose": state.purpose,
      "address": state.address,
      "code": state.pinCode
    };

    try {
      final response = await GetIt.I<ApiClient>().post(
        'https://api-uat.valuenable.in/lamf/customer-portal/abcl-eligibility',
        data: body,
      );

      emit(state.copyWith(loader: false, success: true));

    } catch (e) {
      emit(state.copyWith(loader: false, error: e.toString()));
    }
  }
}
