class TradeEntity {
  final int id;
  final int userId;
  final DateTime date;
  final String pair;
  final String marketType; // 'Futures', 'Spot DEX'
  final String direction; // 'Long', 'Short', 'Buy'
  final double entryPrice;
  final double? exitPrice;
  final double? stopLoss;
  final double? takeProfit;
  final double positionSize;
  final int? leverage;
  final double? fee;
  final double? riskPercentage;
  final double? pnl;
  final int? strategyId;
  final String? notes;
  final String? screenshotPath;
  final DateTime createdAt;

  TradeEntity({
    required this.id,
    required this.userId,
    required this.date,
    required this.pair,
    required this.marketType,
    required this.direction,
    required this.entryPrice,
    this.exitPrice,
    this.stopLoss,
    this.takeProfit,
    required this.positionSize,
    this.leverage,
    this.fee,
    this.riskPercentage,
    this.pnl,
    this.strategyId,
    this.notes,
    this.screenshotPath,
    required this.createdAt,
  });
}
