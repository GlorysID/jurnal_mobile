import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/trade_entity.dart';
import '../../domain/entities/analytics_entity.dart';
import 'trade_provider.dart';

final analyticsProvider = Provider<AnalyticsEntity>((ref) {
  final tradesAsync = ref.watch(tradesProvider);
  return tradesAsync.maybeWhen(
    data: (trades) => _calculateAnalytics(trades),
    orElse: () => AnalyticsEntity.empty(),
  );
});

AnalyticsEntity _calculateAnalytics(List<TradeEntity> trades) {
  final closedTrades = trades.where((t) => t.pnl != null).toList();
  // Sort oldest to newest for equity curve
  closedTrades.sort((a, b) => a.date.compareTo(b.date));

  if (closedTrades.isEmpty) return AnalyticsEntity.empty();

  double totalPnl = 0;
  int winningTrades = 0;
  int losingTrades = 0;
  List<double> equityCurve = [0];

  double peakEquity = 0;
  double maxDrawdown = 0;

  double currentEquity = 0;

  for (var trade in closedTrades) {
    double pnl = trade.pnl!;
    totalPnl += pnl;
    currentEquity += pnl;

    equityCurve.add(currentEquity);

    if (pnl > 0) {
      winningTrades++;
    } else if (pnl < 0) {
      losingTrades++;
    }

    if (currentEquity > peakEquity) {
      peakEquity = currentEquity;
    }

    double drawdown = peakEquity - currentEquity;
    if (drawdown > maxDrawdown) {
      maxDrawdown = drawdown;
    }
  }

  int total = closedTrades.length;
  double winRate = (winningTrades / total) * 100;
  double expectedValue = totalPnl / total;

  return AnalyticsEntity(
    totalPnl: totalPnl,
    totalTrades: total,
    winningTrades: winningTrades,
    losingTrades: losingTrades,
    winRate: winRate,
    maxDrawdown: maxDrawdown,
    expectedValue: expectedValue,
    equityCurve: equityCurve,
  );
}
