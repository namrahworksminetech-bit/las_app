part of 'bloc_portfolio.dart';

class PortfolioState extends Equatable {
  GlobalKey<FormState> formKey = GlobalKey();

  List<TabModel> tabList = [
    TabModel('Mutual Funds', EmType.laMf),
    TabModel('Shares', EmType.laS),
    TabModel('Insurance Policy', EmType.laIp),
  ];

  EmType selectedTab;

  bool? isTutorial;

  TextEditingController? amountCtrl;

  PortfolioState({
    this.selectedTab = EmType.laMf,
    this.isTutorial = false,
    this.amountCtrl,
  });

  PortfolioState copyWith({
    EmType? type,
    bool? isTutorial,
    String? amount,
  }) {
    return PortfolioState(
      selectedTab: type ?? selectedTab,
      isTutorial: isTutorial,
      amountCtrl: TextEditingController(text: amount),
    );
  }

  @override
  List<Object> get props => [
    selectedTab,
    isTutorial ?? false,
    amountCtrl ?? '0',
  ];
}
