class PortfolioData {
  final double totalValue;
  final double eligibleCreditLimit;
  final double pledgeableFunds;

  const PortfolioData({
    this.totalValue = 0.0,
    this.eligibleCreditLimit = 0.0,
    this.pledgeableFunds = 0.0,
  });

  factory PortfolioData.fromJson(Map<String, dynamic> json) {
    return PortfolioData(
      totalValue: (json['total_portfolio'] ?? 0).toDouble(),
      eligibleCreditLimit: (json['pledgeableAmount'] ?? 0).toDouble(),
      pledgeableFunds: (json['eligible_portfolio'] ?? 0).toDouble(),
    );
  }
}
