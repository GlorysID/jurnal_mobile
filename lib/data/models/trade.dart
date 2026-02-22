import 'package:isar/isar.dart';

part 'trade.g.dart';

@collection
class Trade {
  Id id = Isar.autoIncrement;

  @Index()
  late int userId;

  @Index()
  late DateTime date;

  late String pair;
  late String marketType; // 'Futures', 'Spot DEX'
  late String direction; // 'Long', 'Short', 'Buy'

  late double entryPrice;
  double? exitPrice;
  double? stopLoss;
  double? takeProfit;

  late double positionSize;
  int? leverage;
  double? fee;
  double? riskPercentage;

  double? pnl;

  int? strategyId;
  String? notes;
  String? screenshotPath;

  late DateTime createdAt;
}
