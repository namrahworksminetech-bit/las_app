import 'dart:convert';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:las_app/core/app_state_provider.dart';
import 'package:las_app/core/utils/enums.dart';
import 'package:las_app/features/portfolio/model_portfolio.dart';
import 'package:las_app/features/portfolio/repository/statement_repo.dart';
import 'package:path_provider/path_provider.dart';
import '../repository/repository_portfolio.dart';
part 'event_portfolio.dart';
part 'state_portfolio.dart';

class PortfolioBloc extends Bloc<PortfolioEvent, PortfolioState> {
  PortfolioBloc() : super(PortfolioState()) {
    on<OnClickTab>(onTabEvent);
    on<OnClickPaymentTutorial>(onRepaymentEvent);
    on<OnClickWithdraw>(onClickWithdraw);
    on<OnChangeAmount>(onChangeAmount);
        on<DownloadClientStatement>(onDownloadClientStatement);
    on<DownloadHoldingStatement>(onDownloadHoldingStatement);
  }

  onTabEvent(OnClickTab event, Emitter<PortfolioState> emit) {
    emit(state.copyWith(type: event.type));
  }

  onRepaymentEvent(OnClickPaymentTutorial event, Emitter<PortfolioState> emit) {
    emit(state.copyWith(isTutorial: event.isTutorial));
  }

 onClickWithdraw(OnClickWithdraw event, Emitter<PortfolioState> emit) {
  var amount = state.amountCtrl?.text;
  final reqId = GetIt.I<AppStateProvider>().reqId ?? '';

  PortfolioRepository().withdraw({
    'reqId': reqId,
    'amount': amount,
  });
}


  onChangeAmount(OnChangeAmount event, Emitter<PortfolioState> emit) {
    var availableAmt = double.parse(event.availableAmount ?? '0');
    var amt = double.parse(event.amount);
    if (availableAmt >= amt) {
      emit(state.copyWith(amount: event.amount));
    }else{
      emit(state.copyWith(amount: event.availableAmount));
    }
  }
  Future<void> onDownloadClientStatement(
      DownloadClientStatement event, Emitter<PortfolioState> emit) async {
    emit(state.copyWith(isDownloading: true));

    final reqId = GetIt.I<AppStateProvider>().reqId ?? '';
 
 
    final response =
        await StatementRepository().getClientStatement(reqId);

    if (response?.data?.file != null) {
      await _savePdf(response!.data!.file!, "ClientStatement.pdf");
    }

    emit(state.copyWith(isDownloading: false));
  }


  Future<void> onDownloadHoldingStatement(
      DownloadHoldingStatement event, Emitter<PortfolioState> emit) async {
    emit(state.copyWith(isDownloading: true));

    final reqId = GetIt.I<AppStateProvider>().reqId ?? '';

    final response =
        await StatementRepository().getHoldingStatement(reqId);

    if (response?.data?.file != null) {
      await _savePdf(response!.data!.file!, "HoldingStatement.pdf");
    }

    emit(state.copyWith(isDownloading: false));
  }


  Future<void> _savePdf(String base64String, String filename) async {
    final bytes = base64Decode(base64String);

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/$filename");

    await file.writeAsBytes(bytes);

    debugPrint("📄 PDF saved at: ${file.path}");
  }

}
