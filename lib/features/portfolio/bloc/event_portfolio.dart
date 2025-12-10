part of 'bloc_portfolio.dart';

abstract class PortfolioEvent extends Equatable {
  const PortfolioEvent();

  @override
  List<Object?> get props => [];
}

class DownloadClientStatement extends PortfolioEvent {}

class DownloadHoldingStatement extends PortfolioEvent {}

class OnClickTab extends PortfolioEvent {
  final EmType? type;

  const OnClickTab({this.type});

  @override
  List<Object?> get props => [type];
}

class OnClickPaymentTutorial extends PortfolioEvent {
  final bool? isTutorial;

  const OnClickPaymentTutorial({this.isTutorial});

  @override
  List<Object?> get props => [isTutorial];
}

class OnClickWithdraw extends PortfolioEvent {
  const OnClickWithdraw();
}

class OnChangeAmount extends PortfolioEvent {
  final String amount;
  final String? availableAmount;

  const OnChangeAmount(this.amount, this.availableAmount);

  @override
  List<Object?> get props => [amount, availableAmount];
}
