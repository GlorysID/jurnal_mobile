class AnalyticsEntity {
  final double totalPnl;
  final int totalTrades;
  final int winningTrades;
  final int losingTrades;
  final double winRate;
  final double maxDrawdown;
  final double expectedValue;
  final List<double> equityCurve; // For chart

  AnalyticsEntity({
    required this.totalPnl,
    required this.totalTrades,
    required this.winningTrades,
    required this.losingTrades,
    required this.winRate,
    required this.maxDrawdown,
    required this.expectedValue,
    required this.equityCurve,
  });

  factory AnalyticsEntity.empty() {
    return AnalyticsEntity(
      totalPnl: 0,
      totalTrades: 0,
      winningTrades: 0,
      losingTrades: 0,
      winRate: 0,
      maxDrawdown: 0,
      expectedValue: 0,
      equityCurve: [0],
    );
  }
}
