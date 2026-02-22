import 'package:isar/isar.dart';
import '../../domain/entities/trade_entity.dart';
import '../../domain/entities/trade_filter.dart';
import '../../domain/repositories/trade_repository.dart';
import '../database/isar_service.dart';
import '../models/trade.dart';

class TradeRepositoryImpl implements TradeRepository {
  final IsarService _isarService;

  TradeRepositoryImpl(this._isarService);

  @override
  Future<List<TradeEntity>> getTrades(int userId) async {
    final isar = await _isarService.db;
    final trades = await isar.trades
        .filter()
        .userIdEqualTo(userId)
        .sortByDateDesc()
        .findAll();
    return trades.map(_mapToEntity).toList();
  }

  @override
  Future<TradeEntity> createTrade(TradeEntity entity) async {
    final isar = await _isarService.db;
    final model = _mapToModel(entity);

    await isar.writeTxn(() async {
      final id = await isar.trades.put(model);
      model.id = id;
    });

    return _mapToEntity(model);
  }

  @override
  Future<TradeEntity> updateTrade(TradeEntity entity) async {
    final isar = await _isarService.db;
    final model = _mapToModel(entity);
    model.id = entity.id; // ensure ID is set for update

    await isar.writeTxn(() async {
      await isar.trades.put(model);
    });

    return _mapToEntity(model);
  }

  @override
  Future<void> deleteTrade(int tradeId) async {
    final isar = await _isarService.db;
    await isar.writeTxn(() async {
      await isar.trades.delete(tradeId);
    });
  }

  @override
  Future<List<TradeEntity>> searchTrades(int userId, String query) async {
    final isar = await _isarService.db;
    final q = query.toLowerCase();

    final trades = await isar.trades
        .filter()
        .userIdEqualTo(userId)
        .and()
        .group(
          (qBuilder) => qBuilder
              .pairContains(q, caseSensitive: false)
              .or()
              .notesContains(q, caseSensitive: false),
        )
        .sortByDateDesc()
        .findAll();

    return trades.map(_mapToEntity).toList();
  }

  @override
  Future<List<TradeEntity>> getFilteredTrades(
    int userId,
    TradeFilter filter,
  ) async {
    final isar = await _isarService.db;
    var query = isar.trades.filter().userIdEqualTo(userId);

    switch (filter) {
      case TradeFilter.all:
        // Already filtered by userId
        break;
      case TradeFilter.winning:
        query = query.and().pnlGreaterThan(0);
        break;
      case TradeFilter.losing:
        query = query.and().pnlLessThan(0);
        break;
      case TradeFilter.today:
        final now = DateTime.now();
        final startOfDay = DateTime(now.year, now.month, now.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));
        query = query.and().dateBetween(startOfDay, endOfDay);
        break;
    }

    final trades = await query.sortByDateDesc().findAll();
    return trades.map(_mapToEntity).toList();
  }

  TradeEntity _mapToEntity(Trade model) {
    return TradeEntity(
      id: model.id,
      userId: model.userId,
      date: model.date,
      pair: model.pair,
      marketType: model.marketType,
      direction: model.direction,
      entryPrice: model.entryPrice,
      exitPrice: model.exitPrice,
      stopLoss: model.stopLoss,
      takeProfit: model.takeProfit,
      positionSize: model.positionSize,
      leverage: model.leverage,
      fee: model.fee,
      riskPercentage: model.riskPercentage,
      pnl: model.pnl,
      strategyId: model.strategyId,
      notes: model.notes,
      screenshotPath: model.screenshotPath,
      createdAt: model.createdAt,
    );
  }

  Trade _mapToModel(TradeEntity entity) {
    return Trade()
      ..userId = entity.userId
      ..date = entity.date
      ..pair = entity.pair
      ..marketType = entity.marketType
      ..direction = entity.direction
      ..entryPrice = entity.entryPrice
      ..exitPrice = entity.exitPrice
      ..stopLoss = entity.stopLoss
      ..takeProfit = entity.takeProfit
      ..positionSize = entity.positionSize
      ..leverage = entity.leverage
      ..fee = entity.fee
      ..riskPercentage = entity.riskPercentage
      ..pnl = entity.pnl
      ..strategyId = entity.strategyId
      ..notes = entity.notes
      ..screenshotPath = entity.screenshotPath
      ..createdAt = entity.createdAt;
  }
}
