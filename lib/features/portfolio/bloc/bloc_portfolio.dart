import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:las_app/core/utils/enums.dart';
import 'package:las_app/features/portfolio/model_portfolio.dart';

import '../repository_portfolio.dart';

part 'event_portfolio.dart';

part 'state_portfolio.dart';

class PortfolioBloc extends Bloc<PortfolioEvent, PortfolioState> {
  PortfolioBloc() : super(PortfolioState()) {
    on<OnClickTab>(onTabEvent);
    on<OnClickPaymentTutorial>(onRepaymentEvent);
    on<OnClickWithdraw>(onClickWithdraw);
    on<OnChangeAmount>(onChangeAmount);
  }

  onTabEvent(OnClickTab event, Emitter<PortfolioState> emit) {
    emit(state.copyWith(type: event.type));
  }

  onRepaymentEvent(OnClickPaymentTutorial event, Emitter<PortfolioState> emit) {
    emit(state.copyWith(isTutorial: event.isTutorial));
  }

  onClickWithdraw(OnClickWithdraw event, Emitter<PortfolioState> emit) {
    var amount = state.amountCtrl?.text;
    PortfolioRepository().withdraw({
      'reqId': 'b5cc9725-be1b-11f0-8e58-0ace226b9915',
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
}
